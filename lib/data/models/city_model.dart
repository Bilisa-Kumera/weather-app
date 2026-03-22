import '../../domain/entities/city.dart';

class CityModel {
  CityModel({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  final String name;
  final String country;
  final double lat;
  final double lon;

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      country: json['country'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  factory CityModel.fromLocalJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      country: json['country'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  City toEntity() => City(name: name, country: country, lat: lat, lon: lon);

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'lat': lat,
        'lon': lon,
      };
}
