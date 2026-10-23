import 'package:flutter/material.dart';

import '../../../core/app_color_scheme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: DecoratedBox(
        decoration: BoxDecoration(color: context.colors.background),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.red,
            context.colors.gold,
            context.colors.lightGold,
            context.colors.gold,
            context.colors.red,
          ],
        ),
      ),
    );
  }
}
