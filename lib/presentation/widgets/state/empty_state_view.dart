import 'package:flutter/material.dart';

import '../../../core/utils/responsive.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(r.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: r.w(56), color: Colors.grey.shade500),
            SizedBox(height: r.h(12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: r.sp(14), color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
