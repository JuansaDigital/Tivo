import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../accounts/data/account_provider.dart';
import '../../../accounts/domain/models/account_model.dart';
import '../../../accounts/presentation/account_form_modal.dart';
import '../../data/metrics_provider.dart';

class WalletCarousel extends ConsumerWidget {
  final VoidCallback onAddAccount;

  const WalletCarousel({
    super.key,
    required this.onAddAccount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountListProvider);
    final isPrivacy = ref.watch(privacyModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mis Instrumentos & Cuentas',
                style: TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: onAddAccount,
                child: const Row(
                  children: [
                    Icon(LucideIcons.plus, size: 14, color: TivoColors.primaryIceBlue),
                    SizedBox(width: 4),
                    Text(
                      'Agregar',
                      style: TextStyle(
                        color: TivoColors.primaryIceBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 145,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: accounts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final acc = accounts[index];
              final isCredit = acc.type == AccountType.creditCard;

              return SizedBox(
                width: 280,
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: TivoSpacing.radiusLg,
                  hasGlow: isCredit,
                  glowColor: isCredit ? TivoColors.accentPurple : TivoColors.primaryIceBlue,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AccountFormModal(accountToEdit: acc),
                    );
                  },
                  backgroundGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isCredit
                        ? [
                            const Color(0x33818CF8),
                            const Color(0x1F06B6D4),
                            const Color(0x281C2541),
                          ]
                        : [
                            const Color(0x3338BDF8),
                            const Color(0x1A06B6D4),
                            const Color(0x281C2541),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(acc.type.icon, size: 16, color: acc.type.color),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    acc.institutionName,
                                    style: const TextStyle(
                                      color: TivoColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (acc.isGMFExempt)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: TivoColors.statusIncomeGreen.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: TivoColors.statusIncomeGreen.withOpacity(0.4)),
                              ),
                              child: const Text(
                                'Exenta 4x1000',
                                style: TextStyle(
                                  color: TivoColors.statusIncomeGreenLight,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else if (isCredit)
                            Text(
                              'Corte día ${acc.cutOffDay}',
                              style: const TextStyle(
                                color: TivoColors.textTertiary,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            acc.name,
                            style: const TextStyle(
                              color: TivoColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPrivacy
                                ? '••••••••'
                                : (isCredit
                                    ? 'Consumo: ${CurrencyFormatter.formatCOP(acc.balance)}'
                                    : CurrencyFormatter.formatCOP(acc.balance)),
                            style: TextStyle(
                              color: isCredit ? TivoColors.statusExpenseRoseLight : TivoColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              acc.accountNumberMasked,
                              style: const TextStyle(
                                color: TivoColors.textTertiary,
                                fontSize: 11,
                                letterSpacing: 1.1,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCredit)
                            Text(
                              isPrivacy ? 'Disp: •••' : 'Cupo: ${CurrencyFormatter.formatCompact(acc.availableCredit)}',
                              style: const TextStyle(
                                color: TivoColors.accentNeonCyan,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
