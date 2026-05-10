import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Paints a subtle Islamic geometric star pattern as background decoration.
class IslamicPatternPainter extends CustomPainter {
  final double opacity;
  final Color color;

  const IslamicPatternPainter({
    this.opacity = 0.06,
    this.color = AppColors.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    const cellSize = 80.0;
    final cols = (size.width / cellSize).ceil() + 2;
    final rows = (size.height / cellSize).ceil() + 2;

    for (var row = -1; row < rows; row++) {
      for (var col = -1; col < cols; col++) {
        final cx = col * cellSize + (row.isOdd ? cellSize / 2 : 0);
        final cy = row * cellSize * 0.866;
        _drawStar(canvas, paint, Offset(cx, cy), cellSize * 0.4);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    const points = 8;
    const innerFactor = 0.4;
    final path = Path();

    for (var i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? radius : radius * innerFactor;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw outer hexagon ring
    final hexPath = Path();
    for (var i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) - math.pi / 6;
      final x = center.dx + radius * 1.1 * math.cos(angle);
      final y = center.dy + radius * 1.1 * math.sin(angle);
      if (i == 0) {
        hexPath.moveTo(x, y);
      } else {
        hexPath.lineTo(x, y);
      }
    }
    hexPath.close();
    canvas.drawPath(hexPath, paint);
  }

  @override
  bool shouldRepaint(IslamicPatternPainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.color != color;
}

/// Paints a Kaaba silhouette hint at the bottom of the screen.
class KaabaHintPainter extends CustomPainter {
  final double opacity;

  const KaabaHintPainter({this.opacity = 0.04});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Kaaba cube body
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.7),
        width: size.width * 0.45,
        height: size.height * 0.35,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(body, paint);

    // Kiswah band (slightly lighter gold stripe)
    paint.color = AppColors.accentLight.withValues(alpha: opacity * 1.5);
    final band = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.62),
      width: size.width * 0.45,
      height: size.height * 0.04,
    );
    canvas.drawRect(band, paint);
  }

  @override
  bool shouldRepaint(KaabaHintPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
