import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';
import '../../widgets/common/gradient_background.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return GradientBackground(
      colors: const [Color(0xFF0B1026), Color(0xFF1E3A8A), Color(0xFF0EA5A8)],
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.w(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: r.h(24)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(r.w(22)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r.r(28)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.22),
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 26,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: r.w(108),
                      height: r.w(108),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFFBEB),
                        border: Border.all(color: const Color(0xFFFACC15), width: 2),
                      ),
                      child: Icon(
                        Icons.wb_sunny_rounded,
                        size: r.w(58),
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                    SizedBox(height: r.h(18)),
                    Text(
                      'Guyyaa Kee\nHaala Qilleensaan Karoorfadhu',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: r.sp(30),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.08,
                      ),
                    ),
                    SizedBox(height: r.h(10)),
                    Text(
                      'Tilmaama saffisaa, odeeffannoo ifaa fi fuula murtii saffisaa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: r.sp(14),
                        color: Colors.white.withOpacity(0.82),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.h(22)),
              Wrap(
                spacing: r.w(10),
                runSpacing: r.h(10),
                children: const [
                  _FeatureChip(icon: Icons.bolt_rounded, label: 'Haaromsa yeroo'),
                  _FeatureChip(icon: Icons.map_outlined, label: 'Barbaacha magaalaa'),
                  _FeatureChip(icon: Icons.calendar_today_outlined, label: 'Mul\'ata guyyaa 15'),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: r.h(54),
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8FAFC),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r.r(18)),
                    ),
                    elevation: 12,
                    shadowColor: const Color(0xFF0F172A).withOpacity(0.45),
                  ),
                  child: Text(
                    'Jalqabi',
                    style: TextStyle(fontSize: r.sp(16), fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(height: r.h(12)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(9)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(r.r(14)),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFFDE047), size: r.w(16)),
          SizedBox(width: r.w(6)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: r.sp(12),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
