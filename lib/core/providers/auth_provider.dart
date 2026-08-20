import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'profile_provider.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthUserModel?>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthUserModel?> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(AuthService.getCurrentUser());

  Future<void> signInWithGoogle({
    String? googleEmail,
    String? googleDisplayName,
    String? googlePhotoUrl,
  }) async {
    final user = await AuthService.signInWithGoogle(
      googleEmail: googleEmail,
      googleDisplayName: googleDisplayName,
      googlePhotoUrl: googlePhotoUrl,
    );
    state = user;
    // Sincronizar perfil
    _ref.read(userProfileProvider.notifier).updateProfile(
      name: user.displayName,
      email: user.email,
    );
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String avatarIconId = 'wallet',
    int avatarColorIndex = 0,
  }) async {
    final user = await AuthService.signUpWithEmail(
      name: name,
      email: email,
      password: password,
      avatarIconId: avatarIconId,
      avatarColorIndex: avatarColorIndex,
    );
    state = user;
    _ref.read(userProfileProvider.notifier).completeProfile(
      name: name,
      email: email,
      avatarIconId: avatarIconId,
      avatarColorIndex: avatarColorIndex,
    );
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = await AuthService.signInWithEmail(
      email: email,
      password: password,
    );
    state = user;
    _ref.read(userProfileProvider.notifier).updateProfile(
      name: user.displayName,
      email: user.email,
    );
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    state = null;
  }

  Future<void> deleteAccount() async {
    await AuthService.deleteAccount();
    state = null;
    _ref.read(userProfileProvider.notifier).reset();
  }
}
