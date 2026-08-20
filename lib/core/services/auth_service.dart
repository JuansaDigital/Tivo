import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile_model.dart';
import 'storage_service.dart';

enum AuthProviderType {
  email,
  google,
  localPin,
}

class AuthUserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final AuthProviderType providerType;
  final DateTime createdAt;

  const AuthUserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.providerType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'providerType': providerType.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuthUserModel.fromMap(Map<String, dynamic> map) {
    return AuthUserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      providerType: AuthProviderType.values.firstWhere(
        (e) => e.name == map['providerType'],
        orElse: () => AuthProviderType.email,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }
}

class AuthService {
  static const String _keyAuthUser = 'tivo_auth_user';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Retorna el usuario actualmente autenticado en la sesión activa
  static AuthUserModel? getCurrentUser() {
    final raw = _prefs?.getString(_keyAuthUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AuthUserModel.fromMap(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }
  /// Registro con correo y contraseña
  static Future<AuthUserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    String avatarIconId = 'wallet',
    int avatarColorIndex = 0,
  }) async {
    await init();
    final cleanEmail = email.trim().toLowerCase();
    String uid = const Uuid().v4();

    if (Firebase.apps.isNotEmpty) {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        if (credential.user != null) {
          uid = credential.user!.uid;
          await credential.user!.updateDisplayName(name.trim());
          try {
            await credential.user!.sendEmailVerification();
          } catch (_) {}
        } else {
          throw Exception('No se pudo completar el registro en Firebase.');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          throw Exception('El correo electrónico ya está registrado. Inicia sesión.');
        } else if (e.code == 'weak-password') {
          throw Exception('La contraseña es muy débil. Debe tener al menos 6 caracteres.');
        } else if (e.code == 'invalid-email') {
          throw Exception('El formato del correo electrónico es inválido.');
        } else {
          throw Exception(e.message ?? 'Error al registrar la cuenta.');
        }
      } catch (e) {
        rethrow;
      }
    }

    final user = AuthUserModel(
      uid: uid,
      email: cleanEmail,
      displayName: name.trim(),
      providerType: AuthProviderType.email,
      createdAt: DateTime.now(),
    );

    await _prefs?.setString(_keyAuthUser, jsonEncode(user.toMap()));

    final profile = UserProfileModel(
      name: name.trim(),
      email: cleanEmail,
      avatarIconId: avatarIconId,
      avatarColorIndex: avatarColorIndex,
      isCompleted: true,
    );
    await StorageService.saveUserProfile(profile);

    return user;
  }

  /// Inicio de sesión con correo y contraseña
  static Future<AuthUserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await init();
    final cleanEmail = email.trim().toLowerCase();
    String uid = const Uuid().v4();

    final existingProfile = StorageService.loadUserProfile();
    String displayName = existingProfile?.name.isNotEmpty == true
        ? existingProfile!.name
        : cleanEmail.split('@').first;

    if (Firebase.apps.isNotEmpty) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        if (credential.user != null) {
          uid = credential.user!.uid;
          if (credential.user!.displayName != null && credential.user!.displayName!.isNotEmpty) {
            displayName = credential.user!.displayName!;
          }
        } else {
          throw Exception('No se pudo autenticar la cuenta.');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          throw Exception('No existe una cuenta registrada con este correo.');
        } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          throw Exception('La contraseña ingresada es incorrecta.');
        } else if (e.code == 'invalid-email') {
          throw Exception('El formato del correo es inválido.');
        } else {
          throw Exception(e.message ?? 'Error de autenticación.');
        }
      } catch (e) {
        rethrow;
      }
    }

    final user = AuthUserModel(
      uid: uid,
      email: cleanEmail,
      displayName: displayName,
      providerType: AuthProviderType.email,
      createdAt: DateTime.now(),
    );

    await _prefs?.setString(_keyAuthUser, jsonEncode(user.toMap()));

    if (existingProfile == null || !existingProfile.isCompleted) {
      await StorageService.saveUserProfile(
        UserProfileModel(
          name: displayName,
          email: cleanEmail,
          avatarIconId: 'wallet',
          avatarColorIndex: 0,
          isCompleted: true,
        ),
      );
    }

    return user;
  }

  /// Inicio de sesión o registro con cuenta de Google
  static Future<AuthUserModel> signInWithGoogle({
    String? googleEmail,
    String? googleDisplayName,
    String? googlePhotoUrl,
  }) async {
    await init();
    
    String email = googleEmail ?? 'usuario.google@gmail.com';
    String name = googleDisplayName ?? 'Usuario Google';
    String? photo = googlePhotoUrl;
    String uid = 'google_${const Uuid().v4().substring(0, 8)}';

    if (googleEmail == null && Firebase.apps.isNotEmpty) {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        
        if (googleUser == null) {
          throw Exception('Inicio de sesión con Google cancelado.');
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final user = userCredential.user;
        if (user != null) {
          email = user.email ?? email;
          name = user.displayName ?? name;
          photo = user.photoURL ?? photo;
          uid = user.uid;
        }
      } catch (e) {
        rethrow;
      }
    }

    final user = AuthUserModel(
      uid: uid,
      email: email,
      displayName: name,
      photoUrl: photo,
      providerType: AuthProviderType.google,
      createdAt: DateTime.now(),
    );

    await _prefs?.setString(_keyAuthUser, jsonEncode(user.toMap()));

    final existingProfile = StorageService.loadUserProfile();
    if (existingProfile == null || !existingProfile.isCompleted) {
      await StorageService.saveUserProfile(
        UserProfileModel(
          name: name,
          email: email,
          avatarIconId: 'sparkles',
          avatarColorIndex: 0,
          isCompleted: true,
        ),
      );
    } else {
      await StorageService.saveUserProfile(
        existingProfile.copyWith(
          name: existingProfile.name.isEmpty ? name : existingProfile.name,
          email: email,
          isCompleted: true,
        ),
      );
    }

    return user;
  }

  /// Cerrar sesión
  static Future<void> signOut() async {
    await init();
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _prefs?.remove(_keyAuthUser);
  }

  /// Eliminar cuenta permanentemente (Políticas de App Store / Play Store)
  static Future<void> deleteAccount() async {
    await init();
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.delete();
      await GoogleSignIn().signOut();
    } catch (_) {}
    await _prefs?.remove(_keyAuthUser);
    await StorageService.clearAllData();
  }
}
