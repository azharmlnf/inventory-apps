import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/core/appwrite_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final account = ref.watch(appwriteAccountProvider);
  return AuthRepository(account: account);
});

class AuthRepository {
  final Account _account;

  AuthRepository({required Account account}) : _account = account;

  Future<models.User> signUp({required String email, required String password, required String name}) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return user;
    } on AppwriteException catch (e) {
      throw e.message ?? 'An unknown error occurred during sign up.';
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<models.Session> signIn({required String email, required String password}) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return session;
    } on AppwriteException catch (e) {
      throw e.message ?? 'An unknown error occurred during sign in.';
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<void> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } on AppwriteException catch (e) {
      throw e.message ?? 'An unknown error occurred during sign out.';
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }

  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } on AppwriteException {
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Cek status premium dari user preferences.
  Future<bool> isUserPremium() async {
    try {
      final prefs = await _account.getPrefs();
      return prefs.data['isPremium'] ?? false;
    } catch (e) {
      return false; // Anggap non-premium jika ada error
    }
  }

  /// Update status premium user.
  Future<void> updatePremiumStatus(bool isPremium) async {
    try {
      await _account.updatePrefs(prefs: {'isPremium': isPremium});
    } on AppwriteException catch (e) {
      throw e.message ?? 'Gagal memperbarui status premium.';
    }
  }
}
