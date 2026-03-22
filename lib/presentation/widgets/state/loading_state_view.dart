import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/utils/responsive.dart';

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(r.w(20)),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.08),
              highlightColor: Colors.white.withOpacity(0.24),
              period: const Duration(milliseconds: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBox(r, height: r.h(24), width: r.w(150), radius: 12),
                  SizedBox(height: r.h(18)),
                  _skeletonBox(r, height: r.h(210), width: double.infinity, radius: 26),
                  SizedBox(height: r.h(16)),
                  Row(
                    children: [
                      Expanded(child: _skeletonBox(r, height: r.h(96), width: double.infinity, radius: 18)),
                      SizedBox(width: r.w(10)),
                      Expanded(child: _skeletonBox(r, height: r.h(96), width: double.infinity, radius: 18)),
                      SizedBox(width: r.w(10)),
                      Expanded(child: _skeletonBox(r, height: r.h(96), width: double.infinity, radius: 18)),
                    ],
                  ),
                  SizedBox(height: r.h(18)),
                  _skeletonBox(r, height: r.h(22), width: r.w(170), radius: 12),
                  SizedBox(height: r.h(12)),
                  SizedBox(
                    height: r.h(140),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      separatorBuilder: (_, __) => SizedBox(width: r.w(10)),
                      itemBuilder: (_, __) => _skeletonBox(
                        r,
                        height: r.h(140),
                        width: r.w(110),
                        radius: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: r.h(18)),
                  Center(
                    child: Text(
                      message ?? 'Odeeffannoo haala qilleensaa fe\'aa jira...',
                      style: TextStyle(
                        fontSize: r.sp(13),
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _skeletonBox(
    Responsive r, {
    required double height,
    required double width,
    required double radius,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.r(radius)),
      ),
    );
  }
}
