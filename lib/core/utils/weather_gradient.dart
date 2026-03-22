import 'package:flutter/material.dart';

class WeatherGradient {
  static List<Color> forCondition({required String condition, required bool isDay}) {
    final c = condition.toLowerCase();

    if (!isDay) {
      return const [
        Color(0xFF312E81),
        Color(0xFF581C87),
        Color(0xFF1E3A8A),
      ];
    }

    if (c.contains('rain') || c.contains('drizzle') || c.contains('thunder')) {
      return const [
        Color(0xFF3B82F6),
        Color(0xFF2563EB),
        Color(0xFF4338CA),
      ];
    }

    if (c.contains('snow') || c.contains('sleet') || c.contains('ice')) {
      return const [
        Color(0xFFBFDBFE),
        Color(0xFF93C5FD),
        Color(0xFFD8B4FE),
      ];
    }

    if (c.contains('cloud') || c.contains('mist') || c.contains('fog')) {
      return const [
        Color(0xFF9CA3AF),
        Color(0xFF6B7280),
        Color(0xFF4B5563),
      ];
    }

    if (c.contains('clear') || c.contains('sun')) {
      return const [
        Color(0xFFFB923C),
        Color(0xFFFACC15),
        Color(0xFFF472B6),
      ];
    }

    return const [
      Color(0xFFFB923C),
      Color(0xFFFACC15),
      Color(0xFFF472B6),
    ];
  }
}
