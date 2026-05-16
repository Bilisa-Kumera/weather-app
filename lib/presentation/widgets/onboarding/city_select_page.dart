import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../../../core/services/location_service.dart';
import '../../../core/utils/responsive.dart';
import '../../../domain/entities/city.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/city/city_bloc.dart';

class CitySelectPage extends StatefulWidget {
  const CitySelectPage({super.key, required this.onFinish, required this.onBack});

  final VoidCallback onFinish;
  final VoidCallback onBack;

  @override
  State<CitySelectPage> createState() => _CitySelectPageState();
}

class _CitySelectPageState extends State<CitySelectPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker(BuildContext context) async {
    // Check and request location before opening map
    final hasPermission = await _handleLocationPermission(context);
    if (!hasPermission) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const _MapPickerScreen(),
      ),
    );
  }

  Future<bool> _handleLocationPermission(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      final shouldOpenSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n.locationServiceTitle,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            l10n.locationServicesDisabled,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                l10n.enable,
                style: const TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
      
      if (shouldOpenSettings == true) {
        await Geolocator.openLocationSettings();
      }
      return false;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.locationPermissionDenied),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.locationPermissionPermanentlyDenied),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            action: SnackBarAction(
              label: l10n.settings,
              textColor: Colors.white,
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ),
        );
      }
      return false;
    }

    return true;
  }

 Future<void> _getCurrentLocation(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  
  debugPrint('🏙️ CITY_SELECT: Starting _getCurrentLocation');
  
  HapticFeedback.mediumImpact();
  
  try {
    final hasPermission = await _handleLocationPermission(context);
    debugPrint('🏙️ CITY_SELECT: Permission result: $hasPermission');
    
    if (!hasPermission) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2DD4BF),
          strokeWidth: 3,
        ),
      ),
    );

    final locationService = LocationService();
    final city = await locationService.getCurrentCity();
    
    // Pop loading dialog
    if (mounted) Navigator.of(context).pop();

    debugPrint('🏙️ CITY_SELECT: City result: ${city?.name}');
    
    if (city != null) {
      context.read<CityBloc>().add(SelectCity(city));
      
      // Show different message for fallback vs real city
      final message = city.country == 'Unknown' && city.name.startsWith('Location ')
          ? l10n.locationFoundCoordinatesOnly
          : l10n.locationFound(city.name);
          
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.currentLocationError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  } catch (e, stackTrace) {
    debugPrint('🏙️ CITY_SELECT: ERROR: $e');
    debugPrint('🏙️ CITY_SELECT: Stack: $stackTrace');
    
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(l10n.errorDetails(e.toString())),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Slate 900
              Color(0xFF134E4A), // Teal 900
              Color(0xFF0D9488), // Teal 600
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background particles
            Positioned.fill(
              child: CustomPaint(
                painter: _ParticlePainter(),
              ),
            ),
            
            // Gradient orbs
            Positioned(
              top: -r.h(120),
              right: -r.w(100),
              child: _GradientOrb(
                size: r.w(350),
                colors: const [
                  Color(0xFF2DD4BF), // Teal 400
                  Color(0xFF14B8A6), // Teal 500
                ],
              ),
            ),
            Positioned(
              bottom: -r.h(80),
              left: -r.w(120),
              child: _GradientOrb(
                size: r.w(300),
                colors: const [
                  Color(0xFF06B6D4), // Cyan 500
                  Color(0xFF0891B2), // Cyan 600
                ],
              ),
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(r.w(24)),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modern back button
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(r.r(16)),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: widget.onBack,
                                borderRadius: BorderRadius.circular(r.r(16)),
                                child: Container(
                                  padding: EdgeInsets.all(r.w(12)),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: r.w(20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: r.w(16)),
                          Text(
                            l10n.selectCity,
                            style: TextStyle(
                              fontSize: r.sp(20),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: r.h(32)),
                      
                      // Main glass card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(r.w(24)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(r.r(28)),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2DD4BF).withOpacity(0.15),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                              spreadRadius: -10,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Location icon
                            Container(
                              width: r.w(64),
                              height: r.w(64),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2DD4BF),
                                    Color(0xFF14B8A6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(r.r(20)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2DD4BF).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: r.w(32),
                              ),
                            ),
                            
                            SizedBox(height: r.h(20)),
                            
                            // Title
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFFCCFBF1),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                l10n.selectLocation,
                                style: TextStyle(
                                  fontSize: r.sp(28),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            
                            SizedBox(height: r.h(10)),
                            
                            // Subtitle
                            Text(
                              l10n.citySelectionInfo,
                              style: TextStyle(
                                fontSize: r.sp(14),
                                color: Colors.white.withOpacity(0.75),
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            
                            SizedBox(height: r.h(24)),
                            
                            // Location buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _ModernButton(
                                    icon: Icons.my_location_rounded,
                                    label: l10n.currentLocation,
                                    isPrimary: true,
                                    onTap: () => _getCurrentLocation(context),
                                  ),
                                ),
                                SizedBox(width: r.w(12)),
                                Expanded(
                                  child: _ModernButton(
                                    icon: Icons.map_rounded,
                                    label: l10n.pickFromMap,
                                    isPrimary: false,
                                    onTap: () => _openMapPicker(context),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: r.h(20)),
                            
                            // Selected city indicator
                            BlocBuilder<CityBloc, CityState>(
                              builder: (context, state) {
                                final selected = state.selectedCity;
                                final enabled = selected != null;
                                
                                return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(r.w(16)),
                                  decoration: BoxDecoration(
                                    color: enabled 
                                        ? const Color(0xFF2DD4BF).withOpacity(0.15)
                                        : Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(r.r(16)),
                                    border: Border.all(
                                      color: enabled 
                                          ? const Color(0xFF2DD4BF).withOpacity(0.3)
                                          : Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        enabled ? Icons.check_circle_rounded : Icons.location_city_rounded,
                                        color: enabled ? const Color(0xFF2DD4BF) : Colors.white.withOpacity(0.5),
                                        size: r.w(24),
                                      ),
                                      SizedBox(width: r.w(12)),
                                      Expanded(
                                        child: Text(
                                          enabled 
                                              ? '${selected.name}, ${selected.country}'
                                              : l10n.selectCityFirst,
                                          style: TextStyle(
                                            fontSize: r.sp(14),
                                            fontWeight: enabled ? FontWeight.w600 : FontWeight.w400,
                                            color: enabled ? Colors.white : Colors.white.withOpacity(0.5),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (enabled)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: r.w(8),
                                            vertical: r.h(4),
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2DD4BF),
                                            borderRadius: BorderRadius.circular(r.r(8)),
                                          ),
                                          child: Text(
                                            l10n.selected,
                                            style: TextStyle(
                                              fontSize: r.sp(10),
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            
                            SizedBox(height: r.h(20)),
                            
                            // Continue button
                            BlocBuilder<CityBloc, CityState>(
                              builder: (context, state) {
                                final selected = state.selectedCity;
                                final enabled = selected != null;
                                
                                return Container(
                                  width: double.infinity,
                                  height: r.h(54),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(r.r(18)),
                                    gradient: enabled
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFFF8FAFC),
                                              Color(0xFFE2E8F0),
                                            ],
                                          )
                                        : null,
                                    color: enabled ? null : Colors.white.withOpacity(0.1),
                                    boxShadow: enabled
                                        ? [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.2),
                                              blurRadius: 20,
                                              offset: const Offset(0, -5),
                                            ),
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: enabled
                                          ? () async {
                                              FocusScope.of(context).unfocus();
                                              widget.onFinish();
                                            }
                                          : null,
                                      borderRadius: BorderRadius.circular(r.r(18)),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              l10n.continueToHome,
                                              style: TextStyle(
                                                fontSize: r.sp(16),
                                                fontWeight: FontWeight.w700,
                                                color: enabled
                                                    ? const Color(0xFF0F172A)
                                                    : Colors.white.withOpacity(0.4),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            if (enabled) ...[
                                              SizedBox(width: r.w(8)),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: const Color(0xFF0F172A),
                                                size: r.w(20),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Bottom note
                      Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: r.w(16), vertical: r.h(8)),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(r.r(12)),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            l10n.changeLaterInSettings,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: r.sp(12),
                              color: Colors.white.withOpacity(0.6),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: r.h(12)),
                      
                      // Progress indicator
                      Center(
                        child: Container(
                          width: r.w(40),
                          height: r.h(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(r.r(2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern button widget
class _ModernButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ModernButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.r(16)),
        gradient: isPrimary
            ? const LinearGradient(
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFE2E8F0),
                ],
              )
            : null,
        color: isPrimary ? null : Colors.transparent,
        border: isPrimary
            ? null
            : Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r.r(16)),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: r.h(14)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isPrimary ? const Color(0xFF0F172A) : Colors.white,
                  size: r.w(18),
                ),
                SizedBox(width: r.w(8)),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: r.sp(13),
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? const Color(0xFF0F172A) : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Gradient orb widget
class _GradientOrb extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GradientOrb({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            ...colors,
            colors.last.withOpacity(0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// Particle painter
class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    
    for (var i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 0.5;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Map Picker Screen with proper location handling
class _MapPickerScreen extends StatefulWidget {
  const _MapPickerScreen();

  @override
  State<_MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<_MapPickerScreen> {
  LatLng? _selectedLocation;
  LatLng? _currentLocation;
  final MapController _mapController = MapController();
  bool _isLoadingLocation = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  /// RELIABLE LOCATION INITIALIZATION
  /// Uses same strategy as LocationService: last known -> low accuracy -> high accuracy
  Future<void> _initializeLocation() async {
    debugPrint('🗺️ MAP_PICKER: Initializing location...');
    
    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      debugPrint('🗺️ MAP_PICKER: serviceEnabled = $serviceEnabled');
      
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.locationServicesDisabled;
          _isLoadingLocation = false;
        });
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('🗺️ MAP_PICKER: permission = $permission');
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.locationPermissionDenied;
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.locationPermissionPermanentlyDenied;
          _isLoadingLocation = false;
        });
        return;
      }

      // STRATEGY 1: Try last known position first (instant)
      debugPrint('🗺️ MAP_PICKER: Trying getLastKnownPosition...');
      Position? position = await Geolocator.getLastKnownPosition();
      
      if (position != null) {
        final age = DateTime.now().difference(position.timestamp ?? DateTime.now());
        debugPrint('🗺️ MAP_PICKER: Last known position: ${position.latitude}, ${position.longitude}, age: ${age.inMinutes}m');
        
        // Use last known if less than 1 hour old
        if (age.inHours < 1) {
          debugPrint('🗺️ MAP_PICKER: Using last known position');
          _setLocation(position.latitude, position.longitude);
          return;
        }
      }

      // STRATEGY 2: Try low accuracy with short timeout
      debugPrint('🗺️ MAP_PICKER: Trying low accuracy...');
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        ).timeout(const Duration(seconds: 5));
        
        debugPrint('🗺️ MAP_PICKER: Low accuracy success: ${position.latitude}, ${position.longitude}');
        _setLocation(position.latitude, position.longitude);
        return;
        
      } on TimeoutException catch (_) {
        debugPrint('🗺️ MAP_PICKER: Low accuracy timed out');
      }

      // STRATEGY 3: Try high accuracy
      debugPrint('🗺️ MAP_PICKER: Trying high accuracy...');
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));
        
        debugPrint('🗺️ MAP_PICKER: High accuracy success: ${position.latitude}, ${position.longitude}');
        _setLocation(position.latitude, position.longitude);
        return;
        
      } on TimeoutException catch (_) {
        debugPrint('🗺️ MAP_PICKER: High accuracy timed out');
      }

      if (position == null) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          debugPrint('🗺️ MAP_PICKER: Falling back to old last known position');
          _setLocation(lastKnown.latitude, lastKnown.longitude);
          return;
        }
      }

      debugPrint('🗺️ MAP_PICKER: All location strategies failed');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.couldNotGetCurrentLocationSelectManually;
        _isLoadingLocation = false;
      });

    } catch (e, stack) {
      debugPrint('🗺️ MAP_PICKER: ERROR: $e');
      debugPrint('🗺️ MAP_PICKER: Stack: $stack');
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.errorGettingLocation(e.toString());
        _isLoadingLocation = false;
      });
    }
  }

  void _setLocation(double lat, double lon) {
    final location = LatLng(lat, lon);
    setState(() {
      _currentLocation = location;
      _selectedLocation = location;
      _isLoadingLocation = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapController.move(location, 15.0);
      }
    });
  }

  Future<void> _recenterToCurrentLocation() async {
    debugPrint('🗺️ MAP_PICKER: Recentering to current location...');
    
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
      setState(() {
        _selectedLocation = _currentLocation;
      });
    } else {
      setState(() {
        _isLoadingLocation = true;
        _errorMessage = null;
      });
      await _initializeLocation();
    }
  }

  Future<void> _confirmLocation() async {
    if (_selectedLocation == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF2DD4BF)),
      ),
    );

    try {
      final locationService = LocationService();
      final city = await locationService.reverseGeocode(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
      );

      if (mounted) Navigator.of(context).pop();

      if (city != null && mounted) {
        context.read<CityBloc>().add(SelectCity(city));
        Navigator.of(context).pop();
      } else {
        // Fallback to coordinates
        final fallbackCity = City(
          name: '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
          country: 'Unknown',
          lat: _selectedLocation!.latitude,
          lon: _selectedLocation!.longitude,
        );
        if (mounted) {
          context.read<CityBloc>().add(SelectCity(fallbackCity));
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDetails(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(r.w(8)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(r.r(12)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          l10n.mapPickerTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: r.sp(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_selectedLocation != null)
            Container(
              margin: EdgeInsets.only(right: r.w(16)),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2DD4BF), Color(0xFF14B8A6)],
                ),
                borderRadius: BorderRadius.circular(r.r(12)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _confirmLocation,
                  borderRadius: BorderRadius.circular(r.r(12)),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: r.w(16), vertical: r.h(8)),
                    child: Text(
                      l10n.confirm,
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation ?? const LatLng(9.145, 38.7319),
              initialZoom: _currentLocation != null ? 15.0 : 5.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.app.weatherify',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: r.w(40),
                      height: r.h(40),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2DD4BF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2DD4BF).withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: r.w(24),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          // Loading overlay
          if (_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF2DD4BF),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: r.h(16)),
                    Text(
                      l10n.gettingYourLocation,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: r.sp(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error overlay
          if (_errorMessage != null && !_isLoadingLocation)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Container(
                  margin: EdgeInsets.all(r.w(24)),
                  padding: EdgeInsets.all(r.w(24)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(r.r(20)),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_off_rounded,
                        color: Colors.red,
                        size: r.w(48),
                      ),
                      SizedBox(height: r.h(16)),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: r.sp(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: r.h(20)),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _isLoadingLocation = true;
                          });
                          _initializeLocation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2DD4BF),
                          foregroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(r.r(12)),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: r.w(24),
                            vertical: r.h(12),
                          ),
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Recenter button
          Positioned(
            bottom: r.h(24),
            right: r.w(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(r.r(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _recenterToCurrentLocation,
                  borderRadius: BorderRadius.circular(r.r(16)),
                  child: Container(
                    padding: EdgeInsets.all(r.w(12)),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: Color(0xFF2DD4BF),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: r.h(24),
            left: r.w(16),
            right: r.w(80),
            child: Container(
              padding: EdgeInsets.all(r.w(12)),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.9),
                borderRadius: BorderRadius.circular(r.r(12)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Text(
                l10n.tapMapToSelectLocation,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: r.sp(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
