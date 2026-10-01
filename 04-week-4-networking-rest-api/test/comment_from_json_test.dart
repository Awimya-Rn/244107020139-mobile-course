import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

/// Unit test untuk Comment.fromJson — memastikan parsing tetap aman
/// meskipun field hilang atau bernilai null.
void main() {
  group('Comment.fromJson', () {
    // -------------------------------------------------------------------
    // Test utama: fromJson dengan field yang hilang.
    //
    // Skenario ini mensimulasikan respons API yang tidak lengkap —
    // misalnya server mengirim JSON tanpa key `name` dan `email`.
    // Kita memastikan bahwa Comment tetap terbentuk dengan nilai default
    // (0 untuk int, '' untuk String) tanpa melempar exception.
    // -------------------------------------------------------------------
    test('mengembalikan nilai default jika field hilang', () {
      // JSON hanya berisi `postId` dan `body`, sisanya hilang.
      final json = <String, dynamic>{
        'postId': 1,
        'body': 'Komentar parsial',
      };

      // Parsing harus berhasil tanpa throw.
      final comment = Comment.fromJson(json);

      // Field yang ada di JSON harus ter-parse dengan benar.
      expect(comment.postId, 1);
      expect(comment.body, 'Komentar parsial');

      // Field yang hilang harus menggunakan nilai default.
      expect(comment.id, 0, reason: 'id hilang → default 0');
      expect(comment.name, '', reason: 'name hilang → default string kosong');
      expect(comment.email, '', reason: 'email hilang → default string kosong');
    });

    // -------------------------------------------------------------------
    // Test tambahan: fromJson dengan semua field bernilai null eksplisit.
    // -------------------------------------------------------------------
    test('mengembalikan nilai default jika semua field null', () {
      final json = <String, dynamic>{
        'postId': null,
        'id': null,
        'name': null,
        'email': null,
        'body': null,
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 0);
      expect(comment.id, 0);
      expect(comment.name, '');
      expect(comment.email, '');
      expect(comment.body, '');
    });

    // -------------------------------------------------------------------
    // Test kontrol: fromJson dengan semua field lengkap dan valid.
    // -------------------------------------------------------------------
    test('mem-parse JSON lengkap dengan benar', () {
      final json = <String, dynamic>{
        'postId': 1,
        'id': 5,
        'name': 'Test User',
        'email': 'test@example.com',
        'body': 'Isi komentar lengkap.',
      };

      final comment = Comment.fromJson(json);

      expect(comment.postId, 1);
      expect(comment.id, 5);
      expect(comment.name, 'Test User');
      expect(comment.email, 'test@example.com');
      expect(comment.body, 'Isi komentar lengkap.');
    });

    // -------------------------------------------------------------------
    // Edge case: field integer berisi tipe double (misalnya 3.9).
    //
    // Beberapa API atau decode JSON bisa mengirim angka sebagai double.
    // Jika kita cast langsung `as int`, akan throw TypeError.
    // Dengan pola `as num?` + `.toInt()`, nilai di-truncate menjadi 3
    // tanpa crash — inilah alasan kita cast ke num? terlebih dahulu.
    // -------------------------------------------------------------------
    test('menangani field integer bertipe double tanpa crash', () {
      final json = <String, dynamic>{
        'postId': 3.9,
        'id': 7.2,
        'name': 'Edge Case',
        'email': 'edge@case.com',
        'body': 'double to int',
      };

      final comment = Comment.fromJson(json);

      // double di-truncate ke int (3.9 → 3, 7.2 → 7).
      expect(comment.postId, 3);
      expect(comment.id, 7);
      expect(comment.name, 'Edge Case');
    });
  });
}
