import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/glass_card.dart';
import '../../savings/data/savings_provider.dart';
import '../../savings/presentation/savings_form_modal.dart';

class TipsAcademyScreen extends ConsumerStatefulWidget {
  const TipsAcademyScreen({super.key});

  @override
  ConsumerState<TipsAcademyScreen> createState() => _TipsAcademyScreenState();
}

class _TipsAcademyScreenState extends ConsumerState<TipsAcademyScreen> {
  int _selectedSection = 0; // 0: Píldoras, 1: Retos de Ahorro, 2: Calculadoras

  // Calculadora State
  bool _isCompoundInterest = true;
  double _initialAmount = 1000000;
  double _monthlyDeposit = 300000;
  double _annualRate = 12.0; // 12% EA
  int _months = 60; // 5 años

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tips & Educación',
                    style: TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tu Mentor Financiero Inteligente',
                    style: TextStyle(color: TivoColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Segmented Control
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  children: [
                    _sectionTab('Píldoras', 0),
                    _sectionTab('Retos Ahorro', 1),
                    _sectionTab('Calculadoras', 2),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              if (_selectedSection == 0) ...[
                _buildPillsSection(),
              ] else if (_selectedSection == 1) ...[
                _buildChallengesSection(),
              ] else ...[
                  _buildCalculatorsView(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTab(String title, int index) {
    final isSelected = _selectedSection == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedSection = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? TivoColors.primaryIceBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF070E22) : TivoColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillsSection() {
    final pills = [
      {
        'title': 'Cómo funciona el interés compuesto a tu favor',
        'level': 'BÁSICO',
        'levelColor': TivoColors.statusIncomeGreen,
        'readTime': '2 min',
        'content':
            'Albert Einstein llamó al interés compuesto la octava maravilla del mundo. Quien lo entiende lo gana; quien no, lo paga. Reinvertir tus ganancias multiplica exponencialmente tu capital.',
      },
      {
        'title': 'La regla del 50 / 30 / 20 explicada fácil',
        'level': 'BÁSICO',
        'levelColor': TivoColors.statusIncomeGreen,
        'readTime': '3 min',
        'content':
            'Divide tus ingresos netos en 3 bloques: 50% Gastos Esenciales (arriendo, comida), 30% Estilo de Vida (salidas, entretenimiento) y 20% Ahorro e Inversión Blindada.',
      },
      {
        'title': 'Usa tu tarjeta de crédito como un profesional',
        'level': 'INTERMEDIO',
        'levelColor': TivoColors.accentElectricCyan,
        'readTime': '3 min',
        'content':
            'Compra el día después de tu fecha de corte a 1 sola cuota. Así obtendrás hasta 45 días de crédito a tasa 0% de interés y sumarás beneficios de cashback o puntos.',
      },
      {
        'title': 'Cómo construir tu Fondo de Emergencia de 3 a 6 meses',
        'level': 'AVANZADO',
        'levelColor': TivoColors.accentPurple,
        'readTime': '4 min',
        'content':
            'Calcula el total mensual de tus costos fijos y multiplícalo por 3. Este colchón debe mantenerse en cuentas líquidas de alta disponibilidad para protegerte ante imprevistos.',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pills.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final p = pills[index];
        return GlassCard(
          padding: const EdgeInsets.all(16),
          borderRadius: TivoSpacing.radiusLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (p['levelColor'] as Color).withOpacity(0.18),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: (p['levelColor'] as Color).withOpacity(0.4)),
                    ),
                    child: Text(
                      p['level'] as String,
                      style: TextStyle(
                        color: p['levelColor'] as Color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Lectura de ${p['readTime']}',
                    style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                p['title'] as String,
                style: const TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p['content'] as String,
                style: const TextStyle(
                  color: TivoColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChallengesSection() {
    final savingsGoals = ref.watch(savingsListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tus Retos de Ahorro',
                  style: TextStyle(
                    color: TivoColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Crea, edita y monitorea tus metas',
                  style: TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {
                SavingsFormModal.show(context);
              },
              icon: const Icon(LucideIcons.plus, size: 14),
              label: const Text('Nuevo Reto', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: TivoColors.primaryIceBlue,
                foregroundColor: const Color(0xFF070E22),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (savingsGoals.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(28),
            borderRadius: TivoSpacing.radiusLg,
            child: Center(
              child: Column(
                children: [
                  const Icon(LucideIcons.target, size: 36, color: TivoColors.textTertiary),
                  const SizedBox(height: 12),
                  const Text(
                    'No tienes retos de ahorro creados',
                    style: TextStyle(color: TivoColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Define tus metas financieras (ej: Fondo de Emergencia, Vacaciones) y monitorea su avance.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: TivoColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => SavingsFormModal.show(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TivoColors.statusIncomeGreen,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Crear Mi Primer Reto'),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savingsGoals.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final g = savingsGoals[index];
              final progress = (g.currentAmount / g.targetAmount).clamp(0.0, 1.0);
              final percentFormatted = (progress * 100).toStringAsFixed(0);

              return Dismissible(
                key: Key(g.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: TivoColors.statusExpenseRose,
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
                  ),
                  child: const Icon(LucideIcons.trash2, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(savingsListProvider.notifier).deleteGoal(g.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reto "${g.title}" eliminado.'),
                      backgroundColor: TivoColors.statusExpenseRose,
                    ),
                  );
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderRadius: TivoSpacing.radiusLg,
                  onTap: () {
                    SavingsFormModal.show(context, goalToEdit: g);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              g.title,
                              style: const TextStyle(
                                color: TivoColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: g.color.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                              border: Border.all(color: g.color.withOpacity(0.4)),
                            ),
                            child: Text(
                              '$percentFormatted% Completado',
                              style: TextStyle(color: g.color, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(LucideIcons.pencil, size: 16, color: TivoColors.textTertiary),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              SavingsFormModal.show(context, goalToEdit: g);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(g.color),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Aporte sugerido: ${CurrencyFormatter.formatCompact(g.monthlyContribution)}/mes',
                            style: const TextStyle(color: TivoColors.textTertiary, fontSize: 11),
                          ),
                          Text(
                            '${CurrencyFormatter.formatCompact(g.currentAmount)} / ${CurrencyFormatter.formatCompact(g.targetAmount)}',
                            style: const TextStyle(
                              color: TivoColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
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
      ],
    );
  }

  Widget _buildCalculatorsView() {
    double totalAccumulated = 0;
    double totalInterestGained = 0;
    double totalInvested = _initialAmount + (_monthlyDeposit * _months);

    if (_isCompoundInterest) {
      final monthlyRate = _annualRate / 12 / 100;
      double currentBalance = _initialAmount;
      for (int i = 0; i < _months; i++) {
        currentBalance += _monthlyDeposit;
        currentBalance *= (1 + monthlyRate);
      }
      totalAccumulated = currentBalance;
      totalInterestGained = totalAccumulated - totalInvested;
    } else {
      final monthlyRate = _annualRate / 12 / 100;
      totalInterestGained = _initialAmount * monthlyRate * _months;
      // Para interés simple, asumimos que el aporte mensual no genera interés
      totalAccumulated = totalInvested + totalInterestGained;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassCard(
          padding: const EdgeInsets.all(18),
          borderRadius: TivoSpacing.radiusLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(LucideIcons.calculator, size: 18, color: TivoColors.primaryIceBlue),
                  SizedBox(width: 8),
                  Text(
                    'Calculadora Financiera',
                    style: TextStyle(
                      color: TivoColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tipo de Interés', style: TextStyle(color: TivoColors.textSecondary, fontSize: 13)),
                  Row(
                    children: [
                      const Text('Simple', style: TextStyle(color: TivoColors.textSecondary, fontSize: 12)),
                      Switch(
                        value: _isCompoundInterest,
                        activeColor: TivoColors.accentNeonCyan,
                        onChanged: (val) => setState(() => _isCompoundInterest = val),
                      ),
                      const Text('Compuesto', style: TextStyle(color: TivoColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text('Monto Inicial: ${CurrencyFormatter.formatCOP(_initialAmount)}', style: const TextStyle(color: TivoColors.textSecondary, fontSize: 12)),
              Slider(
                value: _initialAmount,
                min: 0,
                max: 10000000,
                divisions: 100,
                activeColor: TivoColors.statusIncomeGreen,
                onChanged: (v) => setState(() => _initialAmount = v),
              ),
              
              Text('Aporte Mensual: ${CurrencyFormatter.formatCOP(_monthlyDeposit)}', style: const TextStyle(color: TivoColors.textSecondary, fontSize: 12)),
              Slider(
                value: _monthlyDeposit,
                min: 0,
                max: 2000000,
                divisions: 40,
                activeColor: TivoColors.primaryIceBlue,
                onChanged: (v) => setState(() => _monthlyDeposit = v),
              ),
              
              Text('Tasa de Interés (E.A): ${_annualRate.toStringAsFixed(1)}%', style: const TextStyle(color: TivoColors.textSecondary, fontSize: 12)),
              Slider(
                value: _annualRate,
                min: 1,
                max: 30,
                divisions: 29,
                activeColor: TivoColors.statusWarningAmber,
                onChanged: (v) => setState(() => _annualRate = v),
              ),

              Text('Plazo: $_months meses (${(_months/12).toStringAsFixed(1)} años)', style: const TextStyle(color: TivoColors.textSecondary, fontSize: 12)),
              Slider(
                value: _months.toDouble(),
                min: 1,
                max: 120,
                divisions: 119,
                activeColor: TivoColors.accentElectricCyan,
                onChanged: (v) => setState(() => _months = v.round()),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                  border: Border.all(color: TivoColors.primaryIceBlue.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Capital Total Acumulado:', style: TextStyle(color: TivoColors.textSecondary, fontSize: 12)),
                        Text(
                          CurrencyFormatter.formatCOP(totalAccumulated),
                          style: const TextStyle(color: TivoColors.accentNeonCyan, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ganancia por Intereses:', style: TextStyle(color: TivoColors.textSecondary, fontSize: 11)),
                        Text(
                          '+${CurrencyFormatter.formatCOP(totalInterestGained)}',
                          style: const TextStyle(color: TivoColors.statusIncomeGreenLight, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
