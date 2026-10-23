import 'package:flutter/material.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../../shared/widgets/app_widgets.dart';

class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 104),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: context.colors.gold, size: 34),
            const SizedBox(height: 16),
            AppTitle(title),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: context.colors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
