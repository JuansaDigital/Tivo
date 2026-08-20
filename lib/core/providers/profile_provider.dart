import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import '../services/storage_service.dart';

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileModel>((ref) {
  return UserProfileNotifier();
});

class UserProfileNotifier extends StateNotifier<UserProfileModel> {
  UserProfileNotifier() : super(_getInitialProfile());

  static UserProfileModel _getInitialProfile() {
    final stored = StorageService.loadUserProfile();
    if (stored != null) return stored;
    return const UserProfileModel(
      name: '',
      email: '',
      avatarIconId: 'wallet',
      avatarColorIndex: 0,
      isCompleted: false,
    );
  }

  void completeProfile({
    required String name,
    required String email,
    required String avatarIconId,
    int avatarColorIndex = 0,
  }) {
    final updated = UserProfileModel(
      name: name.trim(),
      email: email.trim(),
      avatarIconId: avatarIconId,
      avatarColorIndex: avatarColorIndex,
      isCompleted: true,
    );
    state = updated;
    StorageService.saveUserProfile(updated);
  }

  void updateProfile({
    String? name,
    String? email,
    String? avatarIconId,
    int? avatarColorIndex,
  }) {
    final updated = state.copyWith(
      name: name?.trim(),
      email: email?.trim(),
      avatarIconId: avatarIconId,
      avatarColorIndex: avatarColorIndex,
      isCompleted: true,
    );
    state = updated;
    StorageService.saveUserProfile(updated);
  }

  void reset() {
    state = const UserProfileModel(
      name: '',
      email: '',
      avatarIconId: 'wallet',
      avatarColorIndex: 0,
      isCompleted: false,
    );
    StorageService.saveUserProfile(state);
  }
}
