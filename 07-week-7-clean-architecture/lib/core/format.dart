String _two(int n) => n.toString().padLeft(2, '0');

String formatDateTime(DateTime d) =>
    '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';

int? parseNoteId(String? raw) {
  if (raw == null) return null;
  final id = int.tryParse(raw);
  return (id == null || id < 0) ? null : id;
}

/// Memvalidasi apakah format string email sesuai dengan standar format email.
bool isValidEmail(String? email) {
  if (email == null) return false;
  final trimmed = email.trim();
  if (trimmed.isEmpty) return false;
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );
  return emailRegex.hasMatch(trimmed);
}
