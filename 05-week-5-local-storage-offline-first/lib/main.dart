import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'data/prefs.dart';
import 'pages/note_detail_page.dart';
import 'pages/notes_page.dart';
import 'pages/posts_page.dart';
import 'pages/settings_page.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final _router = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const NotesPage()),
  GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
  GoRoute(path: '/posts', builder: (_, __) => const PostsPage()),
  GoRoute(
    path: '/note/:id',
    builder: (_, state) =>
        NoteDetailPage(id: int.parse(state.pathParameters['id']!)),
  ),
]);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb || Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  final prefs = PrefsRepository();
  final previous = await prefs.getLastOpened(); // sesi sebelumnya
  await prefs.markOpenedNow();

  runApp(ProviderScope(
    overrides: [previousOpenedProvider.overrideWithValue(previous)],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider).value ?? false;
    return MaterialApp.router(
      title: 'Offline Notes',
      routerConfig: _router,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
    );
  }
}