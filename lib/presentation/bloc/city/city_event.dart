part of 'city_bloc.dart';

abstract class CityEvent extends Equatable {
  const CityEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavedCity extends CityEvent {
  const LoadSavedCity();
}

class SelectCity extends CityEvent {
  const SelectCity(this.city);
  final City city;

  @override
  List<Object?> get props => [city];
}
