import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum AccountType {
  savings('Ahorros', LucideIcons.wallet, Color(0xFF10B981)),
  creditCard('Tarjeta de Crédito', LucideIcons.creditCard, Color(0xFF818CF8)),
  checking('Corriente', LucideIcons.landmark, Color(0xFF38BDF8)),
  cash('Efectivo / Bolsillo', LucideIcons.coins, Color(0xFFFBBF24));

  final String label;
  final IconData icon;
  final Color color;

  const AccountType(this.label, this.icon, this.color);
}

class AccountModel {
  final String id;
  final String name;
  final String institutionName;
  final AccountType type;
  final double balance; // Para crédito: saldo consumido actual
  final double? creditLimit; // Solo para tarjetas de crédito
  final int? cutOffDay; // Día de corte (1-31)
  final int? paymentDueDay; // Día límite de pago (1-31)
  final bool isGMFExempt; // Exenta de 4x1000 en Colombia
  final String accountNumberMasked; // ej: •••• 4589

  const AccountModel({
    required this.id,
    required this.name,
    required this.institutionName,
    required this.type,
    required this.balance,
    this.creditLimit,
    this.cutOffDay,
    this.paymentDueDay,
    this.isGMFExempt = false,
    required this.accountNumberMasked,
  });

  double get availableCredit {
    if (type != AccountType.creditCard || creditLimit == null) return 0.0;
    return (creditLimit! - balance).clamp(0.0, creditLimit!);
  }

  double get creditUtilization {
    if (type != AccountType.creditCard || creditLimit == null || creditLimit == 0) return 0.0;
    return (balance / creditLimit!).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'institutionName': institutionName,
      'type': type.name,
      'balance': balance,
      'creditLimit': creditLimit,
      'cutOffDay': cutOffDay,
      'paymentDueDay': paymentDueDay,
      'isGMFExempt': isGMFExempt,
      'accountNumberMasked': accountNumberMasked,
    };
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      institutionName: map['institutionName'] ?? '',
      type: AccountType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AccountType.savings,
      ),
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (map['creditLimit'] as num?)?.toDouble(),
      cutOffDay: map['cutOffDay'],
      paymentDueDay: map['paymentDueDay'],
      isGMFExempt: map['isGMFExempt'] ?? false,
      accountNumberMasked: map['accountNumberMasked'] ?? '',
    );
  }
}
