import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/core/format.dart';

void main() {
  test('formatDateTime menghasilkan DD/MM/YYYY HH:mm', () {
    final dt = DateTime(2026, 9, 27, 8, 5);
    expect(formatDateTime(dt), '27/09/2026 08:05');
  });

  test('parseNoteId memvalidasi angka positif', () {
    expect(parseNoteId('12'), 12);
    expect(parseNoteId('0'), 0);
    expect(parseNoteId('-1'), isNull);
    expect(parseNoteId('abc'), isNull);
    expect(parseNoteId(null), isNull);
  });

  group('isValidEmail validator', () {
    test('menerima format email valid', () {
      expect(isValidEmail('user@polinema.ac.id'), isTrue);
      expect(isValidEmail('demo.user+test@kampus.test'), isTrue);
      expect(isValidEmail('ilham_putra@domain.co.id'), isTrue);
    });

    test('menolak format email yang tidak valid', () {
      expect(isValidEmail(null), isFalse);
      expect(isValidEmail(''), isFalse);
      expect(isValidEmail('   '), isFalse);
      expect(isValidEmail('plainaddress'), isFalse);
      expect(isValidEmail('@missingusername.com'), isFalse);
      expect(isValidEmail('username@.com'), isFalse);
      expect(isValidEmail('username@domain'), isFalse);
      expect(isValidEmail('user name@domain.com'), isFalse);
    });
  });
}
