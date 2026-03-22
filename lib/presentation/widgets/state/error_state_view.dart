import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(r.w(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: r.w(64), color: Colors.grey.shade500),
              SizedBox(height: r.h(16)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: r.sp(14), color: Colors.grey.shade600),
              ),
              SizedBox(height: r.h(20)),
              SizedBox(
                width: r.w(160),
                height: r.h(44),
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(r.r(16)),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
