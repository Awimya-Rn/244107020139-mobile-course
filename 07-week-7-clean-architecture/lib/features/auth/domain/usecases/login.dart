import '../../../../core/failures.dart';
import '../../../../core/format.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class Login {
  const Login(this._repository);
  final AuthRepository _repository;

  Future<({AuthSession? session, Failure? failure})> call({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      return (
        session: null,
        failure: const ValidationFailure('Email tidak boleh kosong.'),
      );
    }
    if (!isValidEmail(cleanEmail)) {
      return (
        session: null,
        failure: const ValidationFailure('Masukkan email yang valid.'),
      );
    }
    if (password.length < 6) {
      return (
        session: null,
        failure: const ValidationFailure('Kata sandi minimal 6 karakter.'),
      );
    }
    return _repository.login(email: cleanEmail, password: password);
  }
}
