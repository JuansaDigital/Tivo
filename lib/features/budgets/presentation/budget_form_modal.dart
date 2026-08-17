import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../../core/constants/tivo_spacing.dart';
import '../data/budget_provider.dart';
import '../domain/models/budget_model.dart';

class BudgetFormModal extends ConsumerStatefulWidget {
  final BudgetModel? budgetToEdit;

  const BudgetFormModal({super.key, this.budgetToEdit});

  static Future<void> show(BuildContext context, {BudgetModel? budgetToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BudgetFormModal(budgetToEdit: budgetToEdit),
    );
  }

  @override
  ConsumerState<BudgetFormModal> createState() => _BudgetFormModalState();
}

class _BudgetFormModalState extends ConsumerState<BudgetFormModal> {
  late TextEditingController _categoryController;
  late TextEditingController _limitController;
  late Color _selectedColor;

  final List<Color> _colorOptions = [
    TivoColors.primaryIceBlue,
    TivoColors.accentElectricCyan,
    TivoColors.accentNeonCyan,
    TivoColors.accentPurple,
    TivoColors.statusExpenseRose,
    TivoColors.statusWarningAmber,
    TivoColors.statusIncomeGreen,
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.budgetToEdit;
    _categoryController = TextEditingController(text: b?.categoryName ?? '');
    _limitController = TextEditingController(text: b?.limitAmount.toStringAsFixed(0) ?? '');
    _selectedColor = b?.color ?? _colorOptions.first;
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _save() {
    final limitText = _limitController.text.replaceAll('.', '').replaceAll(',', '').trim();
    final limitAmount = double.tryParse(limitText);

    if (limitAmount == null || limitAmount <= 0 || _categoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa una categoría y un límite válido.'),
          backgroundColor: TivoColors.statusExpenseRose,
        ),
      );
      return;
    }

    final newBudget = BudgetModel(
      id: widget.budgetToEdit?.id ?? const Uuid().v4(),
      categoryName: _categoryController.text.trim(),
      limitAmount: limitAmount,
      spentAmount: widget.budgetToEdit?.spentAmount ?? 0.0,
      color: _selectedColor,
    );

    if (widget.budgetToEdit != null) {
      ref.read(budgetListProvider.notifier).updateBudget(newBudget);
    } else {
      ref.read(budgetListProvider.notifier).addBudget(newBudget);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.budgetToEdit != null;
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Editar Presupuesto' : 'Nuevo Presupuesto',
                  style: const TextStyle(
                    color: TivoColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isEditing)
                  IconButton(
                    icon: const Icon(LucideIcons.trash2, color: TivoColors.statusExpenseRose),
                    onPressed: () {
                      ref.read(budgetListProvider.notifier).deleteBudget(widget.budgetToEdit!.id);
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildTextField(
              controller: _categoryController,
              label: 'CATEGORÍA O CONCEPTO',
              hint: 'Ej: Mercado, Transporte...',
              icon: LucideIcons.tag,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _limitController,
              label: 'LÍMITE MENSUAL (\$)',
              hint: '0',
              icon: LucideIcons.dollarSign,
              isNumber: true,
            ),
            const SizedBox(height: 16),
            
            const Text(
              'COLOR IDENTIFICADOR',
              style: TextStyle(
                color: TivoColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
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
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                      ),
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
                  backgroundColor: TivoColors.primaryIceBlue,
                  foregroundColor: const Color(0xFF070E22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusLg),
                  ),
                ),
                child: Text(
                  isEditing ? 'Guardar Cambios' : 'Crear Presupuesto',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: TivoColors.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: TivoColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: TivoColors.textTertiary),
            prefixIcon: Icon(icon, color: TivoColors.textTertiary, size: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(TivoSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
