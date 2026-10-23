import 'package:flutter/material.dart';

import '../../../core/app_color_scheme.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.accent = false});

  final Widget child;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.colors.gold.withValues(alpha: accent ? .35 : .18),
        ),
      ),
      child: Stack(
        children: [
          if (accent)
            const Positioned(top: 0, left: 0, right: 0, child: AccentStripe()),
          Padding(padding: const EdgeInsets.all(13), child: child),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [context.colors.forest, context.colors.green],
        ),
        border: Border.all(
          color: context.colors.gold.withValues(alpha: .35),
          width: 1.5,
        ),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: context.colors.text,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AccentStripe extends StatelessWidget {
  const AccentStripe({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.forest, context.colors.gold, context.colors.forest],
        ),
      ),
    );
  }
}
