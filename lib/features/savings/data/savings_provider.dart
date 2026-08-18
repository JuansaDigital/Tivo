import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../../../core/services/storage_service.dart';
import '../domain/models/savings_model.dart';

final savingsListProvider = StateNotifierProvider<SavingsNotifier, List<SavingsGoalModel>>((ref) {
  return SavingsNotifier();
});

class SavingsNotifier extends StateNotifier<List<SavingsGoalModel>> {
  SavingsNotifier() : super(StorageService.loadSavings());

  static List<SavingsGoalModel> get initialGoals => [
    SavingsGoalModel(
      id: 'sav_1',
      title: 'Fondo de Emergencia (3 Meses)',
      currentAmount: 8200000.0,
      targetAmount: 12000000.0,
      monthlyContribution: 600000.0,
      color: TivoColors.statusIncomeGreen,
    ),
    SavingsGoalModel(
      id: 'sav_2',
      title: 'Viaje Fin de Año 2026',
      currentAmount: 3400000.0,
      targetAmount: 6000000.0,
      monthlyContribution: 400000.0,
      color: TivoColors.accentElectricCyan,
    ),
  ];

  void addGoal(SavingsGoalModel goal) {
    state = [...state, goal];
    StorageService.saveSavings(state);
  }

  void updateGoal(SavingsGoalModel updatedGoal) {
    state = state.map((g) => g.id == updatedGoal.id ? updatedGoal : g).toList();
    StorageService.saveSavings(state);
  }

  void deleteGoal(String id) {
    state = state.where((g) => g.id != id).toList();
    StorageService.saveSavings(state);
  }

  void addContribution(String id, double extraAmount) {
    state = state.map((g) {
      if (g.id == id) {
        return SavingsGoalModel(
          id: g.id,
          title: g.title,
          targetAmount: g.targetAmount,
          currentAmount: g.currentAmount + extraAmount,
          monthlyContribution: g.monthlyContribution,
          color: g.color,
        );
      }
      return g;
    }).toList();
    StorageService.saveSavings(state);
  }

  void reset() {
    state = [];
    StorageService.saveSavings(state);
  }

  void loadDemoData() {
    state = initialGoals;
    StorageService.saveSavings(state);
  }
}
