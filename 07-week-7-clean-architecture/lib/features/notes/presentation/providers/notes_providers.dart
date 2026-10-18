import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notes_database.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/add_note.dart';
import '../../domain/usecases/get_notes.dart';

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(openNotesDb);
});

final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final addNoteProvider = Provider<AddNote>((ref) {
  return AddNote(ref.watch(noteRepositoryProvider));
});

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() async {
    final result = await ref.watch(getNotesProvider).call();
    if (result.failure != null) throw result.failure!;
    return result.notes;
  }

  /// Mengembalikan pesan error, atau null bila sukses.
  Future<String?> add(String title, String body) async {
    final result =
        await ref.read(addNoteProvider).call(title: title, body: body);
    if (result.failure != null) return result.failure!.message;
    ref.invalidateSelf();
    await future;
    return null;
  }
}

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);