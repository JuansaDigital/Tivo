import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/tivo_colors.dart';
import '../../core/constants/tivo_spacing.dart';
import '../dashboard/presentation/dashboard_screen.dart';
import '../habits/presentation/tips_academy_screen.dart';
import '../reminders/presentation/reminders_screen.dart';
import '../transactions/presentation/finances_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(onNavigateTab: _onTabSelected),
      const FinancesScreen(),
      const RemindersScreen(),
      const TipsAcademyScreen(),
    ];

    return Scaffold(
      backgroundColor: TivoColors.bgDeepNavy,
      extendBody: true,
      body: Stack(
        children: [
          // Capa 0: Fondo Profundo con degradado espacial y resplandores
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TivoColors.bgDeepNavy,
                    TivoColors.bgNavyMedium,
                    Color(0xFF070E22),
                  ],
                ),
              ),
            ),
          ),
          // Resplandor ambiental superior en Ice Blue
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TivoColors.primaryIceBlue.withOpacity(0.12),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: const SizedBox(),
              ),
            ),
          ),
          // Resplandor ambiental inferior en Electric Cyan
          Positioned(
            bottom: 40,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TivoColors.accentElectricCyan.withOpacity(0.10),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),
          ),

          // Pantalla Activa
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
        ],
      ),
      // Barra Inferior Glassmorphic Flotante (Glass Floating Dock)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: TivoColors.bgSurfaceGlass,
                    borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.14),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: LucideIcons.layoutGrid,
                        label: 'Inicio',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: LucideIcons.wallet,
                        label: 'Finanzas',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: LucideIcons.alarmClock,
                        label: 'Recordatorios',
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: LucideIcons.lightbulb,
                        label: 'Tips',
                        index: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? TivoColors.primaryIceBlue.withOpacity(0.20)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(TivoSpacing.radiusPill),
          border: isSelected
              ? Border.all(color: TivoColors.primaryIceBlue.withOpacity(0.40), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? TivoColors.primaryIceBlue
                  : TivoColors.textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: TivoColors.primaryIceBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
