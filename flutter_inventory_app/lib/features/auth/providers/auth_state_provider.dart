import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_inventory_app/data/repositories/auth_repository.dart';
import 'package:appwrite/models.dart' as models;

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final models.User? user;
  final String? errorMessage;
  final bool isPremium;

  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isPremium = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    models.User? user,
    String? errorMessage,
    bool? isPremium,
  }) {
    // When status is unauthenticated, user and isPremium should be cleared.
    final bool shouldClear = status == AuthStatus.unauthenticated;
    return AuthState(
      status: status ?? this.status,
      user: shouldClear ? null : user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isPremium: shouldClear ? false : isPremium ?? this.isPremium,
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
      final isPremium = await _authRepository.isUserPremium();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isPremium: isPremium,
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
      await _authRepository.signIn(email: email, password: password);
      await _updateUserAndPremiumStatus();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _authRepository.signOut();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> updatePremiumStatus(bool isPremium) async {
    try {
      await _authRepository.updatePremiumStatus(isPremium);
      state = state.copyWith(isPremium: isPremium);
    } catch (e) {
      // Optionally handle or rethrow the error
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