import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/error_view.dart';
import '../providers/notes_providers.dart';
import '../widgets/notes_list.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        actions: [
          IconButton(
            tooltip: 'Pengumuman',
            icon: const Icon(Icons.campaign_outlined),
            onPressed: () => context.push('/announcements'),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(
          message: messageOf(e),
          onRetry: () => ref.invalidate(notesProvider),
        ),
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('Belum ada catatan.'))
            : NotesList(notes),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => const _AddNoteDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AddNoteDialog extends ConsumerStatefulWidget {
  const _AddNoteDialog();

  @override
  ConsumerState<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends ConsumerState<_AddNoteDialog> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error =
        await ref.read(notesProvider.notifier).add(_title.text, _body.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
    } else {
      setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catatan baru'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _title,
            decoration: InputDecoration(labelText: 'Judul', errorText: _error),
          ),
          TextField(
            controller: _body,
            decoration: const InputDecoration(labelText: 'Isi'),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
    );
  }
}