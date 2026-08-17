import 'package:flutter/material.dart';
import '../../../../core/constants/tivo_colors.dart';

class TaxMetricThreshold {
  final String title;
  final String description;
  final double currentAmount;
  final double limitThreshold; // Tope legal (ej: 1400 UVT)
  final String uvtEquivalent;

  const TaxMetricThreshold({
    required this.title,
    required this.description,
    required this.currentAmount,
    required this.limitThreshold,
    required this.uvtEquivalent,
  });

  double get percentage => (currentAmount / limitThreshold).clamp(0.0, 1.0);

  Color get statusColor {
    final p = percentage;
    if (p >= 0.80) return TivoColors.statusExpenseRose;
    if (p >= 0.60) return TivoColors.statusWarningAmber;
    return TivoColors.statusIncomeGreen;
  }

  String get statusText {
    final p = percentage;
    if (p >= 0.80) return 'Riesgo Alto (Alerta Tope)';
    if (p >= 0.60) return 'Precaución';
    return 'Zona Segura';
  }
}

class TaxShieldProfile {
  final int taxYear;
  final TaxMetricThreshold cardPurchases;
  final TaxMetricThreshold bankDeposits;
  final TaxMetricThreshold grossAssets;

  const TaxShieldProfile({
    required this.taxYear,
    required this.cardPurchases,
    required this.bankDeposits,
    required this.grossAssets,
  });
}
