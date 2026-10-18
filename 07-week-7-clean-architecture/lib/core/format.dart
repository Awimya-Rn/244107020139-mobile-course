String _two(int n) => n.toString().padLeft(2, '0');

String formatDateTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

int? parseNoteId(String? raw) {
  if (raw == null) return null;
  final id = int.tryParse(raw);
  return (id == null || id < 0) ? null : id;
}