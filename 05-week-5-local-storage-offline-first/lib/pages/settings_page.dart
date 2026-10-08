import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/prefs.dart';
import '../data/sync.dart';

final prefsRepositoryProvider = Provider((ref) => PrefsRepository());

/// Waktu terakhir dibuka (sesi sebelumnya), diisi lewat override di main().
final previousOpenedProvider = Provider<String?>((ref) => null);

final darkModeProvider =
    AsyncNotifierProvider<DarkModeNotifier, bool>(DarkModeNotifier.new);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(prefsRepositoryProvider).getDarkMode();

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    await ref.read(prefsRepositoryProvider).setDarkMode(next);
    state = AsyncData(next); // tanpa AsyncLoading agar tema tidak berkedip
  }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider).value ?? false;
    final offline = ref.watch(forceOfflineProvider);
    final lastOpened = ref.watch(previousOpenedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tema gelap'),
            value: dark,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          SwitchListTile(
            title: const Text('Paksa mode offline (simulasi)'),
            subtitle: const Text('Sinkronisasi & refresh jaringan dinonaktifkan'),
            value: offline,
            onChanged: (_) => ref.read(forceOfflineProvider.notifier).toggle(),
          ),
          ListTile(
            title: const Text('Terakhir dibuka'),
            subtitle: Text(lastOpened ?? 'Pertama kali dibuka'),
          ),
        ],
      ),
    );
  }
}