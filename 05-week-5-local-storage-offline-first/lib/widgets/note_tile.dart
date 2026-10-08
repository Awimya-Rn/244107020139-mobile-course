import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.body.isNotEmpty)
            Text(note.body, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (note.dirty)
            const Chip(
              label: Text('belum tersinkron'),
              avatar: Icon(Icons.cloud_off, size: 16),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
      trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      onTap: onTap,
    );
  }
}