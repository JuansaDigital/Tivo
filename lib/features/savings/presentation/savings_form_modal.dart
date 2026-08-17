import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../data/savings_provider.dart';
import '../domain/models/savings_model.dart';

class SavingsFormModal extends ConsumerStatefulWidget {
  final SavingsGoalModel? goalToEdit;

  const SavingsFormModal({super.key, this.goalToEdit});

  static Future<void> show(BuildContext context, {SavingsGoalModel? goalToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SavingsFormModal(goalToEdit: goalToEdit),
    );
  }

  @override
  ConsumerState<SavingsFormModal> createState() => _SavingsFormModalState();
}

class _SavingsFormModalState extends ConsumerState<SavingsFormModal> {
  late TextEditingController _titleController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  late TextEditingController _monthlyController;
  late Color _selectedColor;

  final List<Color> _colorOptions = [
    TivoColors.statusIncomeGreen,
    TivoColors.accentElectricCyan,
    TivoColors.primaryIceBlue,
    TivoColors.accentPurple,
    TivoColors.statusExpenseRose,
  ];

  @override
  void initState() {
    super.initState();
    final g = widget.goalToEdit;
    _titleController = TextEditingController(text: g?.title ?? '');
    _targetController = TextEditingController(text: g?.targetAmount.toStringAsFixed(0) ?? '');
    _currentController = TextEditingController(text: g?.currentAmount.toStringAsFixed(0) ?? '');
    _monthlyController = TextEditingController(text: g?.monthlyContribution.toStringAsFixed(0) ?? '');
    _selectedColor = g?.color ?? _colorOptions.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final target = double.tryParse(_targetController.text) ?? 0;
    final current = double.tryParse(_currentController.text) ?? 0;
    final monthly = double.tryParse(_monthlyController.text) ?? 0;

    if (title.isEmpty || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un título y una meta válida.'), backgroundColor: TivoColors.statusExpenseRose),
      );
      return;
    }

    final newGoal = SavingsGoalModel(
      id: widget.goalToEdit?.id ?? const Uuid().v4(),
      title: title,
      targetAmount: target,
      currentAmount: current,
      monthlyContribution: monthly,
      color: _selectedColor,
    );

    if (widget.goalToEdit != null) {
      ref.read(savingsListProvider.notifier).updateGoal(newGoal);
    } else {
      ref.read(savingsListProvider.notifier).addGoal(newGoal);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goalToEdit != null;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        color: TivoColors.bgDeepNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(TivoSpacing.radiusXl)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Editar Meta' : 'Nueva Meta de Ahorro',
                  style: const TextStyle(color: TivoColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
                ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, color: TivoColors.statusExpenseRose),
                    onPressed: () {
                      ref.read(savingsListProvider.notifier).deleteGoal(widget.goalToEdit!.id);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildTextField(controller: _titleController, label: 'TÍTULO DEL RETO', hint: 'Ej: Viaje, Auto...', icon: LucideIcons.target),
            const SizedBox(height: 16),
            _buildTextField(controller: _targetController, label: 'META TOTAL (\$)', hint: '0', icon: LucideIcons.dollarSign, isNumber: true),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _currentController, label: 'AHORRO ACTUAL (\$)', hint: '0', icon: LucideIcons.piggyBank, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: _monthlyController, label: 'APORTE MENSUAL', hint: '0', icon: LucideIcons.calendarClock, isNumber: true)),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text('COLOR IDENTIFICADOR', style: TextStyle(color: TivoColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _colorOptions.length,
                itemBuilder: (context, index) {
                  final color = _colorOptions[index];
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 44,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: isSelected ? Border.all(color: Colors.white, width: 3) : null),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TivoColors.statusIncomeGreen,
                  foregroundColor: const Color(0xFF070E22),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TivoSpacing.radiusLg)),
                ),
                child: Text(isEditing ? 'Guardar Cambios' : 'Crear Meta', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, required IconData icon, bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: TivoColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: TivoColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint, hintStyle: const TextStyle(color: TivoColors.textTertiary),
            prefixIcon: Icon(icon, color: TivoColors.textTertiary, size: 18),
            filled: true, fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(TivoSpacing.radiusMd), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
