import '../../../../core/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/auth_session_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      return (
        session: AuthSessionModel(
          access: 'mock-access-for-$email',
          refresh: 'mock-refresh-for-$email',
        ),
        failure: null,
      );
    } catch (e) {
      return (session: null, failure: NetworkFailure('Autentikasi gagal: $e'));
    }
  }

  @override
  Future<({String? access, Failure? failure})> refresh(
    String refreshToken,
  ) async {
    try {
      if (!refreshToken.startsWith('mock-refresh-for-')) {
        return (
          access: null,
          failure: const LocalFailure('Refresh token tidak valid.'),
        );
      }
      return (
        access: 'mock-access-renewed-${DateTime.now().microsecondsSinceEpoch}',
        failure: null,
      );
    } catch (e) {
      return (
        access: null,
        failure: NetworkFailure('Gagal memperbarui token: $e'),
      );
    }
  }
}
