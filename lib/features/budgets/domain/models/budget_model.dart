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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryName': categoryName,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'color': color.value,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] ?? '',
      categoryName: map['categoryName'] ?? '',
      limitAmount: (map['limitAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (map['spentAmount'] as num?)?.toDouble() ?? 0.0,
      color: map['color'] != null ? Color(map['color'] as int) : const Color(0xFF38BDF8),
    );
  }
}
