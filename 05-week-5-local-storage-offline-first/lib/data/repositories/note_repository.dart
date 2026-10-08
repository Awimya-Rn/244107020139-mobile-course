import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../local/db.dart';
import '../local/note.dart';

class NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
      : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<Note>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(Note.fromMap).toList();
  }

  Future<Note?> getById(int id) async {
    final db = await _openDb();
    final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Note.fromMap(rows.first);
  }

  Future<Note> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = Note(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return Note(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  Future<void> updateNote(int id,
      {required String title, String body = ''}) async {
    final db = await _openDb();
    await db.update(
      'notes',
      {
        'title': title,
        'body': body,
        'updated_at': DateTime.now().toIso8601String(), // dasar last-write-wins
        'dirty': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> countDirty() async {
    final db = await _openDb();
    final rows =
        await db.rawQuery('SELECT COUNT(*) AS c FROM notes WHERE dirty = 1');
    return ((rows.first['c'] as num?)?.toInt() ?? 0);
  }

  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }
}

// ---- Provider (dipakai UI dan test) ----
final noteRepositoryProvider = Provider<NoteRepository>((ref) => NoteRepository());

final notesProvider = FutureProvider<List<Note>>(
    (ref) => ref.watch(noteRepositoryProvider).fetchNotes());

final dirtyCountProvider = FutureProvider<int>(
    (ref) => ref.watch(noteRepositoryProvider).countDirty());

final noteByIdProvider = FutureProvider.family<Note?, int>(
    (ref, id) => ref.watch(noteRepositoryProvider).getById(id));