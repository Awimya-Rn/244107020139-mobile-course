import 'package:flutter/material.dart';

import '../../../../core/format.dart';
import '../../domain/entities/note.dart';

class NotesList extends StatelessWidget {
  const NotesList(this.notes, {super.key});
  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: notes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final n = notes[i];
        return ListTile(
          title: Text(n.title),
          subtitle: Text(
            n.body.isEmpty
                ? formatDateTime(n.updatedAt)
                : '${n.body}\n${formatDateTime(n.updatedAt)}',
          ),
          isThreeLine: n.body.isNotEmpty,
          trailing: n.dirty ? const Icon(Icons.sync, size: 18) : null,
        );
      },
    );
  }
}