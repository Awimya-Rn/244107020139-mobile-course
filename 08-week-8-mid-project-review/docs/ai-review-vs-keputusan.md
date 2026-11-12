# Review AI dibandingkan keputusan teknis

Tanggal: 12 November 2026. Author: [isi: nama] ([isi: NIM], [isi: kelas]).
AI dipakai sebagai reviewer awal dan pelaksana perubahan, bukan sebagai reviewer sejawat atau pemberi approval.
Keputusan yang direkam di bawah merupakan keputusan implementasi dalam sesi berbantuan AI;
mahasiswa tetap perlu memeriksa, memahami, dan menjelaskannya saat demo.

> **Batas dokumen ini.** Hanya yang benar-benar dikerjakan dan diperiksa pada sesi ini yang dicatat sebagai bukti.
> Tes otomatis, emulator, PR, review sejawat, dan merge **belum dilakukan**; statusnya ada di
> [verifikasi emulator](emulator-verification.md), [review sejawat](peer-review.md), dan
> [verifikasi merge](merge-verification.md).

## Konteks dan permintaan

Basis review: `Kenali-Batikmu/Kenali-Batikmu-Mobile@0fc7cf8` (branch lokal `dev`),
diambil dari `Kenali-Batikmu-Mobile.zip`. Aplikasi Flutter dengan provider berbasis `ChangeNotifier`
(`lib/providers/`), SQLite lokal (`DatabaseHelper`), dan Supabase (`SupabaseService`) dengan konsep online/offline.
Proyek ini tidak diasumsikan memakai Riverpod, GoRouter, atau Clean Architecture ketat.

Permintaan penulis (kutipan asli, tanpa prompt review formal):

```text
1. "buat logo ini menjadi logo utama ketika dibuat aplikasi, dan ketika membuka
   aplikasi muncul logo ini"   (lampiran: logo_1.png)
2. "apakah file tersebut sudah terintegrasi ke supabase?"
```

Permintaan 1 menghasilkan perubahan kode/aset (R1–R4). Permintaan 2 menghasilkan tinjauan baca-saja
atas kode Supabase (R5–R9); **tidak ada kode Supabase yang diubah**.

## Output awal AI

Perubahan logo (usulan awal):

1. **Saran — ikon launcher untuk semua platform dari satu logo.** Android memakai ikon adaptive
   (monogram KB di atas latar krem) plus ikon lama untuk API rendah; iOS, macOS, Windows, dan web
   juga diganti agar logonya konsisten.
2. **Saran — splash dua lapis.** Splash native (Android/iOS) untuk momen sebelum Flutter tampil, lalu
   `SplashScreen` Flutter yang menampilkan `assets/images/logo_1.png` sebelum masuk ke layar awal.
3. **Saran — Android 12+ memakai splash sistem.** Pada API 31+ `launch_background` diabaikan dan sistem
   memakai ikon aplikasi, sehingga latar harus diatur lewat `windowSplashScreenBackground`.
4. **Saran — pewaktu splash harus aman.** Timer dibatalkan saat widget dibuang dan navigasi dijaga `mounted`.

Tinjauan Supabase (temuan atas kode basis):

5. **Blocker keamanan — hash kata sandi dapat dibaca klien.** Login membaca `password_hash` dari tabel
   `users` melalui anon key.
6. **Saran — nama file Storage dapat ditebak** karena diturunkan dari email pada bucket publik.
7. **Saran — hapus lalu sisip pada `savePracticeScan` tidak atomik.**
8. **Saran — `inference_time_ms` ditulis dengan nilai tetap 120.**
9. **Saran — `getUserByEmail` dipanggil berulang** hanya untuk mendapat `user_id`.

## Verifikasi dan keputusan

