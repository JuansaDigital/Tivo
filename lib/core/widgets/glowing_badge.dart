import 'package:flutter/material.dart';
import '../constants/tivo_colors.dart';
import '../constants/tivo_spacing.dart';

class GlowingBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final bool isGlowing;
  final VoidCallback? onTap;

  const GlowingBadge({
    super.key,
    required this.text,
    this.icon,
    this.color = TivoColors.accentElectricCyan,
    this.isGlowing = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
        border: Border.all(
          color: color.withOpacity(0.35),
          width: 1.0,
        ),
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: color.withOpacity(0.20),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }

    return badge;
  }
}
