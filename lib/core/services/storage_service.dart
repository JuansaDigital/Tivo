import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/accounts/domain/models/account_model.dart';
import '../../features/transactions/domain/models/transaction_model.dart';
import '../../features/savings/domain/models/savings_model.dart';
import '../../features/reminders/domain/models/reminder_model.dart';
import '../../features/budgets/domain/models/budget_model.dart';
import '../models/user_profile_model.dart';

class StorageService {
  static const String _keyAccounts = 'tivo_accounts';
  static const String _keyTransactions = 'tivo_transactions';
  static const String _keySavings = 'tivo_savings';
  static const String _keyReminders = 'tivo_reminders';
  static const String _keyBudgets = 'tivo_budgets';
  static const String _keyInitialized = 'tivo_is_initialized';
  static const String _keyLanguage = 'tivo_language';
  static const String _keyCurrency = 'tivo_currency';
  static const String _keyBiometric = 'tivo_biometric_enabled';
  static const String _keyUserPin = 'tivo_user_pin';
  static const String _keyAutoLock = 'tivo_auto_lock_duration';
  static const String _keyPrivacyMode = 'tivo_privacy_mode';
  static const String _keyUserProfile = 'tivo_user_profile';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static bool isInitialized() {
    return _prefs?.getBool(_keyInitialized) ?? false;
  }

  static Future<void> markInitialized() async {
    await _prefs?.setBool(_keyInitialized, true);
  }

  // --- Accounts ---
  static List<AccountModel> loadAccounts() {
    final raw = _prefs?.getString(_keyAccounts);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw);
      return list.map((e) => AccountModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAccounts(List<AccountModel> accounts) async {
    final list = accounts.map((e) => e.toMap()).toList();
    await _prefs?.setString(_keyAccounts, jsonEncode(list));
  }

  // --- Transactions ---
  static List<TransactionModel> loadTransactions() {
    final raw = _prefs?.getString(_keyTransactions);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw);
      return list.map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final list = transactions.map((e) => e.toMap()).toList();
    await _prefs?.setString(_keyTransactions, jsonEncode(list));
  }

  // --- Savings Goals ---
  static List<SavingsGoalModel> loadSavings() {
    final raw = _prefs?.getString(_keySavings);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw);
      return list.map((e) => SavingsGoalModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveSavings(List<SavingsGoalModel> goals) async {
    final list = goals.map((e) => e.toMap()).toList();
    await _prefs?.setString(_keySavings, jsonEncode(list));
  }

  // --- Reminders ---
  static List<ReminderModel> loadReminders() {
    final raw = _prefs?.getString(_keyReminders);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw);
      return list.map((e) => ReminderModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveReminders(List<ReminderModel> reminders) async {
    final list = reminders.map((e) => e.toMap()).toList();
    await _prefs?.setString(_keyReminders, jsonEncode(list));
  }

  // --- Budgets ---
  static List<BudgetModel> loadBudgets() {
    final raw = _prefs?.getString(_keyBudgets);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List list = jsonDecode(raw);
      return list.map((e) => BudgetModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveBudgets(List<BudgetModel> budgets) async {
    final list = budgets.map((e) => e.toMap()).toList();
    await _prefs?.setString(_keyBudgets, jsonEncode(list));
  }

  // --- Preferences & Security ---
  static String loadLanguage() {
    return _prefs?.getString(_keyLanguage) ?? 'es';
  }

  static Future<void> saveLanguage(String lang) async {
    await _prefs?.setString(_keyLanguage, lang);
  }

  static String loadCurrency() {
    return _prefs?.getString(_keyCurrency) ?? 'cop';
  }

  static Future<void> saveCurrency(String curr) async {
    await _prefs?.setString(_keyCurrency, curr);
  }

  static bool loadBiometricEnabled() {
    return _prefs?.getBool(_keyBiometric) ?? true;
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _prefs?.setBool(_keyBiometric, enabled);
  }

  static String loadUserPin() {
    final pin = _prefs?.getString(_keyUserPin) ?? '';
    if (pin == '1234') {
      _prefs?.remove(_keyUserPin);
      return '';
    }
    return pin;
  }

  static Future<void> saveUserPin(String pin) async {
    await _prefs?.setString(_keyUserPin, pin);
  }

  static String loadAutoLockDuration() {
    return _prefs?.getString(_keyAutoLock) ?? 'Inmediato';
  }

  static Future<void> saveAutoLockDuration(String duration) async {
    await _prefs?.setString(_keyAutoLock, duration);
  }

  static bool loadPrivacyMode() {
    return _prefs?.getBool(_keyPrivacyMode) ?? false;
  }

  static Future<void> savePrivacyMode(bool enabled) async {
    await _prefs?.setBool(_keyPrivacyMode, enabled);
  }

  // --- User Profile ---
  static UserProfileModel? loadUserProfile() {
    final raw = _prefs?.getString(_keyUserProfile);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(raw);
      final profile = UserProfileModel.fromMap(map);
      final authUserRaw = _prefs?.getString('tivo_auth_user');
      if (authUserRaw == null || authUserRaw.isEmpty) {
        return profile.copyWith(isCompleted: false);
      }
      return profile;
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveUserProfile(UserProfileModel profile) async {
    await _prefs?.setString(_keyUserProfile, jsonEncode(profile.toMap()));
  }

  // --- Clear All Data (Reset to 0) ---
  static Future<void> clearAllData() async {
    await _prefs?.remove(_keyAccounts);
    await _prefs?.remove(_keyTransactions);
    await _prefs?.remove(_keySavings);
    await _prefs?.remove(_keyReminders);
    await _prefs?.remove(_keyBudgets);
    await _prefs?.remove(_keyUserProfile);
    await _prefs?.remove(_keyUserPin);
    await _prefs?.remove('tivo_auth_user');
    await markInitialized();
  }
}
