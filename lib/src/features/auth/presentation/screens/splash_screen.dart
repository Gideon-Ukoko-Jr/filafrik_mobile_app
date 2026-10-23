import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/app_color_scheme.dart';
import '../../../../shared/widgets/app_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  var _finished = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _finish);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _finish() {
    if (_finished || !mounted) {
      return;
    }
    _finished = true;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: InkWell(
        onTap: _finish,
        child: Stack(
          children: [
            Positioned(
              top: -72,
              right: -78,
              child: GlowCircle(
                size: 250,
                color: context.colors.lightGold,
                opacity: .07,
              ),
            ),
            Positioned(
              bottom: -62,
              left: -62,
              child: GlowCircle(size: 210, color: context.colors.red, opacity: .10),
            ),
            Positioned(
              top: 330,
              left: -28,
              child: GlowCircle(size: 96, color: context.colors.gold, opacity: .14),
            ),
            Center(
              child: SizedBox(
                width: 278,
                height: 278,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Ring(
                      size: 272,
                      color: context.colors.gold.withValues(alpha: .18),
                      width: 1,
                    ),
                    Ring(
                      size: 252,
                      color: context.colors.gold.withValues(alpha: .45),
                      width: 1.5,
                    ),
                    Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.gold.withValues(alpha: .04),
                        border: Border.all(
                          color: context.colors.lightGold.withValues(alpha: .10),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'FILAFRIK',
                            style: TextStyle(
                              color: context.colors.gold,
                              fontSize: 12,
                              letterSpacing: 2.4,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'THE AFRICAN EXPERIENCE',
                            style: TextStyle(
                              color: context.colors.muted,
                              fontSize: 8.5,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const DividerMark(),
                          const SizedBox(height: 5),
                          Text(
                            'FOUNDERS CIRCLE',
                            style: TextStyle(
                              color: context.colors.muted,
                              fontSize: 10,
                              letterSpacing: 2.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const DividerMark(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 58,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: context.colors.gold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
