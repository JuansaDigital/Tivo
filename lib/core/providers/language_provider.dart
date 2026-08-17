import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLanguage { es, en }

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(AppLanguage.es);

  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

// Simple map for translating some key texts (in a real app, use intl or easy_localization)
const Map<AppLanguage, Map<String, String>> translations = {
  AppLanguage.es: {
    'settings_title': 'Configuración y Perfil',
    'language': 'Idioma',
    'currency': 'Moneda Principal',
    'security': 'Seguridad y Biometría',
    'restart_required': 'Reinicia la app para aplicar el idioma.',
  },
  AppLanguage.en: {
    'settings_title': 'Settings & Profile',
    'language': 'Language',
    'currency': 'Main Currency',
    'security': 'Security & Biometrics',
    'restart_required': 'Restart the app to apply language changes.',
  }
};

String translate(AppLanguage lang, String key) {
  return translations[lang]?[key] ?? key;
}
