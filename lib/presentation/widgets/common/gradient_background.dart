import 'dart:ui';

import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.colors,
    required this.child,
  });

  final List<Color> colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _BlurBlob(color: Colors.white.withOpacity(0.2), size: 220),
        ),
        Positioned(
          bottom: -140,
          left: -60,
          child: _BlurBlob(color: Colors.white.withOpacity(0.1), size: 260),
        ),
        child,
      ],
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: const SizedBox(),
        ),
      ),
    );
  }
}