| ID | Level | Bukti | Keputusan dan alasan |
| --- | --- | --- | --- |
| R1 | Saran | Skrip ukur: pada skala awal 0,080 dp/px titik terjauh monogram dari pusat 33,5 dp, melewati batas aman ikon adaptive 33 dp; skala diturunkan ke 0,075 dp/px (≈31,4 dp). Pratinjau topeng lingkaran dan squircle diperiksa visual | **Terima.** Monogram tidak terpotong pada topeng launcher. Belum dibuktikan pada launcher asli; lihat E02 di [verifikasi emulator](emulator-verification.md) |
| R2 | Saran | Dari 15 berkas `AppIcon.appiconset`, **0 memiliki alpha** (diperiksa dengan PIL setelah generate). Versi iOS dibuat full-bleed tanpa border dan tanpa sudut transparan | **Terima.** iOS menolak ikon aplikasi bertransparansi; sudut membulat diberikan sistem. Berkas Android/macOS/Windows/web tetap memakai bentuk logo asli |
| R3 | Saran | Berkas `values-v31/styles.xml` dan `values-night-v31/styles.xml` dibuat; keduanya valid XML. Qualifier `night` mengalahkan `v31`, sehingga varian malam wajib ada agar latar tetap krem | **Terima.** Latar splash seragam krem pada mode terang dan gelap. Perilaku di perangkat belum diuji (E01, E04) |
| R4 | Saran | `splash_screen.dart` (86 baris) membatalkan `Timer` di `dispose`, memakai `mounted`, dan animasi mulai dari opasitas penuh agar tidak berkedip dari splash native. Pencarian di `test/` tidak menemukan rujukan ke `KenaliBatikmuApp` atau `initialScreen` | **Terima guard lokal.** `main.dart` hanya berubah satu baris. Tes yang ada **belum dijalankan** |
| R5 | Blocker keamanan | `auth_provider.dart` baris 178–190: login memanggil `getUserByEmail` lalu memakai `password_hash`; `supabase_service.dart` memakai `select()` tanpa membatasi kolom. Anon key tertanam di `supabase_config.dart` | **Ditunda, menunggu keputusan penulis.** Agar login berjalan, tabel `users` harus dapat dibaca anon, sehingga hash semua pengguna dapat diambil siapa pun yang memegang anon key. Status RLS sebenarnya tidak bisa dilihat dari kode. Dua opsi sudah ditawarkan: migrasi ke Supabase Auth, atau SQL tabel + RLS |
| R6 | Saran | `uploadAvatar` memakai `avatar_<email>.jpg` dan `uploadPracticeImage` memakai `practice_<email>_mod<id>.jpg`, lalu `getPublicUrl` | **Ditunda.** URL foto dapat ditebak bila email diketahui. Usul: path berbasis id acak, atau signed URL |
| R7 | Saran | `savePracticeScan` menjalankan `delete` lalu `insert`; kegagalan insert setelah delete menghapus data lama | **Ditunda.** Usul: `upsert` dengan kunci unik (user, modul, tipe) atau RPC bertransaksi |
| R8 | Saran | `'inference_time_ms': 120` bernilai tetap pada `savePracticeScan` | **Ditunda.** Nilai bukan hasil ukur; ukur sungguhan atau jangan dikirim |
| R9 | Saran | `saveQuizAttempt`, `savePracticeScan`, `syncUserModuleProgress`, dan tiga `fetch*` masing-masing memanggil `getUserByEmail` | **Ditunda.** Satu round-trip tambahan per operasi dan semuanya bergantung pada akses baca `users`. Usul: teruskan `userId` yang sudah ada |

Tidak ada tes regresi baru yang ditulis atau dijalankan pada perubahan ini, dan suite tes yang ada
(11 berkas pada `test/`, sekitar 42 deklarasi menurut hitungan `grep`, bukan hasil `flutter test`) belum dijalankan.
Flutter SDK tidak tersedia pada lingkungan sesi AI, sehingga `flutter analyze`, `dart format`, dan
`flutter test` harus dijalankan penulis. Usulan tes untuk R4 (belum ditulis, belum dijalankan):

```dart
testWidgets('splash moves to next screen after duration', (tester) async {
  await tester.pumpWidget(const MaterialApp(
    home: SplashScreen(nextScreen: Text('next')),
  ));
  expect(find.text('next'), findsNothing);
  await tester.pump(const Duration(milliseconds: 2300));
  await tester.pumpAndSettle();
  expect(find.text('next'), findsOneWidget);
});
```

### Potongan final yang diterima

```dart
// lib/main.dart
import 'screens/splash/splash_screen.dart';
// ...
home: SplashScreen(nextScreen: initialScreen),
```

```dart
// lib/screens/splash/splash_screen.dart (ringkas)
_timer = Timer(widget.duration, _goNext); // 2200 ms

void _goNext() {
  if (!mounted) return;
  Navigator.of(context).pushReplacement(
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}
```

`initialScreen` tetap ditentukan oleh logika lama di `main.dart` (onboarding, login, atau beranda);
splash hanya menunda tampilannya. Logo yang dipakai ialah `assets/images/logo_1.png`, yang sudah
berada di folder aset yang terdaftar pada `pubspec.yaml`.

## Hasil tinjauan integrasi Supabase

- **Terintegrasi pada level kode:** `supabase_flutter` terpasang, `main.dart` memanggil inisialisasi,
  `SupabaseService` mencakup pengguna, modul, motif, kuis, scan, progres, dan Storage, serta
  `SyncProvider` menjalankan antrean offline saat koneksi kembali.
- **Belum dapat dipastikan:** tabel, bucket Storage, dan kebijakan RLS pada proyek Supabase yang sebenarnya,
  karena sesi ini tidak memiliki akses jaringan ke Supabase. Pengujian yang disarankan: daftarkan akun,
  lalu periksa baris baru pada tabel `users`.
- Zip ini hanya berisi aplikasi Flutter; tidak ada backend Python di dalamnya.

## Batas keputusan dan tindak lanjut

- Perubahan ini tidak mengklaim perbaikan keamanan. R5–R9 hanya dicatat dan belum diubah.
- Nama aplikasi Android (`android:label`) tidak diubah karena tidak diminta.
- Pratinjau ikon dibuat dengan skrip (topeng lingkaran/squircle simulasi) dan **bukan** screenshot emulator.
- Pembaruan: belum ada PR dan belum ada review manusia. Tidak ada self-approval atau klaim merge tanpa bukti;
  lihat [review sejawat](peer-review.md) dan [verifikasi merge](merge-verification.md).
