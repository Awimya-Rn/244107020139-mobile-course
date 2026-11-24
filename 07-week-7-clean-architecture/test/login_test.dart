import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/auth/domain/usecases/login.dart';

import 'fakes.dart';

void main() {
  group('Login UseCase - Email Validation & Auth Tests', () {
    test('Login menolak email kosong dan tidak menyentuh repository', () async {
      final repo = FakeAuthRepository();
      final result = await Login(repo)(email: '   ', password: 'password123');

      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure!.message, 'Email tidak boleh kosong.');
      expect(result.session, isNull);
      expect(repo.loginCalls, 0);
    });

    test(
      'Login menolak email tanpa simbol @ dan tidak menyentuh repository',
      () async {
        final repo = FakeAuthRepository();
        final result = await Login(repo)(
          email: 'userexample.com',
          password: 'password123',
        );

        expect(result.failure, isA<ValidationFailure>());
        expect(result.failure!.message, 'Masukkan email yang valid.');
        expect(result.session, isNull);
        expect(repo.loginCalls, 0);
      },
    );

    test(
      'Login menolak email tanpa domain/TLD dan tidak menyentuh repository',
      () async {
        final repo = FakeAuthRepository();
        final result = await Login(repo)(
          email: 'user@domain',
          password: 'password123',
        );

        expect(result.failure, isA<ValidationFailure>());
        expect(result.failure!.message, 'Masukkan email yang valid.');
        expect(result.session, isNull);
        expect(repo.loginCalls, 0);
      },
    );

    test(
      'Login menolak email dengan format cacat (@domain.com, user@, user@.com)',
      () async {
        final repo = FakeAuthRepository();

        final invalidEmails = [
          '@domain.com',
          'user@',
          'user@.com',
          'user @domain.com',
          'user@domain..com',
        ];

        for (final email in invalidEmails) {
          final result = await Login(repo)(
            email: email,
            password: 'password123',
          );
          expect(
            result.failure,
            isA<ValidationFailure>(),
            reason: 'Email "$email" seharusnya ditolak.',
          );
          expect(result.failure!.message, 'Masukkan email yang valid.');
          expect(result.session, isNull);
        }

        expect(
          repo.loginCalls,
          0,
          reason: 'Repository tidak boleh dipanggil untuk email cacat.',
        );
      },
    );

    test('Login menolak kata sandi kurang dari 6 karakter', () async {
      final repo = FakeAuthRepository();
      final result = await Login(repo)(
        email: 'user@example.com',
        password: '123',
      );

      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure!.message, 'Kata sandi minimal 6 karakter.');
      expect(result.session, isNull);
      expect(repo.loginCalls, 0);
    });

    test('Login men-trim email valid lalu memanggil repository', () async {
      final repo = FakeAuthRepository();
      final result = await Login(repo)(
        email: '  mahasiswa@polinema.ac.id  ',
        password: 'password123',
      );

      expect(result.failure, isNull);
      expect(result.session, isNotNull);
      expect(result.session!.access, contains('mahasiswa@polinema.ac.id'));
      expect(repo.loginCalls, 1);
      expect(repo.lastEmail, 'mahasiswa@polinema.ac.id');
    });

    test(
      'Login meneruskan failure dari repository ketika terjadi kesalahan jaringan',
      () async {
        final repo = FakeAuthRepository(fail: true);
        final result = await Login(repo)(
          email: 'demo@kampus.test',
          password: 'password123',
        );

        expect(result.failure, isA<NetworkFailure>());
        expect(result.session, isNull);
        expect(repo.loginCalls, 1);
      },
    );
  });
}
