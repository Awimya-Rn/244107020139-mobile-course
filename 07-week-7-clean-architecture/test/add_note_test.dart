import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/notes/domain/usecases/add_note.dart';

import 'fakes.dart';

void main() {
  test('AddNote menolak judul kosong dan tidak menyentuh repository', () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo)(title: '   ');
    expect(result.failure, isA<ValidationFailure>());
    expect(result.note, isNull);
    expect(repo.addCalls, 0);
  });

  test('AddNote men-trim judul lalu menyimpan', () async {
    final repo = FakeNoteRepository();
    final result = await AddNote(repo)(title: '  Belanja  ', body: ' susu ');
    expect(result.failure, isNull);
    expect(repo.lastTitle, 'Belanja');
    expect(result.note!.body, 'susu');
  });

  test('AddNote meneruskan failure dari repository', () async {
    final result = await AddNote(FakeNoteRepository(fail: true))(title: 'X');
    expect(result.failure, isA<LocalFailure>());
  });
}