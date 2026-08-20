import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/tivo_colors.dart';
import '../constants/tivo_spacing.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Gradient? borderGradient;
  final double borderWidth;
  final VoidCallback? onTap;
  final BoxShadow? extraShadow;
  final bool hasGlow;
  final Color glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = TivoSpacing.radiusLg,
    this.padding = TivoSpacing.cardPadding,
    this.margin,
    this.blur = 20.0,
    this.backgroundColor,
    this.backgroundGradient,
    this.borderGradient,
    this.borderWidth = 1.0,
    this.onTap,
    this.extraShadow,
    this.hasGlow = false,
    this.glowColor = TivoColors.primaryIceBlue,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderGradient = borderGradient ??
        const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TivoColors.glassBorderStart,
            TivoColors.glassBorderEnd,
          ],
          stops: [0.0, 1.0],
        );

    final cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          if (hasGlow)
            BoxShadow(
              color: glowColor.withOpacity(0.18),
              blurRadius: 28,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
          ?extraShadow,
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: CustomPaint(
            painter: _GradientBorderPainter(
              gradient: effectiveBorderGradient,
              borderRadius: borderRadius,
              strokeWidth: borderWidth,
            ),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundGradient == null
                    ? (backgroundColor ?? TivoColors.bgSurfaceGlass)
                    : null,
                gradient: backgroundGradient,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: TivoColors.primaryIceBlue.withOpacity(0.12),
          highlightColor: Colors.transparent,
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

class _GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final double borderRadius;
  final double strokeWidth;

  _GradientBorderPainter({
    required this.gradient,
    required this.borderRadius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius - (strokeWidth / 2)),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter oldDelegate) {
    return oldDelegate.borderRadius != borderRadius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradient != gradient;
  }
}
