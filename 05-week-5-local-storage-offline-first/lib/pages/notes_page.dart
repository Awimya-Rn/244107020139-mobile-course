import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';
import '../data/sync.dart';
import '../widgets/note_tile.dart';

Future<void> showNoteEditor(BuildContext context, WidgetRef ref,
    {Note? note}) async {
  final title = TextEditingController(text: note?.title);
  final body = TextEditingController(text: note?.body);

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(note == null ? 'Catatan baru' : 'Edit catatan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: title, decoration: const InputDecoration(labelText: 'Judul')),
          TextField(controller: body, maxLines: 3, decoration: const InputDecoration(labelText: 'Isi')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
      ],
    ),
  );

  if (saved != true || title.text.trim().isEmpty) return;
  final repo = ref.read(noteRepositoryProvider);
  if (note == null) {
    await repo.addNote(title: title.text.trim(), body: body.text.trim());
  } else {
    await repo.updateNote(note.id!, title: title.text.trim(), body: body.text.trim());
    ref.invalidate(noteByIdProvider(note.id!));
  }
  ref.invalidate(notesProvider);
  ref.invalidate(dirtyCountProvider);
}

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _sync(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    if (ref.read(forceOfflineProvider)) {
      messenger.showSnackBar(
          const SnackBar(content: Text('Offline: sinkronisasi ditunda')));
      return;
    }
    final n = await syncNotes(ref.read(noteRepositoryProvider));
    ref.invalidate(notesProvider);
    ref.invalidate(dirtyCountProvider);
    messenger.showSnackBar(SnackBar(content: Text('$n catatan tersinkron')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirty = ref.watch(dirtyCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(icon: const Icon(Icons.article_outlined), onPressed: () => context.push('/posts')),
          Badge(
            label: Text('$dirty'),
            isLabelVisible: dirty > 0,
            child: IconButton(icon: const Icon(Icons.sync), onPressed: () => _sync(context, ref)),
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/settings')),
        ],
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat: $e'),
              TextButton(onPressed: () => ref.invalidate(notesProvider), child: const Text('Coba lagi')),
            ],
          ),
        ),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Belum ada catatan. Tekan + untuk menambah.'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final n = items[i];
                  return NoteTile(
                    note: n,
                    onTap: () => context.push('/note/${n.id}'),
                    onDelete: () async {
                      await ref.read(noteRepositoryProvider).deleteNote(n.id!);
                      ref.invalidate(notesProvider);
                      ref.invalidate(dirtyCountProvider);
                    },
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showNoteEditor(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}