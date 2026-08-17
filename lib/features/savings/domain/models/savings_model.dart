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
}
