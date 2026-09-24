import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.dark = false,
  });

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [
                  Color(0xFF0B1923),
                  Color(0xFF12312E),
                  Color(0xFF0C2528),
                ]
                    : const [
                  Color(0xFFFAF9F4),
                  Color(0xFFF0F6EF),
                  Color(0xFFF9F4E9),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _BackgroundPainter(dark: dark),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  const _BackgroundPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final accent = dark
        ? const Color(0xFFE9CF87)
        : const Color(0xFF5A917B);

    _drawGlow(
      canvas,
      center: Offset(size.width * 0.95, size.height * 0.12),
      radius: size.width * 0.85,
      color: accent.withValues(alpha: dark ? 0.10 : 0.15),
    );

    _drawGlow(
      canvas,
      center: Offset(size.width * 0.02, size.height * 0.85),
      radius: size.width * 0.72,
      color: (dark
          ? const Color(0xFF3B9B8A)
          : const Color(0xFFC0DCC4))
          .withValues(alpha: dark ? 0.11 : 0.30),
    );

    final patternPaint = Paint()
      ..color = accent.withValues(alpha: dark ? 0.16 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final patternRadius = math.min(size.width * 0.31, 145.0);

    _drawRosette(
      canvas,
      center: Offset(size.width * 0.94, size.height * 0.14),
      radius: patternRadius,
      paint: patternPaint,
    );

    _drawRosette(
      canvas,
      center: Offset(size.width * 0.02, size.height * 0.89),
      radius: patternRadius * 0.78,
      paint: patternPaint,
    );

    if (dark) {
      _drawSubtleStars(canvas, size);
    } else {
      _drawLightDots(canvas, size);
    }

    canvas.restore();
  }

  void _drawGlow(
      Canvas canvas, {
        required Offset center,
        required double radius,
        required Color color,
      }) {
    final bounds = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: 0),
        ],
      ).createShader(bounds);

    canvas.drawCircle(center, radius, paint);
  }

  void _drawRosette(
      Canvas canvas, {
        required Offset center,
        required double radius,
        required Paint paint,
      }) {
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.70, paint);

    final outer = Path();
    final inner = Path();

    for (var i = 0; i < 16; i++) {
      final angle = (i * math.pi / 8) - math.pi / 2;
      final outerDistance = i.isEven ? radius * 0.86 : radius * 0.46;
      final innerDistance = i.isEven ? radius * 0.60 : radius * 0.32;

      final outerPoint = Offset(
        center.dx + math.cos(angle) * outerDistance,
        center.dy + math.sin(angle) * outerDistance,
      );

      final innerPoint = Offset(
        center.dx + math.cos(angle) * innerDistance,
        center.dy + math.sin(angle) * innerDistance,
      );

      if (i == 0) {
        outer.moveTo(outerPoint.dx, outerPoint.dy);
        inner.moveTo(innerPoint.dx, innerPoint.dy);
      } else {
        outer.lineTo(outerPoint.dx, outerPoint.dy);
        inner.lineTo(innerPoint.dx, innerPoint.dy);
      }
    }

    outer.close();
    inner.close();

    canvas.drawPath(outer, paint);
    canvas.drawPath(inner, paint);
  }

  void _drawSubtleStars(Canvas canvas, Size size) {
    final random = math.Random(28);
    final paint = Paint();

    for (var i = 0; i < 58; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = i % 9 == 0 ? 1.2 : 0.55;

      paint.color = (i % 5 == 0
          ? const Color(0xFFE9CF87)
          : const Color(0xFFB7DDD1))
          .withValues(alpha: i % 9 == 0 ? 0.28 : 0.13);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _drawLightDots(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4B826E).withValues(alpha: 0.12);

    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 6; column++) {
        canvas.drawCircle(
          Offset(
            size.width * 0.09 + column * 31,
            size.height * 0.21 + row * 31,
          ),
          1.2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}