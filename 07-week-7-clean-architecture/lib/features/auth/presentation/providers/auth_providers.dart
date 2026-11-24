import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final loginUseCaseProvider = Provider<Login>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return Login(repository);
});

class AuthState {
  const AuthState({this.session, this.errorMessage, this.isLoading = false});

  final AuthSession? session;
  final String? errorMessage;
  final bool isLoading;

  bool get isAuthenticated => session != null;
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login({required String email, required String password}) async {
    state = const AuthState(isLoading: true);
    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(email: email, password: password);

    if (result.failure != null) {
      state = AuthState(
        errorMessage: result.failure!.message,
        isLoading: false,
      );
      return false;
    }

    state = AuthState(session: result.session, isLoading: false);
    return true;
  }

  void logout() {
    state = const AuthState();
  }
}
