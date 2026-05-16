import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/city.dart';

class LocationService {
  Future<bool> requestPermission() async {
    debugPrint('📍 LOC_SERVICE: requestPermission() called');
    
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('📍 LOC_SERVICE: serviceEnabled = $serviceEnabled');
    
    if (!serviceEnabled) {
      debugPrint('📍 LOC_SERVICE: Location services disabled');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    debugPrint('📍 LOC_SERVICE: current permission = $permission');
    
    if (permission == LocationPermission.denied) {
      debugPrint('📍 LOC_SERVICE: Requesting permission...');
      permission = await Geolocator.requestPermission();
      debugPrint('📍 LOC_SERVICE: permission after request = $permission');
    }
    
    final granted = permission == LocationPermission.whileInUse || 
                    permission == LocationPermission.always;
    debugPrint('📍 LOC_SERVICE: permission granted = $granted');
    return granted;
  }

  /// RELIABLE LOCATION STRATEGY:
  /// 1. Return last known position immediately (even if old - good enough for weather)
  /// 2. Try to get fresh low accuracy position in background
  /// 3. Only if no last known position, try harder
  Future<Position?> getCurrentPosition() async {
    debugPrint('📍 LOC_SERVICE: getCurrentPosition() called');
    
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        debugPrint('📍 LOC_SERVICE: No permission');
        return null;
      }

      // STRATEGY 1: Get last known position immediately
      debugPrint('📍 LOC_SERVICE: Getting last known position...');
      final lastKnown = await Geolocator.getLastKnownPosition();
      
      if (lastKnown != null) {
        final age = DateTime.now().difference(lastKnown.timestamp ?? DateTime.now());
        debugPrint('📍 LOC_SERVICE: Last known position: ${lastKnown.latitude}, ${lastKnown.longitude}, age: ${age.inMinutes} minutes');
        
        // For weather app, even 1-hour old location is acceptable
        // Return it immediately without waiting for fresh location
        if (age.inHours < 1) {
          debugPrint('📍 LOC_SERVICE: Using last known position (acceptable for weather)');
          return lastKnown;
        } else {
          debugPrint('📍 LOC_SERVICE: Last known position very old (${age.inHours} hours), trying fresh...');
        }
      }

      // STRATEGY 2: Try to get fresh location with short timeout
      debugPrint('📍 LOC_SERVICE: Trying fresh location with 5s timeout...');
      try {
        final freshPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        ).timeout(const Duration(seconds: 5));
        
        debugPrint('📍 LOC_SERVICE: Fresh location obtained: ${freshPosition.latitude}, ${freshPosition.longitude}');
        return freshPosition;
        
      } on TimeoutException catch (_) {
        debugPrint('📍 LOC_SERVICE: Fresh location timed out');
        
        // FALLBACK: Return last known position even if old, rather than null
        if (lastKnown != null) {
          debugPrint('📍 LOC_SERVICE: Falling back to old last known position');
          return lastKnown;
        }
      }

      // STRATEGY 3: If no last known and fresh failed, try one more time with high accuracy
      if (lastKnown == null) {
        debugPrint('📍 LOC_SERVICE: No last known, trying high accuracy...');
        try {
          final highAccuracy = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(const Duration(seconds: 8));
          debugPrint('📍 LOC_SERVICE: High accuracy obtained');
          return highAccuracy;
        } on TimeoutException catch (_) {
          debugPrint('📍 LOC_SERVICE: High accuracy also timed out');
        }
      }
      
      debugPrint('📍 LOC_SERVICE: All strategies failed');
      return null;
      
    } catch (e, stack) {
      debugPrint('📍 LOC_SERVICE: ERROR: $e');
      debugPrint('📍 LOC_SERVICE: Stack: $stack');
      return null;
    }
  }

  Future<City?> reverseGeocode(double lat, double lon) async {
    debugPrint('📍 LOC_SERVICE: reverseGeocode($lat, $lon)');
    
    try {
      debugPrint('📍 LOC_SERVICE: Calling placemarkFromCoordinates...');
      final placemarks = await placemarkFromCoordinates(lat, lon);
      debugPrint('📍 LOC_SERVICE: Found ${placemarks.length} placemarks');
      
      if (placemarks.isEmpty) {
        debugPrint('📍 LOC_SERVICE: No placemarks found');
        return null;
      }

      final place = placemarks.first;
      debugPrint('📍 LOC_SERVICE: Placemark: locality=${place.locality}, subAdmin=${place.subAdministrativeArea}, admin=${place.administrativeArea}, country=${place.country}');
      
      final cityName = place.locality ?? 
                       place.subAdministrativeArea ?? 
                       place.administrativeArea;
      
      debugPrint('📍 LOC_SERVICE: cityName = $cityName');

      if (cityName == null || cityName.isEmpty) {
        debugPrint('📍 LOC_SERVICE: cityName is null/empty');
        return null;
      }

      return City(
        name: cityName,
        country: place.country ?? 'Unknown',
        lat: lat,
        lon: lon,
      );
      
    } catch (e, stack) {
      debugPrint('📍 LOC_SERVICE: ERROR in reverseGeocode: $e');
      debugPrint('📍 LOC_SERVICE: Stack: $stack');
      return null;
    }
  }

  Future<City?> getCurrentCity() async {
    debugPrint('📍 LOC_SERVICE: ===== getCurrentCity() START =====');
    
    final position = await getCurrentPosition();
    debugPrint('📍 LOC_SERVICE: position = $position');
    
    if (position == null) {
      debugPrint('📍 LOC_SERVICE: No position, returning null');
      return null;
    }

    var city = await reverseGeocode(position.latitude, position.longitude);
    debugPrint('📍 LOC_SERVICE: reverseGeocode result = ${city?.name}');
    
    // FALLBACK: If geocoding fails, create city from coordinates
    if (city == null) {
      debugPrint('📍 LOC_SERVICE: Creating fallback city from coordinates');
      city = City(
        name: 'Location ${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}',
        country: 'Unknown',
        lat: position.latitude,
        lon: position.longitude,
      );
      debugPrint('📍 LOC_SERVICE: Fallback city created: ${city.name}');
    }
    
    debugPrint('📍 LOC_SERVICE: ===== getCurrentCity() END =====');
    return city;
  }
}