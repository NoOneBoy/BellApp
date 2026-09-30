import 'dart:math' as math;

import 'package:flutter/material.dart';

class BellVisual extends StatelessWidget {
  const BellVisual({
    super.key,
    required this.swing,
    this.size = 280,
  });

  final double swing;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: swing,
      alignment: const Alignment(0, -0.85),
      child: CustomPaint(
        size: Size.square(size),
        painter: BellPainter(clapper: swing * 1.35),
      ),
    );
  }
}

class BellPainter extends CustomPainter {
  BellPainter({required this.clapper});

  final double clapper;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final top = size.height * 0.08;
    final bodyTop = size.height * 0.18;
    final bodyBottom = size.height * 0.78;
    final rimY = size.height * 0.82;

    final gold = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF6D889), Color(0xFFC7922C), Color(0xFF8A5A12)],
      ).createShader(Offset.zero & size);

    final darkGold = Paint()
      ..color = const Color(0xFF5C3B0E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.018
      ..strokeCap = StrokeCap.round;

    final highlight = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.center,
        colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(size.width * 0.2, bodyTop, size.width * 0.35, size.height * 0.4));

    final capRect = Rect.fromCenter(
      center: Offset(cx, top + size.height * 0.05),
      width: size.width * 0.18,
      height: size.height * 0.1,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(capRect, const Radius.circular(8)),
      gold,
    );

    final path = Path()
      ..moveTo(cx - size.width * 0.16, bodyTop)
      ..quadraticBezierTo(
        cx - size.width * 0.42,
        bodyTop + (bodyBottom - bodyTop) * 0.45,
        cx - size.width * 0.46,
        bodyBottom,
      )
      ..quadraticBezierTo(cx, rimY + size.height * 0.04, cx + size.width * 0.46, bodyBottom)
      ..quadraticBezierTo(
        cx + size.width * 0.42,
        bodyTop + (bodyBottom - bodyTop) * 0.45,
        cx + size.width * 0.16,
        bodyTop,
      )
      ..close();
    canvas.drawPath(path, gold);
    canvas.drawPath(path, darkGold);
    canvas.drawPath(path, highlight);

    final lip = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(cx, bodyBottom + size.height * 0.015),
          width: size.width * 0.94,
          height: size.height * 0.08,
        ),
      );
    canvas.drawPath(
      lip,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE8C56B), Color(0xFF9A6B1A)],
        ).createShader(Offset.zero & size),
    );

    canvas.save();
    canvas.translate(cx + clapper * size.width * 0.35, bodyTop + size.height * 0.12);
    canvas.rotate(clapper * 0.8);
    final clapperPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD8D8D8), Color(0xFF6E6E6E)],
      ).createShader(Rect.fromLTWH(-10, 0, 20, size.height * 0.5));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, size.height * 0.22), width: size.width * 0.045, height: size.height * 0.38),
        const Radius.circular(8),
      ),
      clapperPaint,
    );
    canvas.drawCircle(Offset(0, size.height * 0.44), size.width * 0.07, clapperPaint);
    canvas.restore();

    final spark = Paint()
      ..color = const Color(0xFFFFF3C4).withValues(alpha: 0.35 + 0.25 * math.cos(clapper * 8).abs())
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(cx, bodyTop + size.height * 0.22), size.width * 0.12, spark);
  }

  @override
  bool shouldRepaint(covariant BellPainter oldDelegate) => oldDelegate.clapper != clapper;
}
