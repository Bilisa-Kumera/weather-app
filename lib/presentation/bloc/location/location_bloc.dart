import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/location_service.dart';
import '../../../domain/entities/city.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc(this._locationService) : super(const LocationState()) {
    on<GetCurrentLocation>(_onGetCurrentLocation);
  }

  final LocationService _locationService;

  Future<void> _onGetCurrentLocation(
    GetCurrentLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(state.copyWith(status: LocationStatus.loading));

    try {
      final city = await _locationService.getCurrentCity();
      if (city != null) {
        emit(state.copyWith(status: LocationStatus.success, city: city));
      } else {
        emit(state.copyWith(
          status: LocationStatus.failure,
          message: 'Unable to get current location',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LocationStatus.failure,
        message: 'Location service error: ${e.toString()}',
      ));
    }
  }
}