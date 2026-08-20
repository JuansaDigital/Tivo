import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final biometricEnabledProvider = StateNotifierProvider<BiometricNotifier, bool>((ref) {
  return BiometricNotifier();
});

class BiometricNotifier extends StateNotifier<bool> {
  BiometricNotifier() : super(StorageService.loadBiometricEnabled());

  void toggle(bool enabled) {
    state = enabled;
    StorageService.saveBiometricEnabled(enabled);
  }
}

final userPinProvider = StateNotifierProvider<PinNotifier, String>((ref) {
  return PinNotifier();
});

class PinNotifier extends StateNotifier<String> {
  PinNotifier() : super(StorageService.loadUserPin());

  void updatePin(String newPin) {
    state = newPin;
    StorageService.saveUserPin(newPin);
  }
}

final autoLockProvider = StateNotifierProvider<AutoLockNotifier, String>((ref) {
  return AutoLockNotifier();
});

class AutoLockNotifier extends StateNotifier<String> {
  AutoLockNotifier() : super(StorageService.loadAutoLockDuration());

  void setDuration(String duration) {
    state = duration;
    StorageService.saveAutoLockDuration(duration);
  }
}

