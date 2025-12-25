import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inventory_app/data/repositories/auth_repository.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_inventory_app/features/item/providers/item_providers.dart';
import 'package:flutter_inventory_app/features/category/providers/category_providers.dart';
import 'package:flutter_inventory_app/features/transaction/providers/transaction_providers.dart';
import 'package:flutter_inventory_app/features/activity/providers/activity_log_providers.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final models.User? user;
  final String? errorMessage;
  final bool isPremium;
  final String? activeSubscriptionId;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isPremium = false,
    this.activeSubscriptionId,
  });

  AuthState copyWith({
    AuthStatus? status,
    models.User? user,
    String? errorMessage,
    bool? isPremium,
    String? activeSubscriptionId,
  }) {
    final bool shouldClear = status == AuthStatus.unauthenticated;
    return AuthState(
      status: status ?? this.status,
      user: shouldClear ? null : user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isPremium: shouldClear ? false : isPremium ?? this.isPremium,
      activeSubscriptionId: shouldClear ? null : activeSubscriptionId ?? this.activeSubscriptionId,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState();
  }

  AuthRepository get _authRepository => ref.watch(authRepositoryProvider);

  Future<void> _updateUserAndPremiumStatus() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      // FIX: Safely handle isPremium value which might not be a bool.
      final dynamic premiumValue = user.prefs.data['isPremium'];
      final bool isPremiumFromPrefs = (premiumValue is bool) ? premiumValue : (premiumValue.toString() == 'true');
      
      final subscriptionIdFromPrefs = user.prefs.data['activeSubscriptionId'];

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isPremium: isPremiumFromPrefs,
        activeSubscriptionId: subscriptionIdFromPrefs,
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> checkCurrentUser() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _updateUserAndPremiumStatus();
  }

  Future<bool> signUp(String email, String password, String name) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.signUp(email: email, password: password, name: name);
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      // FIX: Forcibly sign out to clear any lingering active session before logging in.
      try {
        await _authRepository.signOut();
      } catch (e) {
        // Ignore errors, as there might not be a session to clear.
        debugPrint("Ignoring error during pre-login sign-out: $e");
      }
      
      await _authRepository.signIn(email: email, password: password);
      await _updateUserAndPremiumStatus();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    debugPrint("[AUTH] signOut: Initiated. Setting status to loading.");
    state = state.copyWith(status: AuthStatus.loading);
    try {
      debugPrint("[AUTH] signOut: Calling _authRepository.signOut()...");
      await _authRepository.signOut();
      debugPrint("[AUTH] signOut: _authRepository.signOut() completed.");
      
      debugPrint("[AUTH] signOut: Invalidating user-specific providers...");
      ref.invalidate(itemsProvider);
      ref.invalidate(categoriesProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(activityLogsProvider);
      debugPrint("[AUTH] signOut: Providers invalidated.");

      debugPrint("[AUTH] signOut: Setting status to unauthenticated.");
      state = state.copyWith(status: AuthStatus.unauthenticated);
      debugPrint("[AUTH] signOut: Completed successfully.");
    } catch (e) {
      debugPrint("[AUTH] signOut: FAILED with error: $e");
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> updatePremiumStatus(bool isPremium, {String? productId}) async {
    try {
      await _authRepository.updatePremiumStatus(isPremium, productId);
      state = state.copyWith(isPremium: isPremium, activeSubscriptionId: productId);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
  
  Future<models.User?> getCurrentUser() {
    return _authRepository.getCurrentUser();
  }

  void resetStateToInitial() {}
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

final currentUserProvider = Provider<models.User?>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.user;
});