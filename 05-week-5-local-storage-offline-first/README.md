# Week 5: Local Storage & Offline First

Aplikasi **Offline Notes** untuk codelab Minggu 5 (Pemrograman Mobile, JTI Polinema). Aplikasi tetap bisa dibaca dan ditulis tanpa internet, lalu disinkronkan ketika koneksi kembali.

- **Nama / NIM:** [isi nama] / [isi NIM]
- **Kelas:** [isi kelas]

## Tujuan

- Menyimpan preferensi sederhana (tema gelap, waktu terakhir dibuka) dengan `SharedPreferences`.
- Menerapkan CRUD catatan dengan SQLite (`sqflite`) melalui repository lokal.
- Menerapkan pola offline-first: cache-first read, dirty flag, dan sinkronisasi.
- Menampilkan state loading, error, empty, dan success dengan Riverpod.
- Menguji repository lokal dengan repository palsu (tanpa database sungguhan).

## Fitur utama

| Fitur | Keterangan |
|---|---|
| Preferensi | Toggle tema gelap/terang dan waktu terakhir dibuka (SharedPreferences) |
| CRUD catatan | Tambah, lihat, edit, hapus catatan di SQLite, diurutkan `updated_at` terbaru |
| Dirty flag | Catatan yang belum tersinkron ditandai `dirty = 1` dan menampilkan label "belum tersinkron" |
| Sinkronisasi | Tombol sync memproses catatan dirty (server disimulasikan dengan delay), lalu badge kembali 0 |
| Cache-first posts | Data `GET /posts` (JSONPlaceholder) tampil dari cache lokal, lalu di-refresh di background |
| Simulasi offline | Toggle "Paksa mode offline" agar demo tidak bergantung pada Wi-Fi |
| Detail catatan | Halaman `/note/:id` (GoRouter) yang membaca langsung dari repository lokal |

## Stack teknologi

Flutter, Dart, `flutter_riverpod`, `shared_preferences`, `sqflite`, `path`, `dio`, `go_router`.

## Struktur project

```
lib/
├── main.dart
├── data/
│   ├── local/ (db.dart, note.dart)
│   ├── prefs.dart
│   ├── sync.dart
│   └── repositories/note_repository.dart
├── pages/ (notes_page, note_detail_page, posts_page, settings_page)
└── widgets/note_tile.dart
test/note_test.dart
docs/
screenshots/
```

## Arsitektur

```
UI (ConsumerWidget) --watch--> Provider (AsyncValue)
Provider --> Repository lokal --CRUD--> SQLite
Repository --sync--> Remote (simulasi) --sukses--> dirty = 0
```

- UI tidak memanggil SQLite/SharedPreferences secara langsung. Semua lewat repository + provider.
- `NoteRepository` menerima `openDb` lewat constructor sehingga bisa diganti repository palsu saat testing.
- Logika cache posts dan `syncNotes` dipisah ke `data/sync.dart` agar repository fokus pada CRUD.

## Aturan konflik sinkronisasi

**Last-write-wins berdasarkan `updated_at`.** Jika catatan yang sama berubah di lokal dan di server, versi dengan `updated_at` lebih baru yang dipertahankan. Setiap `addNote` dan `updateNote` mengisi `updated_at` baru dan menandai `dirty = 1`.

## Cara menjalankan

```bash
flutter pub get
flutter run            # disarankan di emulator Android / perangkat fisik
flutter analyze
flutter test
```

**Catatan platform:** `sqflite` mendukung Android, iOS, dan macOS secara bawaan. Untuk Windows/Linux, tambahkan `sqflite_common_ffi` dan inisialisasi `databaseFactory = databaseFactoryFfi` di `main()` sebelum database dipakai. Tanpa itu muncul error `databaseFactory not initialized`.

## Hasil yang dicapai

### 1. Preferensi (SharedPreferences)

Tema dan waktu terakhir dibuka tersimpan di perangkat.

| Tema terang | Tema gelap |
|---|---|
| ![Pengaturan tema terang](screenshots/Preferensi.png) | ![Pengaturan tema gelap](screenshots/Preferensi_1.png) |

### 2. CRUD catatan (SQLite)

| Daftar catatan | Tambah catatan | Detail catatan |
|---|---|---|
| ![Daftar catatan](screenshots/CRUD.png) | ![Dialog catatan baru](screenshots/CRUD_1.png) | ![Detail catatan](screenshots/CRUD_2.png) |

### 3. Dirty flag dan sinkronisasi

**Sebelum sync:** badge pada ikon sync menunjukkan **2** catatan dan tiap catatan berlabel "belum tersinkron".
**Sesudah sync:** muncul pesan "2 catatan tersinkron", label hilang, dan badge kembali 0.

| Sebelum sync | Sesudah sync |
|---|---|
| ![Badge dirty sebelum sync](screenshots/DirtyFlag.png) | ![Setelah sync](screenshots/DirtyFlag_1.png) |

### 4. Cache-first posts

Daftar posts tampil dari cache lokal terlebih dahulu, lalu diperbarui dari jaringan di background.

![Posts cache-first](screenshots/CacheFirst.png)
![Catatan saat offline](screenshots/CacheFirst_offline.png) 

## Testing

`test/note_test.dart` memakai `FakeNoteRepository` (tanpa SQLite sungguhan):

1. `Note.fromMap` aman terhadap field yang hilang.
2. Flag `dirty` bertahan pada serialisasi.
3. `notesProvider` sukses dengan repository palsu.
4. `notesProvider` error dengan repository palsu.
5. `dirtyCountProvider` menghitung catatan belum tersinkron.

## AI Challenge

Prompt, output awal AI, tabel perbandingan, dan hasil verifikasi ada di folder [`docs/`](docs/).

**Keputusan final:** SharedPreferences untuk preferensi kecil dan SQLite (sqflite) untuk catatan. Catatan butuh query, urutan, dan penanda `dirty`/`updated_at` untuk sinkronisasi, sedangkan Drift menambah boilerplate codegen yang belum diperlukan.

| Kebutuhan | Pilihan | Alasan singkat |
|---|---|---|
| Preferensi tema | SharedPreferences | Nilai primitif kecil |
| Catatan + antrean sync | sqflite | Relasional, mudah memodelkan dirty flag |
| Alternatif cache objek | Hive | NoSQL ringan |
| Aplikasi besar, query kompleks | Drift | Reaktif dan type-safe, tetapi boilerplate besar |

## Masalah yang ditemui

| Gejala | Penyebab | Solusi |
|---|---|---|
| `Bad state: databaseFactory not initialized` | Dijalankan di desktop/web, bukan Android | Jalankan di Android, atau pakai `sqflite_common_ffi` di desktop |
| `Building native assets failed` (Windows) | Build hook `sqlite3` gagal | Jalankan di Android, atau `flutter clean`, pindahkan project ke path tanpa spasi, cek koneksi |

## Refleksi singkat

- Daftar catatan tidak disimpan di SharedPreferences karena koleksi akan ditulis ulang seluruhnya setiap perubahan dan tidak bisa di-query atau di-sync per baris.
- Cache-first cocok untuk data yang toleran sedikit basi. Untuk data real-time lebih tepat network-first.
- Dirty flag cukup untuk create/update. Untuk delete dan retry per operasi dibutuhkan tabel outbox.