import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tivo_colors.dart';
import '../domain/models/savings_model.dart';

final savingsListProvider = StateNotifierProvider<SavingsNotifier, List<SavingsGoalModel>>((ref) {
  return SavingsNotifier();
});

class SavingsNotifier extends StateNotifier<List<SavingsGoalModel>> {
  SavingsNotifier() : super(_initialGoals);

  static final List<SavingsGoalModel> _initialGoals = [
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
  }

  void updateGoal(SavingsGoalModel updatedGoal) {
    state = state.map((g) => g.id == updatedGoal.id ? updatedGoal : g).toList();
  }

  void deleteGoal(String id) {
    state = state.where((g) => g.id != id).toList();
  }
}
