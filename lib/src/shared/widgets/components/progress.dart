import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class ProgressBars extends StatelessWidget {
  const ProgressBars({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final active = index < step;
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: index == 3 ? 0 : 4),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.gold
                  : AppColors.gold.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
