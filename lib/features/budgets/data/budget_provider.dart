import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../domain/models/budget_model.dart';

final budgetListProvider = StateNotifierProvider<BudgetNotifier, List<BudgetModel>>((ref) {
  return BudgetNotifier();
});

class BudgetNotifier extends StateNotifier<List<BudgetModel>> {
  BudgetNotifier() : super(_initialBudgets);

  static final List<BudgetModel> _initialBudgets = [
    BudgetModel(
      id: 'budget_1',
      categoryName: 'Alimentación & Mercado',
      spentAmount: 780000.0,
      limitAmount: 1000000.0,
      color: TivoColors.primaryIceBlue,
    ),
    BudgetModel(
      id: 'budget_2',
      categoryName: 'Vivienda & Servicios',
      spentAmount: 1850000.0,
      limitAmount: 2000000.0,
      color: TivoColors.accentElectricCyan,
    ),
    BudgetModel(
      id: 'budget_3',
      categoryName: 'Salidas & Ocio',
      spentAmount: 420000.0,
      limitAmount: 400000.0,
      color: TivoColors.statusExpenseRose,
    ),
    BudgetModel(
      id: 'budget_4',
      categoryName: 'Transporte & Gasolina',
      spentAmount: 190000.0,
      limitAmount: 350000.0,
      color: TivoColors.accentPurple,
    ),
  ];

  void addBudget(BudgetModel budget) {
    state = [...state, budget];
  }

  void updateBudget(BudgetModel updatedBudget) {
    state = state.map((b) => b.id == updatedBudget.id ? updatedBudget : b).toList();
  }

  void deleteBudget(String id) {
    state = state.where((b) => b.id != id).toList();
  }

  void reset() {
    state = [];
  }
}
