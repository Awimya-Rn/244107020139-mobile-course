import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';
import 'package:week5_offline_notes/main.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({this.items = const []})
      : super(openDb: () => throw UnimplementedError());

  final List<Note> items;

  @override
  Future<List<Note>> fetchNotes() async => items;

  @override
  Future<int> countDirty() async => 0;
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offline Notes'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
