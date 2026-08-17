import 'package:flutter/material.dart';

class BudgetModel {
  final String id;
  final String categoryName;
  final double limitAmount;
  final double spentAmount;
  final Color color;

  BudgetModel({
    required this.id,
    required this.categoryName,
    required this.limitAmount,
    this.spentAmount = 0.0,
    required this.color,
  });

  BudgetModel copyWith({
    String? categoryName,
    double? limitAmount,
    double? spentAmount,
    Color? color,
  }) {
    return BudgetModel(
      id: id,
      categoryName: categoryName ?? this.categoryName,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      color: color ?? this.color,
    );
  }
}
