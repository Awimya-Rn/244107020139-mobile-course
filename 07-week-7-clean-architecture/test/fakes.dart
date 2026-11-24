import 'package:week7_clean_notes/core/failures.dart';
import 'package:week7_clean_notes/features/announcements/domain/entities/announcement.dart';
import 'package:week7_clean_notes/features/announcements/domain/repositories/announcement_repository.dart';
import 'package:week7_clean_notes/features/auth/domain/entities/auth_session.dart';
import 'package:week7_clean_notes/features/auth/domain/repositories/auth_repository.dart';
import 'package:week7_clean_notes/features/notes/domain/entities/note.dart';
import 'package:week7_clean_notes/features/notes/domain/repositories/note_repository.dart';

class FakeNoteRepository implements NoteRepository {
  FakeNoteRepository({this.items = const [], this.fail = false});

  final List<Note> items;
  final bool fail;
  int addCalls = 0;
  String? lastTitle;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    if (fail) {
      return (
        notes: const <Note>[],
        failure: const LocalFailure('db locked (simulasi)'),
      );
    }
    return (notes: items, failure: null);
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
  }) async {
    addCalls++;
    lastTitle = title;
    if (fail) return (note: null, failure: const LocalFailure('db locked'));
    return (
      note: Note(
        id: 1,
        title: title,
        body: body,
        updatedAt: DateTime(2026, 9, 27),
      ),
      failure: null,
    );
  }
}

class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository({this.items = const [], this.fail = false});
  final List<Announcement> items;
  final bool fail;

  @override
  Future<({List<Announcement> items, Failure? failure})>
  fetchAnnouncements() async {
    if (fail) {
      return (
        items: const <Announcement>[],
        failure: const NetworkFailure('offline (simulasi)'),
      );
    }
    return (items: items, failure: null);
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.fail = false, this.session});

  final bool fail;
  final AuthSession? session;
  int loginCalls = 0;
  int refreshCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;
    if (fail) {
      return (
        session: null,
        failure: const NetworkFailure('Koneksi gagal (simulasi)'),
      );
    }
    return (
      session:
          session ??
          AuthSession(
            access: 'mock-access-for-$email',
            refresh: 'mock-refresh-for-$email',
          ),
      failure: null,
    );
  }

  @override
  Future<({String? access, Failure? failure})> refresh(
    String refreshToken,
  ) async {
    refreshCalls++;
    if (fail) {
      return (
        access: null,
        failure: const NetworkFailure('Refresh gagal (simulasi)'),
      );
    }
    return (access: 'mock-access-renewed', failure: null);
  }
}
