import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.dark = false});

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
                        Color(0xFF102F2B),
                        Color(0xFF17483F),
                        Color(0xFF0B2926),
                      ]
                    : const [
                        Color(0xFFF9F7F0),
                        Color(0xFFF0F6EF),
                        Color(0xFFF9F3E8),
                      ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _BackgroundPainter(dark: dark)),
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
    canvas.clipRect(Offset.zero & size);

    final glowColor = dark ? const Color(0xFFE8D69A) : const Color(0xFFB7D9BC);
    final patternColor = dark
        ? const Color(0xFFE8D69A)
        : const Color(0xFF477E6B);

    _drawGlow(
      canvas,
      Offset(size.width * 0.92, size.height * 0.12),
      size.width * 0.8,
      glowColor.withValues(alpha: dark ? 0.12 : 0.28),
    );

    _drawGlow(
      canvas,
      Offset(size.width * 0.05, size.height * 0.88),
      size.width * 0.7,
      glowColor.withValues(alpha: dark ? 0.07 : 0.17),
    );

    final linePaint = Paint()
      ..color = patternColor.withValues(alpha: dark ? 0.19 : 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final radius = math.min(size.width * 0.31, 145.0);

    _drawRosette(
      canvas,
      Offset(size.width * 0.91, size.height * 0.13),
      radius,
      linePaint,
    );

    _drawRosette(
      canvas,
      Offset(size.width * 0.04, size.height * 0.88),
      radius * 0.82,
      linePaint,
    );

    final dotPaint = Paint()
      ..color = patternColor.withValues(alpha: dark ? 0.20 : 0.14);

    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 6; column++) {
        canvas.drawCircle(
          Offset(
            size.width * 0.10 + column * 31,
            size.height * 0.19 + row * 31,
          ),
          1.3,
          dotPaint,
        );
      }
    }
  }

  void _drawGlow(Canvas canvas, Offset center, double radius, Color color) {
    final bounds = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
      ).createShader(bounds);

    canvas.drawCircle(center, radius, paint);
  }

  void _drawRosette(Canvas canvas, Offset center, double radius, Paint paint) {
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.72, paint);

    final path = Path();

    for (var point = 0; point < 16; point++) {
      final angle = point * math.pi / 8 - math.pi / 2;
      final distance = point.isEven ? radius * 0.88 : radius * 0.48;

      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      if (point == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.dark != dark;
  }
}
