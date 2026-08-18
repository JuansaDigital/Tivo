import 'package:flutter/material.dart';

class SavingsGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final double monthlyContribution;
  final Color color;

  SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.monthlyContribution,
    required this.color,
  });

  SavingsGoalModel copyWith({
    String? title,
    double? targetAmount,
    double? currentAmount,
    double? monthlyContribution,
    Color? color,
  }) {
    return SavingsGoalModel(
      id: id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'monthlyContribution': monthlyContribution,
      'color': color.value,
    };
  }

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      targetAmount: (map['targetAmount'] as num?)?.toDouble() ?? 0.0,
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? 0.0,
      monthlyContribution: (map['monthlyContribution'] as num?)?.toDouble() ?? 0.0,
      color: map['color'] != null ? Color(map['color'] as int) : const Color(0xFF10B981),
    );
  }
}
