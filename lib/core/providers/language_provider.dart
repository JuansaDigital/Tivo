import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

enum AppLanguage {
  es('Español', 'es'),
  en('English', 'en');

  final String label;
  final String code;
  const AppLanguage(this.label, this.code);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (l) => l.code.toLowerCase() == code.toLowerCase(),
      orElse: () => AppLanguage.es,
    );
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<AppLanguage> {
  LanguageNotifier() : super(_initialLanguage());

  static AppLanguage _initialLanguage() {
    final savedCode = StorageService.loadLanguage();
    return AppLanguage.fromCode(savedCode);
  }

  void setLanguage(AppLanguage lang) {
    state = lang;
    StorageService.saveLanguage(lang.code);
  }
}

// Catálogo centralizado de traducciones en tiempo real para Español e Inglés
const Map<AppLanguage, Map<String, String>> translations = {
  AppLanguage.es: {
    // Navegación Inferior
    'nav_home': 'Inicio',
    'nav_finances': 'Finanzas',
    'nav_reminders': 'Recordatorios',
    'nav_tips': 'Tips',

    // Pantalla de Configuraciones
    'settings_title': 'Configuraciones',
    'user_profile': 'Perfil de Usuario',
    'security_privacy': 'Seguridad y Privacidad',
    'biometric_login': 'Login Biométrico',
    'biometric_login_desc': 'Permitir acceso rápido con Face ID / Huella',
    'change_pin': 'Cambiar PIN de Acceso',
    'change_pin_desc': 'PIN actual configurado:',
    'privacy_mode': 'Modo Oculto / Privacidad',
    'privacy_mode_desc': 'Ocultar montos y balances sensibles (••••••)',
    'auto_lock': 'Bloqueo Automático',
    'auto_lock_immediate': 'Inmediato',
    'auto_lock_1min': '1 minuto',
    'auto_lock_5min': '5 minutos',
    'auto_lock_never': 'Nunca',
    'logout_lock': 'Bloquear / Cerrar Sesión',
    'logout_lock_desc': 'Volver a la pantalla de bienvenida y bloqueo',
    'preferences_section': 'Preferencias',
    'language': 'Idioma',
    'main_currency': 'Moneda Principal',
    'save_preferences': 'Guardar Preferencias',
    'preferences_saved_msg': '¡Preferencias guardadas exitosamente! ✨',
    'data_management': 'Gestión de Datos & Almacenamiento',
    'load_demo': 'Cargar Datos de Ejemplo (Demo)',
    'load_demo_desc': 'Poblar la app con datos financieros de demostración',
    'demo_loaded_msg': 'Datos de demostración cargados con éxito.',
    'delete_all': 'Borrar todos los datos (\$0)',
    'delete_all_desc': 'Reiniciar la app limpia en \$0 para tus propios datos',
    'delete_dialog_title': 'Borrar todos los datos',
    'delete_dialog_desc': '¿Estás seguro de que deseas eliminar permanentemente todas tus cuentas, números, ingresos, gastos, presupuestos y metas? Esta acción dejará la app en 0.',
    'delete_confirm_btn': 'Eliminar Todo',
    'delete_success_msg': 'Toda la información financiera ha sido borrada con éxito (\$0).',
    'cancel': 'Cancelar',
    'save_pin_btn': 'Guardar PIN',
    'current_pin_label': 'PIN Actual',
    'new_pin_label': 'Nuevo PIN (4 dígitos)',
    'confirm_pin_label': 'Confirmar Nuevo PIN',
    'pin_mismatch_current': 'El PIN actual no coincide.',
    'pin_invalid_length': 'El nuevo PIN debe tener exactamente 4 dígitos numéricos.',
    'pin_mismatch_new': 'Los nuevos PINs no coinciden.',
    'pin_success_updated': '¡PIN actualizado correctamente! 🔒',

    // Pantalla de Bloqueo / Auth
    'welcome_login': 'Iniciar Sesión / Login',
    'lock_title': 'Ingresa tu PIN de Seguridad',
    'lock_subtitle': 'Ingresa tu PIN de 4 dígitos para ingresar',
    'pin_setup_label': 'PIN de Seguridad (4 dígitos)',
    'pin_confirm_label': 'Confirmar PIN (4 dígitos)',
    'lock_pin_wrong': 'PIN incorrecto.',
    'lock_biometric_reason': 'Autentícate para acceder a tu panel de TIVO',
    'lock_biometric_disabled': 'El acceso biométrico está desactivado en Configuraciones.',
    'lock_biometric_fallback': 'Usa tu PIN de seguridad para ingresar',
    'lock_biometric_btn': 'Face ID / Huella',
    'lock_delete_btn': 'Borrar',

    // Flujo de Caja Real & Dashboard
    'cashflow_title': 'Flujo de Caja Real',
    'cashflow_subtitle': 'Últimos 7 días sincronizados',
    'income': 'Ingresos',
    'expense': 'Gastos',
    'today': 'Hoy',
    'no_movements_7d': 'Sin movimientos en los últimos 7 días (\$0)',
    'net_worth': 'Patrimonio Neto',
    'total_liquid_cash': 'Activos',
    'total_debt': 'Deudas',
    'safe_to_spend_today': 'Disponible para hoy',
    'safe_to_spend_month': 'Disponible este mes',
    'quick_actions': 'Acciones Rápidas',
    'recent_transactions': 'Transacciones Recientes',
    'view_all': 'Ver Todo',
  },
  AppLanguage.en: {
    // Bottom Navigation
    'nav_home': 'Home',
    'nav_finances': 'Finances',
    'nav_reminders': 'Reminders',
    'nav_tips': 'Tips',

    // Settings Screen
    'settings_title': 'Settings',
    'user_profile': 'User Profile',
    'security_privacy': 'Security & Privacy',
    'biometric_login': 'Biometric Login',
    'biometric_login_desc': 'Enable fast access with Face ID / Fingerprint',
    'change_pin': 'Change Access PIN',
    'change_pin_desc': 'Current configured PIN:',
    'privacy_mode': 'Privacy / Stealth Mode',
    'privacy_mode_desc': 'Hide sensitive amounts and balances (••••••)',
    'auto_lock': 'Auto-Lock',
    'auto_lock_immediate': 'Immediate',
    'auto_lock_1min': '1 minute',
    'auto_lock_5min': '5 minutes',
    'auto_lock_never': 'Never',
    'logout_lock': 'Lock / Log Out',
    'logout_lock_desc': 'Return to welcome and lock screen',
    'preferences_section': 'Preferences',
    'language': 'Language',
    'main_currency': 'Main Currency',
    'save_preferences': 'Save Preferences',
    'preferences_saved_msg': 'Preferences saved successfully! ✨',
    'data_management': 'Data Management & Storage',
    'load_demo': 'Load Demo Data',
    'load_demo_desc': 'Populate the app with demo financial data',
    'demo_loaded_msg': 'Demo data loaded successfully.',
    'delete_all': 'Clear All Data (\$0)',
    'delete_all_desc': 'Reset app clean to \$0 to enter your own data',
    'delete_dialog_title': 'Delete All Data',
    'delete_dialog_desc': 'Are you sure you want to permanently delete all your accounts, numbers, income, expenses, budgets and goals? This will reset the app to 0.',
    'delete_confirm_btn': 'Delete Everything',
    'delete_success_msg': 'All financial data has been successfully cleared (\$0).',
    'cancel': 'Cancel',
    'save_pin_btn': 'Save PIN',
    'current_pin_label': 'Current PIN',
    'new_pin_label': 'New PIN (4 digits)',
    'confirm_pin_label': 'Confirm New PIN',
    'pin_mismatch_current': 'Current PIN does not match.',
    'pin_invalid_length': 'New PIN must be exactly 4 numeric digits.',
    'pin_mismatch_new': 'New PINs do not match.',
    'pin_success_updated': 'PIN updated successfully! 🔒',

    // Lock Screen / Auth
    'welcome_login': 'Log In / Sign In',
    'lock_title': 'Enter Your Security PIN',
    'lock_subtitle': 'Enter your 4-digit security PIN to enter',
    'pin_setup_label': 'Security PIN (4 digits)',
    'pin_confirm_label': 'Confirm PIN (4 digits)',
    'lock_pin_wrong': 'Incorrect PIN.',
    'lock_biometric_reason': 'Authenticate to access your TIVO dashboard',
    'lock_biometric_disabled': 'Biometric access is disabled in Settings.',
    'lock_biometric_fallback': 'Use your security PIN to enter',
    'lock_biometric_btn': 'Face ID / Fingerprint',
    'lock_delete_btn': 'Delete',

    // Cashflow & Dashboard
    'cashflow_title': 'Real Cash Flow',
    'cashflow_subtitle': 'Last 7 synchronized days',
    'income': 'Income',
    'expense': 'Expenses',
    'today': 'Today',
    'no_movements_7d': 'No movements in the last 7 days (\$0)',
    'net_worth': 'Net Worth',
    'total_liquid_cash': 'Assets',
    'total_debt': 'Debts',
    'safe_to_spend_today': 'Safe to spend today',
    'safe_to_spend_month': 'Safe to spend this month',
    'quick_actions': 'Quick Actions',
    'recent_transactions': 'Recent Transactions',
    'view_all': 'View All',
  },
};

String translate(AppLanguage lang, String key) {
  return translations[lang]?[key] ?? translations[AppLanguage.es]?[key] ?? key;
}

final stringsProvider = Provider<Map<String, String>>((ref) {
  final lang = ref.watch(languageProvider);
  return translations[lang] ?? translations[AppLanguage.es]!;
});

