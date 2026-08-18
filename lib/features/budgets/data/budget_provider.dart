import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../core/services/storage_service.dart';
import '../domain/models/budget_model.dart';

final budgetListProvider = StateNotifierProvider<BudgetNotifier, List<BudgetModel>>((ref) {
  return BudgetNotifier();
});

class BudgetNotifier extends StateNotifier<List<BudgetModel>> {
  BudgetNotifier() : super(StorageService.loadBudgets());

  static List<BudgetModel> get initialBudgets => [
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
    StorageService.saveBudgets(state);
  }

  void updateBudget(BudgetModel updatedBudget) {
    state = state.map((b) => b.id == updatedBudget.id ? updatedBudget : b).toList();
    StorageService.saveBudgets(state);
  }

  void deleteBudget(String id) {
    state = state.where((b) => b.id != id).toList();
    StorageService.saveBudgets(state);
  }

  void reset() {
    state = [];
    StorageService.saveBudgets(state);
  }

  void loadDemoData() {
    state = initialBudgets;
    StorageService.saveBudgets(state);
  }
}
