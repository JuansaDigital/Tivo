import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum ReminderPillar {
  fixedUtility('Servicios y Fijos', LucideIcons.receiptText, Color(0xFF38BDF8)),
  creditDebt('Tarjetas & Deudas', LucideIcons.creditCard, Color(0xFFF43F5E)),
  subscription('Suscripción', LucideIcons.repeat, Color(0xFFA855F7));

  final String label;
  final IconData icon;
  final Color color;

  const ReminderPillar(this.label, this.icon, this.color);
}

class ReminderModel {
  final String id;
  final String title;
  final ReminderPillar pillar;
  final double estimatedAmount;
  final DateTime dueDate;
  final bool isPaid;
  final String defaultAccountId;
  final String? notes;
  final double? minimumPayment; // Para tarjetas de crédito
  final double? interestRateEA; // Tasa si se difiere / pago mínimo

  const ReminderModel({
    required this.id,
    required this.title,
    required this.pillar,
    required this.estimatedAmount,
    required this.dueDate,
    this.isPaid = false,
    required this.defaultAccountId,
    this.notes,
    this.minimumPayment,
    this.interestRateEA,
  });

  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  bool get isUrgent => !isPaid && daysUntilDue <= 3;
  bool get isOverdue => !isPaid && daysUntilDue < 0;

  ReminderModel copyWith({
    String? id,
    String? title,
    ReminderPillar? pillar,
    double? estimatedAmount,
    DateTime? dueDate,
    bool? isPaid,
    String? defaultAccountId,
    String? notes,
    double? minimumPayment,
    double? interestRateEA,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      pillar: pillar ?? this.pillar,
      estimatedAmount: estimatedAmount ?? this.estimatedAmount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      defaultAccountId: defaultAccountId ?? this.defaultAccountId,
      notes: notes ?? this.notes,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      interestRateEA: interestRateEA ?? this.interestRateEA,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'pillar': pillar.name,
      'estimatedAmount': estimatedAmount,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid,
      'defaultAccountId': defaultAccountId,
      'notes': notes,
      'minimumPayment': minimumPayment,
      'interestRateEA': interestRateEA,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      pillar: ReminderPillar.values.firstWhere(
        (e) => e.name == map['pillar'],
        orElse: () => ReminderPillar.fixedUtility,
      ),
      estimatedAmount: (map['estimatedAmount'] as num?)?.toDouble() ?? 0.0,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : DateTime.now(),
      isPaid: map['isPaid'] ?? false,
      defaultAccountId: map['defaultAccountId'] ?? '',
      notes: map['notes'],
      minimumPayment: (map['minimumPayment'] as num?)?.toDouble(),
      interestRateEA: (map['interestRateEA'] as num?)?.toDouble(),
    );
  }
}
