import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';

class KPICardsRow extends StatelessWidget {
  final double income;
  final double expenses;
  final double savings;
  final bool isPrivacy;
  final VoidCallback? onTapIncome;
  final VoidCallback? onTapExpenses;
  final VoidCallback? onTapSavings;

  const KPICardsRow({
    super.key,
    required this.income,
    required this.expenses,
    required this.savings,
    required this.isPrivacy,
    this.onTapIncome,
    this.onTapExpenses,
    this.onTapSavings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _KPICard(
          title: 'Ingresos',
          amount: income,
          icon: LucideIcons.arrowDownLeft,
          color: TivoColors.statusIncomeGreen,
          isPrivacy: isPrivacy,
          onTap: onTapIncome,
        ),
        const SizedBox(width: 8),
        _KPICard(
          title: 'Gastos',
          amount: expenses,
          icon: LucideIcons.arrowUpRight,
          color: TivoColors.statusExpenseRose,
          isPrivacy: isPrivacy,
          onTap: onTapExpenses,
        ),
        const SizedBox(width: 8),
        _KPICard(
          title: 'Ahorro',
          amount: savings,
          icon: LucideIcons.piggyBank,
          color: TivoColors.primaryIceBlue,
          isPrivacy: isPrivacy,
          onTap: onTapSavings,
        ),
      ],
    );
  }
}

class _KPICard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isPrivacy;
  final VoidCallback? onTap;

  const _KPICard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isPrivacy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        borderRadius: TivoSpacing.radiusMd,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 14, color: color),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: TivoColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isPrivacy ? '••••••' : CurrencyFormatter.formatCompact(amount),
              style: const TextStyle(
                color: TivoColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
