# Week 4 – Networking & REST API (Flutter)

Aplikasi Flutter yang menampilkan daftar data dari REST API publik **JSONPlaceholder** (`/posts` dan `/comments`) dengan arsitektur berlapis:

```
UI (ConsumerWidget) → Provider (Riverpod, AsyncValue) → Repository → Dio → REST API
```

UI tidak pernah memanggil Dio secara langsung. Semua akses data lewat repository dan provider.

## Tujuan

- Memahami HTTP, REST API, dan JSON, lalu memetakan JSON ke model Dart yang aman null.
- Menerapkan repository pattern sehingga UI terpisah dari lapisan jaringan.
- Mengonfigurasi Dio terpusat (base URL, timeout, interceptor) dan menangani error jaringan.
- Menampilkan state loading, error, empty, dan success dengan `AsyncValue` + Riverpod.
- Menerapkan pagination dasar (infinite scroll, 10 item per halaman).

## Fitur utama

- Daftar posts dari `https://jsonplaceholder.typicode.com/posts`.
- Dio terpusat: `baseUrl`, timeout 10 detik, dan `LogInterceptor`.
- Model `Post` (dan `Comment`) dengan `fromJson` aman null.
- Empat state UI: **loading**, **error + tombol "Coba lagi"**, **empty**, **success**.
- Pesan error ramah pengguna (timeout, koneksi, 404, 401/403, 5xx) lewat `friendlyErrorMessage`.
- Infinite scroll 10 item per halaman (`_page` / `_limit`) dengan guard request ganda.
- Halaman detail post beserta daftar komentar (Refactoring + AI Challenge).
- Unit test model, error mapping, dan provider dengan repository palsu.

## Stack teknologi

| Komponen | Teknologi |
|---|---|
| Framework | Flutter (Dart) |
| HTTP client | `dio` |
| State management | `flutter_riverpod` (AsyncNotifier / AsyncValue) |
| API | JSONPlaceholder (tanpa API key) |
| Testing | `flutter_test` |

## Struktur folder

```
04-week-4-networking-rest-api/
├── lib/
│   ├── main.dart
│   ├── data/
│   │   ├── api_client.dart        # createDio(): konfigurasi terpusat
│   │   ├── providers.dart         # provider Dio, repository, notifier
│   │   ├── models/                # Post, Comment (fromJson aman null)
│   │   └── repositories/          # PostRepository, CommentRepository
│   └── pages/                     # post_list_page, paged_post_page, detail
├── test/
├── docs/                          # dokumentasi AI Challenge
├── screenshots/                   # bukti hasil (dipakai di README ini)
└── README.md
```

## Cara menjalankan

```bash
git clone <url-repository-portfolio>
cd 04-week-4-networking-rest-api
flutter pub get
flutter analyze
flutter test
flutter run
```

Pastikan emulator atau perangkat fisik terhubung ke internet.

---

## Hasil yang dicapai

### 1. Data dari REST API tampil (state success)

Data `GET /posts` diambil lewat repository + Riverpod, lalu ditampilkan sebagai daftar (versi non-paged dari codelab).

![Daftar posts berhasil dimuat](screenshots/p2.png)

### 2. State error: tidak ada koneksi

Saat internet dimatikan (mode pesawat), `DioException` bertipe `connectionError` berubah menjadi pesan ramah beserta tombol **Coba lagi**.

![State error koneksi dengan tombol Coba lagi](screenshots/p2_1.png)

### 3. State error: URL salah (404)

Uji skenario 3 pada codelab: `baseUrl` sementara diganti ke URL yang salah (`https://google.com`). Respons `404` dipetakan ke "Data tidak ditemukan (404)". Setelah uji, `baseUrl` dikembalikan ke JSONPlaceholder.

![State error 404 saat baseUrl salah](screenshots/p2_2.png)

### 4. Pagination / infinite scroll

Halaman `Posts Paged` memuat 10 item per halaman dan menambah data saat pengguna scroll mendekati ujung list. Guard `isLoadingMore` / `hasMore` mencegah request ganda.

![Halaman Posts Paged dengan infinite scroll](screenshots/p3.png)

### 5. Refactoring: halaman detail + komentar

Hasil Refactoring Challenge: halaman detail post menampilkan `title` dan `body` lengkap. Bagian komentar berasal dari `GET /comments?postId={id}` (hasil AI Challenge) dengan model `Comment` aman null.

![Halaman Detail Post dengan daftar komentar](screenshots/Refactoring_dan_testing_1.png)

### 6. Verifikasi hasil AI dengan `flutter analyze`

Sesuai AI Verification Checklist, kode hasil AI dianalisis sebelum diterima. `flutter analyze` menemukan **1 warning**: *unused import* `pages/post_list_page.dart` di `lib/main.dart` karena `home` sudah berpindah ke `PagedPostPage`.

![flutter analyze menemukan 1 warning unused import](screenshots/AI_C.png)

### 7. Analyze bersih dan semua test lulus

Setelah import yang tidak terpakai dihapus, `flutter analyze` bersih dan `flutter test` melaporkan **10 test lulus**.

![flutter analyze tanpa issue dan 10 test lulus](screenshots/Refactoring_dan_testing.png)

### Ringkasan checklist tugas

