import 'package:flutter/material.dart';

/// Tokens de Color Oficiales de TIVO según la especificación PRD v2.5
class TivoColors {
  TivoColors._();

  // Fondos y Superficies Deep Space
  static const Color bgDeepNavy = Color(0xFF0B132B);
  static const Color bgNavyMedium = Color(0xFF141F40);
  static const Color bgSurfaceGlass = Color.fromRGBO(28, 37, 65, 0.55);
  static const Color bgSurfaceGlassLight = Color.fromRGBO(40, 52, 90, 0.40);
  static const Color bgCard = Color(0xFF1C2541);

  // Colores Primarios y Acentos Eléctricos
  static const Color primaryIceBlue = Color(0xFF38BDF8);
  static const Color accentElectricCyan = Color(0xFF06B6D4);
  static const Color accentNeonCyan = Color(0xFF22D3EE);
  static const Color accentPurple = Color(0xFF818CF8);

  // Estados Financieros
  static const Color statusIncomeGreen = Color(0xFF10B981);
  static const Color statusIncomeGreenLight = Color(0xFF34D399);
  static const Color statusExpenseRose = Color(0xFFF43F5E);
  static const Color statusExpenseRoseLight = Color(0xFFFB7185);
  static const Color statusWarningAmber = Color(0xFFF59E0B);
  static const Color statusWarningAmberLight = Color(0xFFFBBF24);

  // Textos y Contraste
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF475569);

  // Bordes y Resplandor Glassmorphism (135 grados)
  static const Color glassBorderStart = Color.fromRGBO(255, 255, 255, 0.22);
  static const Color glassBorderEnd = Color.fromRGBO(6, 182, 212, 0.05);
  static const Color glassHighlight = Color.fromRGBO(255, 255, 255, 0.12);

  // Gradiente Principal de Fondo
  static const LinearGradient deepSpaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B132B),
      Color(0xFF111D42),
      Color(0xFF070C1D),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  // Gradiente Hero para Tarjetas Clave (Safe-to-Spend / CDT)
  static const LinearGradient heroGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x3338BDF8),
      Color(0x1A06B6D4),
      Color(0x0D0B132B),
    ],
  );
}
