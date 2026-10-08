import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'local/db.dart';
import 'repositories/note_repository.dart';

/// ATURAN KONFLIK (didokumentasikan): last-write-wins berdasarkan `updated_at`.
/// Jika catatan yang sama berubah di lokal dan server, versi dengan
/// `updated_at` lebih baru yang dipertahankan.

class Post {
  const Post({required this.id, required this.title, required this.body});
  final int id;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'body': body};
}

/// Toggle simulasi offline yang deterministik untuk demo dan testing.
class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(ForceOfflineNotifier.new);

class SyncService {
  SyncService({Future<Database> Function()? openDb, Dio? dio})
      : _openDb = openDb ?? openNotesDb,
        _dio = dio ?? Dio();

  final Future<Database> Function() _openDb;
  final Dio _dio;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows
        .map((r) => Post.fromJson(
            jsonDecode(r['payload'] as String? ?? '{}') as Map<String, dynamic>))
        .toList();
  }

  /// Ambil dari jaringan lalu simpan ke cache.
  Future<List<Post>> refreshPosts() async {
    try {
      final res = await _dio
          .get<List<dynamic>>('https://jsonplaceholder.typicode.com/posts');
      final posts = (res.data ?? [])
          .take(20)
          .map((e) => Post.fromJson(e as Map<String, dynamic>))
          .toList();

      final db = await _openDb();
      final batch = db.batch();
      batch.delete('cached_posts');
      for (final p in posts) {
        batch.insert('cached_posts', {
          'id': p.id,
          'payload': jsonEncode(p.toJson()),
          'cached_at': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit(noResult: true);
      return posts;
    } on DioException {
      throw Exception('Tidak dapat menjangkau server (offline?)');
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) => SyncService());

/// Cache-first: tampilkan cache seketika, refresh di background, simpan hasilnya.
class PostsNotifier extends AsyncNotifier<List<Post>> {
  bool _refreshed = false; // mencegah loop refresh -> invalidate -> refresh

  @override
  Future<List<Post>> build() async {
    final svc = ref.watch(syncServiceProvider);
    final offline = ref.watch(forceOfflineProvider);
    final cached = await svc.readCachedPosts();

    if (offline) {
      _refreshed = false;
      return cached; // offline: hanya cache
    }
    if (cached.isEmpty) return svc.refreshPosts(); // belum ada cache: tunggu jaringan
    if (!_refreshed) {
      _refreshed = true;
      unawaited(_refreshInBackground(svc));
    }
    return cached; // UI langsung tampil
  }

  Future<void> _refreshInBackground(SyncService svc) async {
    try {
      await svc.refreshPosts();
      ref.invalidateSelf(); // muat ulang dari cache yang sudah diperbarui
    } catch (_) {
      // gagal jaringan: tetap pakai cache
    }
  }
}

final postsProvider =
    AsyncNotifierProvider<PostsNotifier, List<Post>>(PostsNotifier.new);

/// Sinkronisasi catatan dirty (server disimulasikan dengan delay).
Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;
  // Proyek nyata: kirim tiap catatan dirty ke REST API, tandai bersih bila 2xx.
  await Future.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}