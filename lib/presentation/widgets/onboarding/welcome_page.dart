import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/utils/responsive.dart';
import '../../../l10n/app_localizations.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            Positioned.fill(
              child: CustomPaint(
                painter: _ParticlePainter(),
              ),
            ),
            
            Positioned(
              top: -r.h(100),
              right: -r.w(80),
              child: _GradientOrb(
                size: r.w(300),
                colors: const [
                  Color(0xFF2DD4BF), // Teal 400
                  Color(0xFF14B8A6), // Teal 500
                ],
              ),
            ),
            Positioned(
              bottom: -r.h(50),
              left: -r.w(100),
              child: _GradientOrb(
                size: r.w(250),
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
                        child: Transform.scale(
                          scale: _scaleAnimation.value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: r.h(20)),
                      
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(r.w(28)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(r.r(32)),
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
                              color: const Color(0xFF14B8A6).withOpacity(0.15),
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
                          children: [
                            Container(
                              width: r.w(120),
                              height: r.w(120),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFFEF3C7),
                                    Color(0xFFFDE68A),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.wb_sunny_rounded,
                                  size: r.w(56),
                                  color: const Color(0xFFD97706),
                                ),
                              ),
                            ),
                            SizedBox(height: r.h(24)),
                            
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Color(0xFFCCFBF1),
                                ],
                              ).createShader(bounds),
                              child: Text(
                                l10n.welcomeTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: r.sp(32),
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            SizedBox(height: r.h(14)),
                            
                            Text(
                              l10n.welcomeSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: r.sp(15),
                                color: Colors.white.withOpacity(0.75),
                                height: 1.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: r.h(28)),
                      
                      Wrap(
                        spacing: r.w(12),
                        runSpacing: r.h(12),
                        children: [
                          _ModernFeatureChip(
                            icon: Icons.bolt_rounded,
                            label: l10n.featureRealtimeUpdates,
                            delay: 0,
                            controller: _controller,
                          ),
                          _ModernFeatureChip(
                            icon: Icons.map_outlined,
                            label: l10n.featureCitySearch,
                            delay: 0.1,
                            controller: _controller,
                          ),
                          _ModernFeatureChip(
                            icon: Icons.calendar_today_outlined,
                            label: l10n.feature15DayView,
                            delay: 0.2,
                            controller: _controller,
                          ),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      Container(
                        width: double.infinity,
                        height: r.h(58),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(r.r(20)),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFF8FAFC),
                              Color(0xFFE2E8F0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: widget.onNext,
                            borderRadius: BorderRadius.circular(r.r(20)),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.getStarted,
                                    style: TextStyle(
                                      fontSize: r.sp(17),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(width: r.w(8)),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: const Color(0xFF0F172A),
                                    size: r.w(20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      SizedBox(height: r.h(16)),
                      
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

class _ModernFeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double delay;
  final AnimationController controller;

  const _ModernFeatureChip({
    required this.icon,
    required this.label,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0), curve: Curves.easeOutBack),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final opacity = animation.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: (0.8 + (animation.value * 0.2)).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.w(14), vertical: r.h(10)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.12),
              Colors.white.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(r.r(16)),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(r.w(4)),
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withOpacity(0.2),
                borderRadius: BorderRadius.circular(r.r(8)),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2DD4BF),
                size: r.w(16),
              ),
            ),
            SizedBox(width: r.w(8)),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: r.sp(13),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
