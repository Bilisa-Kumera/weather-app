part of 'city_bloc.dart';

enum CityStatus { initial, loading, success, failure, empty }

class CityState extends Equatable {
  const CityState({
    this.status = CityStatus.initial,
    this.selectedCity,
    this.message,
  });

  final CityStatus status;
  final City? selectedCity;
  final String? message;

  CityState copyWith({CityStatus? status, City? selectedCity, String? message}) {
    return CityState(
      status: status ?? this.status,
      selectedCity: selectedCity ?? this.selectedCity,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, selectedCity, message];
}
