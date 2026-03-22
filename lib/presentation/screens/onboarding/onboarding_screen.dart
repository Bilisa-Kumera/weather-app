import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/city/city_bloc.dart';
import '../../bloc/onboarding/onboarding_bloc.dart';
import '../../widgets/onboarding/welcome_page.dart';
import '../../widgets/onboarding/city_select_page.dart';
import '../../../core/utils/responsive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  void _next() {
    if (_index < 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _back() {
    if (_index > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _finish() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final nav = Navigator.of(context, rootNavigator: true);
      final closed = await nav.maybePop();
      if (closed) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      if (!mounted) return;
      context.read<OnboardingBloc>().add(const FinishOnboarding());
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (value) => setState(() => _index = value),
                children: [
                  WelcomePage(onNext: _next),
                  CitySelectPage(onFinish: _finish, onBack: _back),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.w(24), vertical: r.h(10)),
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: r.h(6),
                      decoration: BoxDecoration(
                        color: _index == 0
                            ? Colors.white.withOpacity(0.65)
                            : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(r.r(12)),
                      ),
                    ),
                  ),
                  SizedBox(width: r.w(8)),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: r.h(6),
                      decoration: BoxDecoration(
                        color: _index == 1
                            ? Colors.white.withOpacity(0.65)
                            : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(r.r(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: r.h(10)),
          ],
        ),
      ),
    );
  }
}
