import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/core/format.dart';

void main() {
  test('formatDateTime memakai nol di depan', () {
    expect(formatDateTime(DateTime(2026, 9, 7, 8, 5)), '07/09/2026 08:05');
  });

  test('parseNoteId menangani input tidak valid', () {
    expect(parseNoteId('12'), 12);
    expect(parseNoteId('abc'), isNull);
    expect(parseNoteId('-3'), isNull);
    expect(parseNoteId(null), isNull);
  });
}