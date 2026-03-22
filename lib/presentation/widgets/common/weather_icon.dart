import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';

class WeatherIcon extends StatelessWidget {
  const WeatherIcon({super.key, required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      placeholder: (_, __) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: SizedBox(
            width: r.w(16),
            height: r.w(16),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => Icon(
        Icons.cloud,
        size: size,
        color: Colors.white70,
      ),
    );
  }
}
