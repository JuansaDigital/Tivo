import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FinancialAvatarOption {
  final String id;
  final String label;
  final IconData icon;

  const FinancialAvatarOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class UserProfileModel {
  final String name;
  final String email;
  final String avatarIconId;
  final int avatarColorIndex;
  final bool isCompleted;

  const UserProfileModel({
    required this.name,
    required this.email,
    this.avatarIconId = 'wallet',
    this.avatarColorIndex = 0,
    this.isCompleted = false,
  });

  static const List<FinancialAvatarOption> availableAvatars = [
    FinancialAvatarOption(id: 'wallet', label: 'Billetera', icon: LucideIcons.wallet),
    FinancialAvatarOption(id: 'landmark', label: 'Banca', icon: LucideIcons.landmark),
    FinancialAvatarOption(id: 'trending_up', label: 'Crecimiento', icon: LucideIcons.trendingUp),
    FinancialAvatarOption(id: 'gem', label: 'Patrimonio', icon: LucideIcons.gem),
    FinancialAvatarOption(id: 'rocket', label: 'Acelerador', icon: LucideIcons.rocket),
    FinancialAvatarOption(id: 'crown', label: 'Finanzas Top', icon: LucideIcons.crown),
    FinancialAvatarOption(id: 'shield_check', label: 'Blindaje', icon: LucideIcons.shieldCheck),
    FinancialAvatarOption(id: 'coins', label: 'Efectivo', icon: LucideIcons.coins),
    FinancialAvatarOption(id: 'briefcase', label: 'Negocios', icon: LucideIcons.briefcase),
    FinancialAvatarOption(id: 'pie_chart', label: 'Inversor', icon: LucideIcons.pieChart),
    FinancialAvatarOption(id: 'badge_dollar_sign', label: 'Rentabilidad', icon: LucideIcons.badgeDollarSign),
    FinancialAvatarOption(id: 'sparkles', label: 'Libertad', icon: LucideIcons.sparkles),
  ];

  static const List<List<Color>> avatarGradients = [
    [Color(0xFF38BDF8), Color(0xFF0284C7)], // Ice Cyan
    [Color(0xFF10B981), Color(0xFF059669)], // Emerald
    [Color(0xFFA855F7), Color(0xFF7C3AED)], // Purple
    [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber Gold
    [Color(0xFFF43F5E), Color(0xFFE11D48)], // Rose Ruby
    [Color(0xFF6366F1), Color(0xFF4F46E5)], // Indigo
  ];

  IconData get iconData {
    return availableAvatars.firstWhere(
      (a) => a.id == avatarIconId,
      orElse: () => availableAvatars.first,
    ).icon;
  }

  List<Color> get gradientColors {
    if (avatarColorIndex >= 0 && avatarColorIndex < avatarGradients.length) {
      return avatarGradients[avatarColorIndex];
    }
    return avatarGradients.first;
  }

  String get initials {
    if (name.trim().isEmpty) return 'T';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String get firstName {
    if (name.trim().isEmpty) return 'Usuario';
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.first;
  }

  UserProfileModel copyWith({
    String? name,
    String? email,
    String? avatarIconId,
    int? avatarColorIndex,
    bool? isCompleted,
  }) {
    return UserProfileModel(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarIconId: avatarIconId ?? this.avatarIconId,
      avatarColorIndex: avatarColorIndex ?? this.avatarColorIndex,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'avatarIconId': avatarIconId,
      'avatarColorIndex': avatarColorIndex,
      'isCompleted': isCompleted,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarIconId: map['avatarIconId'] ?? 'wallet',
      avatarColorIndex: map['avatarColorIndex'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
