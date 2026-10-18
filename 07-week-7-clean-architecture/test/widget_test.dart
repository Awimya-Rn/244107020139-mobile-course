import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week7_clean_notes/features/notes/domain/entities/note.dart';
import 'package:week7_clean_notes/features/notes/presentation/pages/notes_page.dart';
import 'package:week7_clean_notes/features/notes/presentation/providers/notes_providers.dart';

import 'fakes.dart';

Widget _app(FakeNoteRepository repo) => ProviderScope(
      overrides: [noteRepositoryProvider.overrideWithValue(repo)],
      child: const MaterialApp(home: NotesPage()),
    );

void main() {
  testWidgets('NotesPage menampilkan catatan dari repository', (tester) async {
    final repo = FakeNoteRepository(items: [
      Note(title: 'Belanja', updatedAt: DateTime(2026, 9, 27)),
    ]);
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    expect(find.text('Belanja'), findsOneWidget);
  });

  testWidgets('NotesPage menampilkan pesan bila kosong', (tester) async {
    await tester.pumpWidget(_app(FakeNoteRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Belum ada catatan.'), findsOneWidget);
  });

  testWidgets('NotesPage menampilkan pesan error dari Failure', (tester) async {
    await tester.pumpWidget(_app(FakeNoteRepository(fail: true)));
    await tester.pumpAndSettle();

    expect(find.text('db locked (simulasi)'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}