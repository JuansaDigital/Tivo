import 'package:flutter/material.dart';
import '../constants/tivo_colors.dart';

class TivoLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const TivoLogo({
    super.key,
    this.size = 120,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showGlow)
            Container(
              width: size * 0.75,
              height: size * 0.75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TivoColors.accentElectricCyan.withOpacity(0.35),
                    blurRadius: size * 0.35,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.25),
                    blurRadius: size * 0.45,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          CustomPaint(
            size: Size(size, size),
            painter: _TivoRibbonPainter(),
          ),
        ],
      ),
    );
  }
}

class _TivoRibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = w * 0.135;

    // 1. Sombra / Resplandor de trazo
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = TivoColors.accentElectricCyan.withOpacity(0.4);

    // 2. Trazo Principal Degradado (Cyan Eléctrico -> Azul Real)
    final mainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF00F5FF), // Electric Cyan
          Color(0xFF38BDF8), // Ice Blue
          Color(0xFF2563EB), // Royal Blue
          Color(0xFF1D4ED8), // Deep Blue
        ],
        stops: [0.0, 0.35, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // 3. Highlight Brillante Superior (Cinta 3D)
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.28
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.9),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.5));

    // Construcción del Camino (Path) de la cinta 'T'
    final path = Path();

    // Brazo Izquierdo Superior -> Curva hacia abajo
    final leftX = w * 0.20;
    final rightX = w * 0.80;
    final topY = h * 0.26;
    final stemX = w * 0.50;
    final bottomY = h * 0.82;

    // Empezamos en el brazo izquierdo
    path.moveTo(leftX, topY);
    
    // Barra superior hasta el centro y curva hacia abajo
    path.lineTo(w * 0.42, topY);
    
    // Curva fluida hacia el tronco vertical
    path.cubicTo(
      w * 0.48, topY,
      stemX - w * 0.04, h * 0.35,
      stemX - w * 0.04, h * 0.48,
    );

    // Tronco hacia abajo
    path.lineTo(stemX - w * 0.04, bottomY - h * 0.08);

    // Bucle inferior redondeado
    path.cubicTo(
      stemX - w * 0.04, bottomY,
      stemX + w * 0.04, bottomY,
      stemX + w * 0.04, bottomY - h * 0.08,
    );

    // Tronco subiendo hacia el brazo derecho
    path.lineTo(stemX + w * 0.04, h * 0.48);

    // Curva hacia el brazo derecho
    path.cubicTo(
      stemX + w * 0.04, h * 0.35,
      w * 0.52, topY,
      w * 0.58, topY,
    );

    // Barra superior derecha
    path.lineTo(rightX, topY);

    // Dibujar Glow
    canvas.drawPath(path, glowPaint);

    // Dibujar Cinta Principal
    canvas.drawPath(path, mainPaint);

    // Dibujar Detalle de brillo 3D
    canvas.drawPath(path, highlightPaint);

    // Segundo bucle superior que cierra la forma de cinta infinita 'T'
    final topLoopPath = Path();
    topLoopPath.moveTo(leftX, topY);
    topLoopPath.cubicTo(
      leftX - w * 0.06, topY - h * 0.06,
      leftX + w * 0.12, topY - h * 0.10,
      stemX, topY - h * 0.06,
    );
    topLoopPath.cubicTo(
      rightX - w * 0.12, topY - h * 0.10,
      rightX + w * 0.06, topY - h * 0.06,
      rightX, topY,
    );

    final topLoopPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.9
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF00F5FF),
          Color(0xFF2563EB),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawPath(topLoopPath, glowPaint);
    canvas.drawPath(topLoopPath, topLoopPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
