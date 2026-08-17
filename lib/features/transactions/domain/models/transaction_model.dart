import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum TransactionType {
  income,
  expense,
  fixedCost,
  saving,
}

enum ExpenseCategory {
  housing('Vivienda', LucideIcons.home, Color(0xFF60A5FA)),
  food('Alimentación', LucideIcons.utensils, Color(0xFFF97316)),
  transport('Transporte', LucideIcons.car, Color(0xFFFACC15)),
  utilities('Servicios', LucideIcons.zap, Color(0xFFA855F7)),
  entertainment('Ocio & Placer', LucideIcons.film, Color(0xFFEC4899)),
  health('Salud', LucideIcons.heartPulse, Color(0xFF10B981)),
  education('Educación', LucideIcons.bookOpen, Color(0xFF38BDF8)),
  salary('Salario', LucideIcons.wallet, Color(0xFF10B981)),
  returns('Rendimientos', LucideIcons.trendingUp, Color(0xFF06B6D4)),
  savings('Ahorro & Metas', LucideIcons.piggyBank, Color(0xFF10B981)),
  other('Otros', LucideIcons.layers, Color(0xFF94A3B8));

  final String label;
  final IconData icon;
  final Color color;

  const ExpenseCategory(this.label, this.icon, this.color);
}

enum NecessityType {
  need('Necesidad'),
  want('Deseo'),
  saving('Ahorro/Inversión');

  final String label;
  const NecessityType(this.label);
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final ExpenseCategory category;
  final NecessityType necessity;
  final String accountName;
  final DateTime date;
  final String? note;
  final String? tag;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    this.necessity = NecessityType.need,
    required this.accountName,
    required this.date,
    this.note,
    this.tag,
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    ExpenseCategory? category,
    NecessityType? necessity,
    String? accountName,
    DateTime? date,
    String? note,
    String? tag,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      necessity: necessity ?? this.necessity,
      accountName: accountName ?? this.accountName,
      date: date ?? this.date,
      note: note ?? this.note,
      tag: tag ?? this.tag,
    );
  }
}
