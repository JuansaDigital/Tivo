import 'package:flutter/material.dart';
import '../constants/tivo_colors.dart';
import '../constants/tivo_spacing.dart';

enum TivoButtonVariant {
  primary,
  secondary,
  glass,
  danger,
}

class TivoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final TivoButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;

  const TivoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = TivoButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height = 52.0,
  });

  @override
  Widget build(BuildContext context) {
    Color getBgColor() {
      switch (variant) {
        case TivoButtonVariant.primary:
          return TivoColors.primaryIceBlue;
        case TivoButtonVariant.secondary:
          return TivoColors.accentElectricCyan;
        case TivoButtonVariant.glass:
          return TivoColors.bgSurfaceGlassLight;
        case TivoButtonVariant.danger:
          return TivoColors.statusExpenseRose;
      }
    }

    Color getTextColor() {
      switch (variant) {
        case TivoButtonVariant.primary:
        case TivoButtonVariant.secondary:
          return const Color(0xFF070E22);
        case TivoButtonVariant.glass:
          return TivoColors.textPrimary;
        case TivoButtonVariant.danger:
          return Colors.white;
      }
    }

    final bool isGlass = variant == TivoButtonVariant.glass;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
        boxShadow: variant == TivoButtonVariant.primary
            ? [
                BoxShadow(
                  color: TivoColors.primaryIceBlue.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBgColor(),
          foregroundColor: getTextColor(),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
            side: isGlass
                ? BorderSide(
                    color: Colors.white.withOpacity(0.18),
                    width: 1.0,
                  )
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: getTextColor(),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: getTextColor()),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: getTextColor(),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
