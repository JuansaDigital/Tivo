import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../transactions/data/transaction_provider.dart';
import '../../transactions/presentation/add_transaction_modal.dart';
import '../data/metrics_provider.dart';
import 'widgets/cashflow_chart.dart';
import 'widgets/daily_tip_card.dart';
import 'widgets/immediate_alert_banner.dart';
import 'widgets/kpi_cards_row.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/wallet_carousel.dart';
import '../../../core/providers/profile_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../accounts/presentation/account_form_modal.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(financialMetricsProvider);
    final transactions = ref.watch(transactionListProvider);
    final isPrivacy = ref.watch(privacyModeProvider);
    final profile = ref.watch(userProfileProvider);
    final greetingName = profile.firstName.isNotEmpty ? profile.firstName : 'Usuario';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: 120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Encabezado y Balance Patrimonial Neto (Módulo 1.1)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: profile.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: profile.gradientColors.first.withOpacity(0.35),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              profile.iconData,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, $greetingName 👋',
                              style: const TextStyle(
                                color: TivoColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Text(
                              'Control Patrimonial 360°',
                              style: TextStyle(
                                color: TivoColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  Row(
                    children: [
                      // Botón Modo Oculto / Privacidad (Módulo 1.1)
                      IconButton(
                        onPressed: () {
                          ref.read(privacyModeProvider.notifier).state = !isPrivacy;
                        },
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isPrivacy
                                ? TivoColors.primaryIceBlue.withOpacity(0.2)
                                : Colors.white.withOpacity(0.06),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isPrivacy
                                  ? TivoColors.primaryIceBlue
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Icon(
                            isPrivacy ? LucideIcons.eyeOff : LucideIcons.eye,
                            size: 18,
                            color: isPrivacy
                                ? TivoColors.primaryIceBlue
                                : TivoColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(
                          LucideIcons.bell,
                          size: 18,
                          color: TivoColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              ),
              const SizedBox(height: 18),

              // Tarjeta Hero: Balance Total Global + Rendimiento Mensual (Módulo 1.1)
              GlassCard(
                hasGlow: true,
                glowColor: TivoColors.primaryIceBlue,
                backgroundGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x3338BDF8),
                    Color(0x1F06B6D4),
                    Color(0x281C2541),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'BALANCE TOTAL NETO',
                          style: TextStyle(
                            color: TivoColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPrivacy
                          ? '••••••••••••'
                          : CurrencyFormatter.formatCOP(metrics.netWorth),
                      style: const TextStyle(
                        color: TivoColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isPrivacy
                                ? 'Activos: •••'
                                : 'Activos: ${CurrencyFormatter.formatCOP(metrics.totalLiquidCash)}',
                            style: const TextStyle(
                              color: TivoColors.accentNeonCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            isPrivacy
                                ? 'Deudas: •••'
                                : 'Deudas: ${CurrencyFormatter.formatCOP(metrics.totalDebt)}',
                            style: const TextStyle(
                              color: TivoColors.statusExpenseRoseLight,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 5. Widget de Alertas Inmediatas (Módulo 1.5)
              ImmediateAlertBanner(
                onTap: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(2); // Pestaña Recordatorios
                  }
                },
              ),
              const SizedBox(height: 16),

              // 2. Carrusel Glassmorphic de Instrumentos Financieros (Módulo 1.2)
              WalletCarousel(
                onAddAccount: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AccountFormModal(),
                  );
                },
              ),
              const SizedBox(height: 18),

              // 3. Métricas Clave del Mes - KPI Cards (Módulo 1.3)
              KPICardsRow(
                income: metrics.monthlyIncome,
                expenses: metrics.monthlyExpenses,
                savings: metrics.safeToSpendMonth,
                isPrivacy: isPrivacy,
                onTapIncome: () => onNavigateTab?.call(1),
                onTapExpenses: () => onNavigateTab?.call(1),
                onTapSavings: () => onNavigateTab?.call(1),
              ),
              const SizedBox(height: 18),

              // 4. Resumen de Flujo de Caja y Gráfico Rápido (Módulo 1.4)
              const CashflowChart(),
              const SizedBox(height: 18),

              // 6. Píldora Diaria de Sabiduría Financiera (Módulo 1.6)
              DailyTipCard(
                onOpenTips: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(3); // Pestaña Tips & Ahorro
                  }
                },
              ),
              const SizedBox(height: 20),

              // Actividad Reciente de Movimientos
              RecentTransactionsList(
                transactions: transactions,
                onViewAll: () {
                  if (onNavigateTab != null) {
                    onNavigateTab!(1); // Pestaña Finanzas
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          heroTag: 'fab_dashboard',
          backgroundColor: TivoColors.primaryIceBlue,
          foregroundColor: const Color(0xFF070E22),
          elevation: 6,
          shape: const CircleBorder(),
          onPressed: () => AddTransactionModal.show(context),
          child: const Icon(LucideIcons.plus, size: 26),
        ),
      ),
    );
  }
}
