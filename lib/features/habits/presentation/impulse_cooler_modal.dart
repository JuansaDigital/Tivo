import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/glowing_badge.dart';
import '../../../core/widgets/tivo_button.dart';

class ImpulseCoolerModal extends StatefulWidget {
  const ImpulseCoolerModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ImpulseCoolerModal(),
    );
  }

  @override
  State<ImpulseCoolerModal> createState() => _ImpulseCoolerModalState();
}

class _ImpulseCoolerModalState extends State<ImpulseCoolerModal> {
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  double _price = 0;
  int _coolingHours = 48;

  // Sueldo promedio estimado x hora de trabajo (~$25.000 COP/hora)
  static const double _hourlyWage = 25000;

  double get _hoursOfWork => _price > 0 ? _price / _hourlyWage : 0;

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _onPriceChanged(String value) {
    final clean = value.replaceAll('.', '').replaceAll(',', '').trim();
    setState(() {
      _price = double.tryParse(clean) ?? 0;
    });
  }

  void _startCooler() {
    if (_price <= 0 || _itemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa el nombre del deseo y el precio.'),
          backgroundColor: TivoColors.statusExpenseRose,
        ),
      );
      return;
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❄️ "${_itemController.text.trim()}" ha entrado en enfriamiento por $_coolingHours horas.'),
        backgroundColor: TivoColors.accentPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.only(top: 12),
      child: GlassCard(
        borderRadius: TivoSpacing.radiusXl,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(LucideIcons.snowflake, size: 20, color: TivoColors.accentPurple),
                      SizedBox(width: 8),
                      Text(
                        'Enfriador de Impulsos',
                        style: TextStyle(
                          color: TivoColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const GlowingBadge(
                    text: 'Neuroeconomía',
                    color: TivoColors.accentPurple,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                '¿Qué deseas comprar por impulso?',
                style: TextStyle(color: TivoColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _itemController,
                style: const TextStyle(color: TivoColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Ej: Nuevos Auriculares, Zapatos, Gadget...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                '¿Cuánto cuesta? (COP)',
                style: TextStyle(color: TivoColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                onChanged: _onPriceChanged,
                style: const TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(
                    color: TivoColors.accentPurple,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.25),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Impacto Psicológico / Horas de Trabajo
              if (_price > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TivoColors.accentPurple.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
                    border: Border.all(color: TivoColors.accentPurple.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.clock, size: 24, color: TivoColors.accentPurple),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Costo en Tiempo de Vida',
                              style: TextStyle(
                                color: TivoColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Equivale a ${_hoursOfWork.toStringAsFixed(1)} horas de tu trabajo',
                              style: const TextStyle(
                                color: TivoColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Tiempo de enfriamiento
              const Text(
                'Tiempo de Pausa Recomendado',
                style: TextStyle(color: TivoColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [24, 48, 72].map((hours) {
                  final isSelected = _coolingHours == hours;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _coolingHours = hours),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TivoColors.accentPurple.withOpacity(0.3)
                              : Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(TivoSpacing.radiusSm),
                          border: Border.all(
                            color: isSelected ? TivoColors.accentPurple : Colors.white10,
                          ),
                        ),
                        child: Text(
                          '$hours Horas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? TivoColors.textPrimary : TivoColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              TivoButton(
                width: double.infinity,
                label: 'Poner en Pausa de Enfriamiento',
                icon: LucideIcons.snowflake,
                onPressed: _startCooler,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
