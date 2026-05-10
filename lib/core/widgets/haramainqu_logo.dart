import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// HaramainQu Logo — Custom painted crescent moon + kaaba silhouette
class HaramainQuLogo extends StatelessWidget {
  final double size;
  const HaramainQuLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LogoPainter(),
      ),
    );
  }
}

/// Animated version for splash screen
class AnimatedHaramainQuLogo extends StatefulWidget {
  final double size;
  const AnimatedHaramainQuLogo({super.key, this.size = 130});

  @override
  State<AnimatedHaramainQuLogo> createState() => _AnimatedHaramainQuLogoState();
}

class _AnimatedHaramainQuLogoState extends State<AnimatedHaramainQuLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.15 * _glow.value),
                blurRadius: 40 * _glow.value,
                spreadRadius: 10 * _glow.value,
              ),
              BoxShadow(
                color: AppColors.accentTeal.withValues(alpha: 0.08 * _glow.value),
                blurRadius: 60 * _glow.value,
                spreadRadius: 15 * _glow.value,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _LogoPainter(glowIntensity: _glow.value),
          ),
        );
      },
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double glowIntensity;
  _LogoPainter({this.glowIntensity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ── Outer circle (border) ──────────────────────────────────────────────
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.accentLight, AppColors.accent, AppColors.accentDark],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 2, borderPaint);

    // ── Inner bg ───────────────────────────────────────────────────────────
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.3),
        colors: [
          AppColors.backgroundCard.withValues(alpha: 0.8),
          AppColors.backgroundPrimary.withValues(alpha: 0.95),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 3, bgPaint);

    // ── Crescent Moon ──────────────────────────────────────────────────────
    final moonPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final moonCenter = Offset(center.dx + radius * 0.05, center.dy - radius * 0.15);
    final moonRadius = radius * 0.35;
    final moonPath = Path();

    // Outer arc
    moonPath.addArc(
      Rect.fromCircle(center: moonCenter, radius: moonRadius),
      -pi * 0.6,
      pi * 1.6,
    );
    // Inner arc (cutout)
    final innerCenter = Offset(moonCenter.dx + moonRadius * 0.35, moonCenter.dy - moonRadius * 0.1);
    final innerRadius = moonRadius * 0.8;
    moonPath.arcTo(
      Rect.fromCircle(center: innerCenter, radius: innerRadius),
      pi * 1.0,
      -pi * 1.6,
      false,
    );
    moonPath.close();

    canvas.drawPath(moonPath, moonPaint);

    // ── Star near crescent ─────────────────────────────────────────────────
    final starCenter = Offset(
      moonCenter.dx + moonRadius * 0.6,
      moonCenter.dy - moonRadius * 0.3,
    );
    _drawStar(canvas, starCenter, radius * 0.06, moonPaint);

    // ── Kaaba silhouette ───────────────────────────────────────────────────
    final kaabaPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final kaabaWidth = radius * 0.35;
    final kaabaHeight = radius * 0.3;
    final kaabaTop = center.dy + radius * 0.15;
    final kaabaLeft = center.dx - kaabaWidth / 2;

    // Kaaba body
    final kaabaRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(kaabaLeft, kaabaTop, kaabaWidth, kaabaHeight),
      const Radius.circular(2),
    );
    canvas.drawRRect(kaabaRect, kaabaPaint);

    // Kiswah line (horizontal stripe)
    final stripePaint = Paint()
      ..color = AppColors.backgroundPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final stripeY = kaabaTop + kaabaHeight * 0.35;
    canvas.drawLine(
      Offset(kaabaLeft + 3, stripeY),
      Offset(kaabaLeft + kaabaWidth - 3, stripeY),
      stripePaint,
    );

    // Door
    final doorPaint = Paint()
      ..color = AppColors.backgroundPrimary
      ..style = PaintingStyle.fill;
    final doorW = kaabaWidth * 0.15;
    final doorH = kaabaHeight * 0.35;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - doorW / 2,
          kaabaTop + kaabaHeight - doorH - 2,
          doorW,
          doorH,
        ),
        const Radius.circular(1),
      ),
      doorPaint,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -pi / 2 + (2 * pi * i / 5);
      final innerAngle = -pi / 2 + (2 * pi * (i + 0.5) / 5);
      final outerPoint = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final innerPoint = Offset(
        center.dx + radius * 0.4 * cos(innerAngle),
        center.dy + radius * 0.4 * sin(innerAngle),
      );
      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) =>
      oldDelegate.glowIntensity != glowIntensity;
}
