import 'package:equatable/equatable.dart';

class City extends Equatable {
  const City({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  final String name;
  final String country;
  final double lat;
  final double lon;

  @override
  List<Object?> get props => [name, country, lat, lon];
}
