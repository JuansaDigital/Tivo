import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/tivo_colors.dart';
import '../../../core/constants/tivo_spacing.dart';
import '../../../core/providers/profile_provider.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/tivo_button.dart';
import 'auth_screen.dart';
import 'lock_screen.dart';
import 'onboarding_profile_screen.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF070E22),
      body: Stack(
        children: [
          // Background ambient gradient orbs
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TivoColors.accentElectricCyan.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    TivoColors.primaryIceBlue.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // 3D TIVO Logo with Ambient Glow
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft Ambient Backlight Glow
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: TivoColors.accentElectricCyan.withOpacity(0.45),
                                blurRadius: 45,
                                spreadRadius: 8,
                              ),
                              BoxShadow(
                                color: TivoColors.primaryIceBlue.withOpacity(0.25),
                                blurRadius: 25,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        // Crisp 3D Tivo Logo
                        Image.asset(
                          'assets/images/tivo_logo.png',
                          width: 160,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Brand Title
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        TivoColors.accentElectricCyan,
                        TivoColors.primaryIceBlue,
                        Colors.white,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'TIVO',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tagline
                  const Text(
                    'Tu Asistente Inteligente de Finanzas Personales',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TivoColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Feature highlight cards
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    borderRadius: TivoSpacing.radiusLg,
                    child: Column(
                      children: [
                        _buildFeatureRow(
                          icon: LucideIcons.trendingUp,
                          iconColor: TivoColors.statusIncomeGreen,
                          title: 'Control Total y Sincronizado',
                          subtitle: 'Cuentas, tarjetas, gastos e ingresos en tiempo real.',
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _buildFeatureRow(
                          icon: LucideIcons.pieChart,
                          iconColor: TivoColors.accentElectricCyan,
                          title: 'Análisis Gráfico Inteligente',
                          subtitle: 'Visualización clara en barras, círculos y calendario.',
                        ),
                        const Divider(color: Colors.white10, height: 20),
                        _buildFeatureRow(
                          icon: LucideIcons.shieldCheck,
                          iconColor: TivoColors.primaryIceBlue,
                          title: 'Seguridad & Metas de Ahorro',
                          subtitle: 'Alertas de corte, retos financieros y acceso protegido.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Google Sign-In Button
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    borderRadius: TivoSpacing.radiusLg,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AuthScreen(initialIsSignUp: false)),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            'G',
                            style: TextStyle(
                              color: Color(0xFFEA4335),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Continuar con Google',
                          style: TextStyle(
                            color: TivoColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Login / Register CTA Button
                  TivoButton(
                    label: ref.watch(userProfileProvider).isCompleted
                        ? 'Iniciar Sesión / PIN'
                        : 'Comenzar / Crear Perfil',
                    icon: ref.watch(userProfileProvider).isCompleted
                        ? LucideIcons.logIn
                        : LucideIcons.userPlus,
                    onPressed: () {
                      final isProfileDone = ref.read(userProfileProvider).isCompleted;
                      if (!isProfileDone) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OnboardingProfileScreen()),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LockScreen()),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 14),

                  // Crear cuenta con correo
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AuthScreen(initialIsSignUp: true)),
                      );
                    },
                    child: const Text(
                      '¿No tienes cuenta? Regístrate con correo',
                      style: TextStyle(
                        color: TivoColors.primaryIceBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'TIVO v2.0 • Ecosistema Financiero Seguro',
                    style: TextStyle(
                      color: TivoColors.textTertiary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: TivoColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: TivoColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
