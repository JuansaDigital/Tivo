import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/tivo_colors.dart';

class TivoScoreGauge extends StatelessWidget {
  final int score; // 0 - 1000
  final double size;

  const TivoScoreGauge({
    super.key,
    required this.score,
    this.size = 110.0,
  });

  Color get scoreColor {
    if (score >= 90) return TivoColors.accentNeonCyan;
    if (score >= 70) return TivoColors.primaryIceBlue;
    if (score >= 50) return TivoColors.statusWarningAmber;
    return TivoColors.statusExpenseRose;
  }

  String get scoreRating {
    if (score >= 90) return 'Excelente';
    if (score >= 70) return 'Saludable';
    if (score >= 50) return 'Precaución';
    return 'Crítico';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ScoreGaugePainter(
              progress: (score.clamp(0, 100) / 100).toDouble(),
              activeColor: scoreColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                scoreRating,
                style: TextStyle(
                  color: scoreColor,
                  fontSize: size * 0.10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreGaugePainter extends CustomPainter {
  final double progress;
  final Color activeColor;

  _ScoreGaugePainter({
    required this.progress,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - 14) / 2;
    const strokeWidth = 7.0;

    const startAngle = 0.75 * pi; // 135 deg
    const totalSweep = 1.5 * pi;  // 270 deg

    // Fondo del arco
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      totalSweep,
      false,
      bgPaint,
    );

    // Halo / Resplandor
    final glowPaint = Paint()
      ..color = activeColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..strokeCap = StrokeCap.round;

    final sweepAngle = totalSweep * progress;

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );

      // Arco Activo
      final activePaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + totalSweep,
          colors: [
            TivoColors.primaryIceBlue,
            activeColor,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        activePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.activeColor != activeColor;
  }
}
