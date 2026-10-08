import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/note_repository.dart';
import 'notes_page.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final n = note.value;
              if (n != null) showNoteEditor(context, ref, note: n);
            },
          ),
        ],
      ),
      body: note.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (n) => n == null
            ? const Center(child: Text('Catatan tidak ditemukan'))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.title, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Diubah: ${n.updatedAt.toLocal()}'),
                    if (n.dirty) const Text('Status: belum tersinkron'),
                    const Divider(),
                    Text(n.body),
                  ],
                ),
              ),
      ),
    );
  }
}