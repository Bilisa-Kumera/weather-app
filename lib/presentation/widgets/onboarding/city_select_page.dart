import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/responsive.dart';
import '../../../domain/entities/city.dart';
import '../../bloc/city/city_bloc.dart';
import '../common/city_dropdown.dart';
import '../common/gradient_background.dart';

class CitySelectPage extends StatelessWidget {
  const CitySelectPage({super.key, required this.onFinish, required this.onBack});

  final VoidCallback onFinish;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return GradientBackground(
      colors: const [Color(0xFF111827), Color(0xFF1D4ED8), Color(0xFF0F766E)],
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(r.w(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(r.r(14)),
                    ),
                    child: IconButton(
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ),
                  SizedBox(width: r.w(12)),
                  Text(
                    'Bakki Keessan',
                    style: TextStyle(
                      fontSize: r.sp(17),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.h(26)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(r.w(20)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(r.r(24)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.24),
                      Colors.white.withOpacity(0.08),
                    ],
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eessa jirta?',
                      style: TextStyle(
                        fontSize: r.sp(28),
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.05,
                      ),
                    ),
                    SizedBox(height: r.h(8)),
                    Text(
                      'Haala qilleensaa yeroo ammaa fi tilmaama fuulduraa argachuuf magaalaa kee barbaadi.',
                      style: TextStyle(
                        fontSize: r.sp(13),
                        color: Colors.white.withOpacity(0.84),
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: r.h(16)),
                    CityDropdown(
                      onSelected: (City city) {
                        context.read<CityBloc>().add(SelectCity(city));
                      },
                    ),
                    SizedBox(height: r.h(16)),
                    BlocBuilder<CityBloc, CityState>(
                      builder: (context, state) {
                        final selected = state.selectedCity;
                        final enabled = selected != null;
                        return SizedBox(
                          width: double.infinity,
                          height: r.h(50),
                          child: ElevatedButton(
                            onPressed: enabled
                                ? () async {
                                    FocusScope.of(context).unfocus();
                                    final nav = Navigator.of(context, rootNavigator: true);
                                    final closed = await nav.maybePop();
                                    if (closed) {
                                      await Future.delayed(const Duration(milliseconds: 200));
                                    }
                                    onFinish();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: enabled
                                  ? const Color(0xFFF8FAFC)
                                  : Colors.white.withOpacity(0.28),
                              foregroundColor: enabled
                                  ? const Color(0xFF0F172A)
                                  : Colors.white.withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(r.r(16)),
                              ),
                              elevation: enabled ? 10 : 0,
                            ),
                            child: Text(
                              enabled ? 'Gara Fuula Ijoo Itti Fufi' : 'Jalqaba magaalaa filadhu',
                              style: TextStyle(fontSize: r.sp(14), fontWeight: FontWeight.w700),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Hubachiisa: Booda keessaa Qindaa\'ina irraa jijjiiruu dandeessa.',
                style: TextStyle(
                  fontSize: r.sp(12),
                  color: Colors.white.withOpacity(0.72),
                ),
              ),
              SizedBox(height: r.h(10)),
            ],
          ),
        ),
      ),
    );
  }
}
