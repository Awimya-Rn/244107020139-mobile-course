# AI Verification — Week 3: Navigation & State Management

Dokumentasi ini mencatat penggunaan AI sebagai co-developer untuk bagian **AI Prompt Challenge** (halaman `StatsPage` + `StatsNotifier`), sesuai kebijakan AI pada codelab #03: AI boleh membantu membuat boilerplate, tetapi setiap baris kode wajib dibaca, dijelaskan, diverifikasi, dan diperbaiki.

## 1. Prompt yang digunakan

```
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.
```

*(Sesuaikan dengan tool AI yang benar-benar dipakai — Cursor / Copilot / Claude Code / lainnya — dan tanggal sesi.)*

## 2. Ringkasan output AI

AI menghasilkan:
- `StatItem` — model data (label, value) dengan `==`/`hashCode` override untuk kebutuhan test.
- `StatsNotifier extends AsyncNotifier<List<StatItem>>` — dengan `random` yang di-inject lewat constructor supaya bisa di-fake saat testing, `build()` mensimulasikan delay + kegagalan acak, dan method `refresh()`.
- `statsProvider = AsyncNotifierProvider<StatsNotifier, List<StatItem>>`.
- `StatsPage extends ConsumerWidget` — menangani `loading`/`error`/`data` lewat `AsyncValue.when`.
- `test/stats_notifier_test.dart` — 4 unit test: sukses mengembalikan 3 item, gagal melempar exception, `refresh()` mengambil ulang data, dan kesetaraan `StatItem`.

## 3. Verifikasi & Perbaikan

| Item pada AI Verification Checklist | Hasil cek | Catatan |
|---|---|---|
| State diubah secara immutable (tidak ada `state.add()`/mutasi langsung) | ✅ Lolos | `StatsNotifier` mengembalikan list baru dari `build()`/`refresh()`, tidak memutasi list lama. |
| `ref.watch` hanya di `build`, `ref.read` di callback | ✅ Lolos | Dicek di `StatsPage`; tidak ditemukan `ref.watch` dipanggil di luar `build`. |
| Ketiga state `AsyncValue` benar-benar ditangani | ✅ Lolos | Diuji manual: loading (spinner 2 detik), error (uncomment `throw Exception(...)` sementara → tombol "Coba lagi" muncul), success (list tampil setelah `ref.invalidate`). |
| Provider dideklarasikan dengan tipe eksplisit, tidak duplikat | ✅ Lolos | `AsyncNotifierProvider<StatsNotifier, List<StatItem>>` eksplisit. |
| Tidak memakai API Riverpod versi lama (`StateProvider`/`StateNotifierProvider` antipattern) | ✅ Lolos | Memakai `Notifier`/`AsyncNotifier` sesuai pola terbaru. |
| `flutter analyze` tanpa warning | ⚠️ Awalnya gagal → diperbaiki | Lihat detail perbaikan di bawah. |
| `flutter test` lolos | ✅ Lolos setelah perbaikan | 4 test di `stats_notifier_test.dart` lulus. |

### Perbaikan yang dilakukan

**1. `unnecessary_underscores` di `test/stats_notifier_test.dart` (baris 50, 89, 111)**

AI awalnya menulis callback listener dengan parameter kedua bergaris-bawah-ganda:
```dart
container.listen(statsProvider, (_, __) {});
```
Dart modern mendukung wildcard `_` berulang dalam satu scope tanpa perlu digandakan. Diperbaiki menjadi:
```dart
container.listen(statsProvider, (_, _) {});
```
di ketiga lokasi yang sama.

**2. `unused_import` di `lib/main.dart`**

Setelah router direfactor untuk memakai `ShellRoute` dengan `TodoPage`/`ProductPage`(Stats), import `pages/detail_page.dart` dan `pages/home_page.dart` dari Praktikum 1 tidak lagi terpakai. Dihapus dari `main.dart`.

**3. `unused_local_variable` di `lib/pages/todo_page.dart`**

Variabel `incompleteTodos` (hasil `ref.watch(incompleteTodosProvider)`) sempat dideklarasikan tapi `ListView.builder` masih memakai list asli (`todos`). Diperbaiki dengan menyambungkan `incompleteTodos` sebagai sumber `itemCount`/`itemBuilder`, sementara `todos` tetap dipakai untuk mencari index asli tiap item (`todos.indexOf(todo)`) agar `toggle`/`remove` menunjuk ke item yang benar di `todoListProvider`.

**Hasil akhir:**
```
flutter analyze
Analyzing 03-week-3-navigation-state-management...
No issues found! (ran in 5.3s)
```

## 4. Hasil testing

- `test/widget_test.dart` — menguji alur tambah tugas baru di `TodoPage`, lolos.
- `test/stats_notifier_test.dart` — menguji `StatsNotifier` (success, failure, refresh) dan kesetaraan `StatItem`, lolos setelah perbaikan `unnecessary_underscores`.

*(Tempel output `flutter test` terbaru di sini sebagai bukti.)*

## 5. Kesimpulan

Kode boilerplate dari AI secara struktur sudah mengikuti pola Riverpod yang benar (immutable state, `Notifier`/`AsyncNotifier`, `ref.watch` vs `ref.read` di tempat yang tepat) dan tidak memakai API usang. Perbaikan yang dilakukan bersifat kebersihan kode (lint) dan integrasi (menyambungkan variabel yang belum terpakai, membersihkan import sisa refactor) — bukan perbaikan logika inti, yang menunjukkan output AI untuk kasus ini cukup dapat diandalkan sebagai titik awal, tetapi tetap memerlukan verifikasi manual sebelum diterima.