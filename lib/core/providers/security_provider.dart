import 'package:flutter_riverpod/flutter_riverpod.dart';

final biometricEnabledProvider = StateNotifierProvider<BiometricNotifier, bool>((ref) {
  return BiometricNotifier();
});

class BiometricNotifier extends StateNotifier<bool> {
  BiometricNotifier() : super(true);

  void toggle(bool enabled) {
    state = enabled;
  }
}

final userPinProvider = StateNotifierProvider<PinNotifier, String>((ref) {
  return PinNotifier();
});

class PinNotifier extends StateNotifier<String> {
  PinNotifier() : super('1234');

  void updatePin(String newPin) {
    state = newPin;
  }
}

final autoLockProvider = StateNotifierProvider<AutoLockNotifier, String>((ref) {
  return AutoLockNotifier();
});

class AutoLockNotifier extends StateNotifier<String> {
  AutoLockNotifier() : super('Inmediato');

  void setDuration(String duration) {
    state = duration;
  }
}
