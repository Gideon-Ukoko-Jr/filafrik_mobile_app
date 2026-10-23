import 'package:flutter/material.dart';

import '../../../core/app_color_scheme.dart';

class Splitter extends StatelessWidget {
  const Splitter({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.colors.gold.withValues(alpha: .25))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'or',
            style: TextStyle(color: context.colors.dim, fontSize: 11),
          ),
        ),
        Expanded(child: Divider(color: context.colors.gold.withValues(alpha: .25))),
      ],
    );
  }
}

class PageDots extends StatelessWidget {
  const PageDots({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Dot(width: 24, active: true), Dot(), Dot()],
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({super.key, this.width = 8, this.active = false});

  final double width;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: active ? context.colors.gold : context.colors.gold.withValues(alpha: .3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class DividerMark extends StatelessWidget {
  const DividerMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 1,
      color: context.colors.gold.withValues(alpha: .65),
    );
  }
}

class GlowCircle extends StatelessWidget {
  const GlowCircle({
    super.key,
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

class Ring extends StatelessWidget {
  const Ring({
    super.key,
    required this.size,
    required this.color,
    required this.width,
  });

  final double size;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: width),
      ),
    );
  }
}
