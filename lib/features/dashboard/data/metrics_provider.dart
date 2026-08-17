import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../accounts/data/account_provider.dart';
import '../../accounts/domain/models/account_model.dart';
import '../../reminders/data/reminders_provider.dart';
import '../../reminders/domain/models/reminder_model.dart';
import '../../transactions/data/transaction_provider.dart';
import '../../transactions/domain/models/transaction_model.dart';

/// Control del Modo Oculto / Privacidad (Flip-to-Hide)
final privacyModeProvider = StateProvider<bool>((ref) => false);

class FinancialMetrics {
  final double totalLiquidCash; // Saldo disponible en cuentas de ahorro y efectivo
  final double totalDebt; // Consumo actual en tarjetas de crédito
  final double netWorth; // Patrimonio Neto Líquido (Líquido - Deuda)
  final double monthlyIncome;
  final double monthlyExpenses;
  final double pendingCommittedExpenses; // Compromisos fijos pendientes (arriendo, servicios)
  final double monthlySavingsTarget;
  final double safeToSpendMonth;
  final double safeToSpendToday;
  final double financialRunwayMonths; // Fondo de emergencia en meses
  final double creditUtilizationRate; // % de cupo de crédito usado
  final int tivoScore; // 0 - 100 pts (PRD)
  final int streakDays;
  final double monthlySubscriptionsTotal;
  final double annualSubscriptionsProjected;

  const FinancialMetrics({
    required this.totalLiquidCash,
    required this.totalDebt,
    required this.netWorth,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.pendingCommittedExpenses,
    required this.monthlySavingsTarget,
    required this.safeToSpendMonth,
    required this.safeToSpendToday,
    required this.financialRunwayMonths,
    required this.creditUtilizationRate,
    required this.tivoScore,
    required this.streakDays,
    required this.monthlySubscriptionsTotal,
    required this.annualSubscriptionsProjected,
  });
}

final financialMetricsProvider = Provider<FinancialMetrics>((ref) {
  final transactions = ref.watch(transactionListProvider);
  final accounts = ref.watch(accountListProvider);
  final reminders = ref.watch(reminderListProvider);

  // 1. Calcular Saldo Líquido y Deuda de Cuentas Reales
  double liquidCash = 0.0;
  double totalDebt = 0.0;
  double totalCreditLimit = 0.0;

  for (final acc in accounts) {
    if (acc.type == AccountType.savings ||
        acc.type == AccountType.checking ||
        acc.type == AccountType.cash) {
      liquidCash += acc.balance;
    } else if (acc.type == AccountType.creditCard) {
      totalDebt += acc.balance;
      totalCreditLimit += acc.creditLimit ?? 0;
    }
  }

  // 2. Ingresos y Gastos del Mes
  double totalIncome = 0;
  double totalExpenses = 0;
  for (final t in transactions) {
    if (t.type == TransactionType.income) {
      totalIncome += t.amount;
    } else if (t.type == TransactionType.expense) {
      totalExpenses += t.amount;
    }
  }

  // 3. Compromisos Fijos Pendientes (Módulo 3: Arriendos, Servicios no pagados)
  double pendingCommitted = 0.0;
  double subscriptionsTotal = 0.0;
  for (final r in reminders) {
    if (!r.isPaid) {
      pendingCommitted += r.estimatedAmount;
    }
    if (r.pillar == ReminderPillar.subscription) {
      subscriptionsTotal += r.estimatedAmount;
    }
  }

  // Meta de ahorro mensual recomendada (20% de los ingresos)
  final double savingsTarget = totalIncome * 0.20;

  // 4. Safe-to-Spend según la fórmula matemática del PRD:
  // SafeToSpend_Total = Sum(Cuentas Líquidas) - Sum(Compromisos Pendientes Mes) - Cuota Ahorro
  final double safeTotal = (liquidCash - pendingCommitted - savingsTarget).clamp(0.0, double.infinity);

  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final daysRemaining = (daysInMonth - now.day) + 1;
  final double safeToday = (safeTotal / (daysRemaining > 0 ? daysRemaining : 1)).clamp(0.0, double.infinity);

  // 5. Pista Financiera (Meses de supervivencia con gasto promedio)
  final double avgMonthlyBurn = totalExpenses > 0 ? totalExpenses : 1.0;
  final double runway = liquidCash > 0 ? (liquidCash / avgMonthlyBurn) : 0.0;

  // 6. Utilización de Crédito
  final double creditUtilization = totalCreditLimit > 0 ? (totalDebt / totalCreditLimit) : 0.0;

  // 7. Tivo Score 0-100 pts
  double score = 0;
  if (accounts.isNotEmpty || transactions.isNotEmpty) {
    // Ahorro
    if (totalIncome > 0 && (totalIncome - totalExpenses) / totalIncome >= 0.2) {
      score += 30;
    } else if (totalIncome > 0) {
      score += (((totalIncome - totalExpenses) / totalIncome) * 150).clamp(0.0, 30.0);
    }
    // Crédito (<30% de uso)
    if (creditUtilization <= 0.30) {
      score += 30;
    } else {
      score += (30 - ((creditUtilization - 0.30) * 50)).clamp(0.0, 30.0);
    }
    // Puntualidad
    score += 20;
    // Fondo de Emergencia
    if (runway >= 3.0) {
      score += 20;
    } else {
      score += (runway / 3.0 * 20).clamp(0.0, 20.0);
    }
  }

  return FinancialMetrics(
    totalLiquidCash: liquidCash,
    totalDebt: totalDebt,
    netWorth: liquidCash - totalDebt,
    monthlyIncome: totalIncome,
    monthlyExpenses: totalExpenses,
    pendingCommittedExpenses: pendingCommitted,
    monthlySavingsTarget: savingsTarget,
    safeToSpendMonth: safeTotal,
    safeToSpendToday: safeToday,
    financialRunwayMonths: double.parse(runway.toStringAsFixed(1)),
    creditUtilizationRate: creditUtilization,
    tivoScore: score.round().clamp(0, 100),
    streakDays: 14,
    monthlySubscriptionsTotal: subscriptionsTotal,
    annualSubscriptionsProjected: subscriptionsTotal * 12,
  );
});