| Syarat | Status |
|---|---|
| Data API tampil via repository + Riverpod | ✅ |
| Dio terpusat (base URL, timeout, interceptor logging) | ✅ |
| Model `fromJson` aman null | ✅ |
| 4 state: loading, error (+ retry), empty, success | ✅ |
| Pagination 10 item/halaman + guard request ganda | ✅ |
| Minimal 2 test lulus (model/error mapping + provider repository palsu) | ✅ (10 test) |
| AI Challenge didokumentasikan di `docs/` | ✅ |
| `flutter analyze` tanpa issue | ✅ |

## AI Challenge (ringkasan)

Prompt ke AI coding assistant: membuat repository layer untuk `GET /comments?postId={id}` memakai Dio + Riverpod, lengkap dengan model `Comment` aman null, `AsyncNotifierProvider`, pesan error ramah pengguna, dan satu unit test. Prompt lengkap, output awal AI, perbaikan, dan alasan keputusan teknis ada di folder `docs/`.

Hasil verifikasi:

- UI tidak memanggil Dio langsung.
- `fromJson` memakai cast defensif (`as String? ?? ''`, `(as num?)?.toInt() ?? 0`).
- Semua `DioExceptionType` dipetakan ke pesan pengguna.
- `baseUrl` dan timeout terpusat di `createDio()`.
- `flutter analyze` awalnya menemukan 1 warning (lihat bagian 6), lalu diperbaiki.

---

## Refleksi

### 1. Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika dilanggar?

Jika widget memanggil Dio sendiri, UI harus tahu detail *bagaimana* data diambil: URL, header, parsing JSON, dan jenis exception. Akibatnya:

- **Sulit diuji.** Widget test terpaksa melakukan HTTP sungguhan atau meniru Dio. Dengan repository, cukup meng-override provider dengan repository palsu.
- **Konfigurasi tersebar.** Base URL, timeout, dan logging menyebar di banyak widget, sehingga satu perubahan harus diulang di banyak file.
- **Logika bocor ke UI.** Parsing, mapping error, dan pagination bercampur dengan kode layout sehingga widget besar dan rapuh.
- **Sulit mengganti sumber data.** Pindah ke package lain, cache lokal, atau API baru memaksa perubahan di semua layar.
- **Siklus hidup tidak terkendali.** Request di `build`/`initState` bisa terpanggil berulang saat rebuild.

Dengan repository sebagai satu-satunya pintu data, perubahan di lapisan jaringan tidak menyentuh UI.

### 2. Kapan pagination client-side cukup, dan kapan harus pagination server (`_page`/`_limit`)?

**Client-side cukup** bila seluruh data kecil (puluhan sampai ratusan item), payload ringan, dan jarang berubah, sehingga satu kali unduh masih cepat dan hemat kuota. Cara ini juga satu-satunya pilihan bila server tidak mendukung paging. Kekurangannya: seluruh data tetap diunduh dan disimpan di memori.

**Pagination server wajib** bila data besar atau tak terbatas (ribuan item atau feed), payload berat, jaringan mobile lambat/mahal, atau data sering berubah. Keuntungannya: waktu muat awal singkat, memori hemat, dan transfer data hanya sebesar yang dilihat pengguna. Konsekuensinya, aplikasi harus mengelola nomor halaman, `hasMore`, guard request ganda, dan error per halaman.

### 3. Bagaimana exception repository berubah menjadi `AsyncError` tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?

Method `build()` pada `AsyncNotifier` adalah `Future` yang di-`await` oleh Riverpod. Jika repository melempar `DioException`, Future itu selesai dengan error, dan Riverpod menyimpannya sebagai `AsyncError` (sebelumnya `AsyncLoading`). Widget cukup `ref.watch(...)` lalu `when(loading:, error:, data:)`, tanpa try/catch di UI. Repository sengaja tidak menelan exception agar error naik ke provider.

**try/catch eksplisit tetap dibutuhkan** ketika:

- state tidak boleh menjadi `AsyncError` penuh, misalnya saat memuat halaman berikutnya: data lama harus tetap tampil, jadi error ditangkap dan disimpan secara terpisah;
- `await ref.read(provider.future)` dipanggil manual (misalnya di `RefreshIndicator`), karena error dilempar ulang ke pemanggil;
- exception perlu dibungkus menjadi tipe domain atau perlu cleanup (`finally`);
- kode berjalan di luar alur `build` provider, seperti event handler dan callback, misalnya method `refresh()` yang mengatur `state` secara manual.

### 4. Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?

- **Import tidak terpakai.** `flutter analyze` menemukan warning `unused_import` di `lib/main.dart` (lihat bagian 6) karena halaman awal berpindah ke `PagedPostPage`. Import dihapus sampai analyze bersih, karena kode AI tidak boleh diterima tanpa lolos analyzer.
- **Cast `fromJson` tidak aman.** Cast langsung seperti `json['id'] as int` crash bila field hilang atau bertipe `double`. Diganti dengan `(json['id'] as num?)?.toInt() ?? 0` dan `as String? ?? ''`.
- **Pemetaan error kurang lengkap.** Semua `DioExceptionType` (timeout, `connectionError`, `badResponse`, dan lainnya) dipetakan ke pesan ramah, bukan `error.toString()`.
- **Konfigurasi jaringan tersebar.** `Dio` dipusatkan di `createDio()` dan repository menerimanya lewat constructor agar bisa diganti repository palsu saat test.
- **Test hanya happy path.** Ditambahkan edge case: field hilang, tipe salah, error provider, dan guard request ganda.