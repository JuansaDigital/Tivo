import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

class QuickActionsRow extends StatelessWidget {
  final VoidCallback onAddTransaction;
  final VoidCallback onOpenCDTSimulator;
  final VoidCallback onOpenImpulseCooler;

  const QuickActionsRow({
    super.key,
    required this.onAddTransaction,
    required this.onOpenCDTSimulator,
    required this.onOpenImpulseCooler,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionItem(
          label: 'Registrar',
          subLabel: 'Gasto / Ingreso',
          icon: LucideIcons.plusCircle,
          accentColor: TivoColors.primaryIceBlue,
          onTap: onAddTransaction,
        ),
        const SizedBox(width: 10),
        _ActionItem(
          label: 'Simular CDT',
          subLabel: 'Tasa Real',
          icon: LucideIcons.calculator,
          accentColor: TivoColors.accentElectricCyan,
          onTap: onOpenCDTSimulator,
        ),
        const SizedBox(width: 10),
        _ActionItem(
          label: 'Enfriador',
          subLabel: 'Neuro-impulso',
          icon: LucideIcons.snowflake,
          accentColor: TivoColors.accentPurple,
          onTap: onOpenImpulseCooler,
        ),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  final String label;
  final String subLabel;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _ActionItem({
    required this.label,
    required this.subLabel,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        borderRadius: TivoSpacing.radiusMd,
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 18, color: accentColor),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: TivoColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              style: const TextStyle(
                color: TivoColors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
