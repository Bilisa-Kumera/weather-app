part of 'location_bloc.dart';

enum LocationStatus {
  initial,
  loading,
  success,
  failure,
}

class LocationState extends Equatable {
  const LocationState({
    this.status = LocationStatus.initial,
    this.city,
    this.message,
  });

  final LocationStatus status;
  final City? city;
  final String? message;

  LocationState copyWith({
    LocationStatus? status,
    City? city,
    String? message,
  }) {
    return LocationState(
      status: status ?? this.status,
      city: city ?? this.city,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, city, message];
}