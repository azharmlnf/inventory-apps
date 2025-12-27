import 'dart:async';

import 'package:appwrite/models.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';
import 'package:flutter_inventory_app/data/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_controller.g.dart';

@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  Future<User?> build() async {
    final account = ref.read(appwriteAccountProvider);
    try {
      return await account.get();
    } catch (_) {
      return null;
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.signUp(email: email, password: password, name: name);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    
    final account = ref.read(appwriteAccountProvider);
    try {
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      final user = await account.get();
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    final account = ref.read(appwriteAccountProvider);
    try {
      await account.deleteSession(sessionId: 'current');
    } finally {
      state = const AsyncData(null);
    }
  }

  Future<void> updatePremiumStatus(bool isPremium, {String? productId}) async {
    final account = ref.read(appwriteAccountProvider);
    final user = state.value;
    if (user == null) return;
    
    try {
      final currentPrefs = await account.getPrefs();
      final newPrefs = Map<String, dynamic>.from(currentPrefs.data);
      
      newPrefs['isPremium'] = isPremium;
      if (productId != null) {
        newPrefs['activeSubscriptionId'] = productId;
      } else if (!isPremium) {
        newPrefs.remove('activeSubscriptionId');
      }

      await account.updatePrefs(prefs: newPrefs);
      
      ref.invalidateSelf();
    } catch (e) {
      // Handle or log error
    }
  }
}
