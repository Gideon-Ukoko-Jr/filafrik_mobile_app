import 'package:flutter/material.dart';

import '../../../core/app_colors.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.background),
        child: Stack(
          children: [
            const Positioned(top: 0, left: 0, right: 0, child: TopStripe()),
            Positioned.fill(child: child),
          ],
        ),
      ),
    );
  }
}

class TopStripe extends StatelessWidget {
  const TopStripe({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.red,
            AppColors.gold,
            AppColors.lightGold,
            AppColors.gold,
            AppColors.red,
          ],
        ),
      ),
    );
  }
}
