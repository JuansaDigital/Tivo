import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glowing_badge.dart';
import '../../../core/widgets/tivo_button.dart';
import '../../dashboard/data/metrics_provider.dart';
import 'impulse_cooler_modal.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(financialMetricsProvider);

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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Hábitos & Neuroeconomía',
                        style: TextStyle(
                          color: TivoColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Psicología del gasto y rachas de ahorro',
                        style: TextStyle(
                          color: TivoColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => ImpulseCoolerModal.show(context),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: TivoColors.accentPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.snowflake,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tarjeta Racha de Autocontrol
              GlassCard(
                hasGlow: true,
                glowColor: TivoColors.statusIncomeGreen,
                backgroundGradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x3310B981),
                    Color(0x1F06B6D4),
                    Color(0x241C2541),
                  ],
                ),
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TivoColors.statusIncomeGreen.withOpacity(0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TivoColors.statusIncomeGreen.withOpacity(0.35),
                        ),
                      ),
                      child: const Icon(
                        LucideIcons.flame,
                        size: 32,
                        color: TivoColors.statusIncomeGreenLight,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'RACHA ACTIVA',
                            style: TextStyle(
                              color: TivoColors.statusIncomeGreenLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${metrics.streakDays} Días en Control',
                            style: const TextStyle(
                              color: TivoColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sin sobrepasar tu límite diario Safe-to-Spend.',
                            style: TextStyle(
                              color: TivoColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Botón Enfriar Nuevo Impulso
              TivoButton(
                width: double.infinity,
                label: 'Enfriar Nueva Compra Impulsiva',
                icon: LucideIcons.snowflake,
                variant: TivoButtonVariant.glass,
                onPressed: () => ImpulseCoolerModal.show(context),
              ),
              const SizedBox(height: 24),

              // Deseos en Enfriamiento Activo
              const Text(
                'Deseos en Cuarentena (48h)',
                style: TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              _ImpulseItemCard(
                title: 'Auriculares Sony WH-1000XM5',
                price: 1350000,
                hoursRemaining: 31,
                hoursOfWork: 54.0,
              ),
              const SizedBox(height: 10),
              _ImpulseItemCard(
                title: 'Tenis Deportivos Running Pro',
                price: 520000,
                hoursRemaining: 12,
                hoursOfWork: 20.8,
              ),
              const SizedBox(height: 24),

              // Desglose Tivo Score
              const Text(
                'Desglose Tivo Score',
                style: TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              GlassCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: const [
                    _ScoreFactorRow(
                      label: 'Tasa de Ahorro e Inversión',
                      score: '92 / 100',
                      color: TivoColors.accentNeonCyan,
                      progress: 0.92,
                    ),
                    SizedBox(height: 12),
                    _ScoreFactorRow(
                      label: 'Pista de Supervivencia Financiera',
                      score: '88 / 100',
                      color: TivoColors.primaryIceBlue,
                      progress: 0.88,
                    ),
                    SizedBox(height: 12),
                    _ScoreFactorRow(
                      label: 'Ratio de Endeudamiento',
                      score: '80 / 100',
                      color: TivoColors.statusIncomeGreen,
                      progress: 0.80,
                    ),
                    SizedBox(height: 12),
                    _ScoreFactorRow(
                      label: 'Control de Impulsos & Presupuesto',
                      score: '76 / 100',
                      color: TivoColors.statusWarningAmber,
                      progress: 0.76,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpulseItemCard extends StatelessWidget {
  final String title;
  final double price;
  final int hoursRemaining;
  final double hoursOfWork;

  const _ImpulseItemCard({
    required this.title,
    required this.price,
    required this.hoursRemaining,
    required this.hoursOfWork,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: TivoSpacing.radiusMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GlowingBadge(
                text: 'Faltan ${hoursRemaining}h',
                color: TivoColors.accentPurple,
                icon: LucideIcons.timer,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Costo: ${price.toStringAsFixed(0)} COP',
                style: const TextStyle(color: TivoColors.textSecondary, fontSize: 13),
              ),
              Text(
                '${hoursOfWork.toStringAsFixed(1)} horas de trabajo',
                style: const TextStyle(
                  color: TivoColors.statusExpenseRoseLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreFactorRow extends StatelessWidget {
  final String label;
  final String score;
  final Color color;
  final double progress;

  const _ScoreFactorRow({
    required this.label,
    required this.score,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: TivoColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            Text(
              score,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
