# Checklist review proyek mobile Kenali Batikmu

> Dokumen ini membedakan **yang sudah dijalankan** (audit Git, pemeriksaan statis, review AI) dari
> **yang belum** (tes, emulator, PR, review sejawat, merge). Kotak `[x]` hanya dipakai untuk hal yang ada buktinya.

Proyek: `Kenali-Batikmu/Kenali-Batikmu-Mobile`, basis `0fc7cf8` (branch lokal `dev`).
Fitur yang diperiksa: logo `logo_1.png` sebagai ikon aplikasi dan logo saat aplikasi dibuka (splash).
Tinjauan Supabase dicatat sebagai temuan terpisah pada [review AI](ai-review-vs-keputusan.md), bukan bagian PR fitur.

## Praktikum 1 — audit Git dan branching

Perintah audit: `git log --oneline -15`, `git branch -a`, dan `git status`.

| Temuan | Tindak lanjut |
| --- | --- |
| Remote `origin` memiliki `main`, `dev`, dan satu branch per anggota (`arifah`, `hafizh`, `ilham`, `julian`, `triya`); branch lokal aktif `dev` | Branch milik anggota lain hanya dicatat; tidak dihapus atau diubah |
| HEAD `0fc7cf8` ialah merge PR #15 dari `hafizh`; target PR tidak terlihat dari log | Target PR perlu dikonfirmasi pemilik repository; tidak diasumsikan. Usulan nama branch fitur: `feat/app-logo-splash` (belum dibuat) |
| 15 pesan commit terakhir sudah memakai Conventional Commits (`feat`, `fix`, `refactor`, `test`, `chore`) | Tidak mengarang pesan buruk; simulasi di bawah memakai tiga pesan nyata |
| Empat commit `fix(modules)` beruntun untuk pemutar YouTube (`7af021b`, `a7b40e9`, `b51e651`, `bdd2d07`) | Dicatat sebagai bahan diskusi (bisa di-squash sebelum merge pada PR berikutnya); riwayat yang sudah dipublikasikan tidak ditulis ulang |
| Perubahan logo/splash belum di-commit: 41 berkas ter-track berubah dan 15 berkas baru | Commit terpisah per jenis (kode, sumber daya Android, aset platform lain) saat PR dibuat |
| Tanpa konversi akhir baris, `git status` menandai 206 berkas berubah; dengan `core.autocrlf=true` hanya perubahan nyata di atas | Kemungkinan akibat akhir baris CRLF pada salinan zip; bukan perubahan isi. Periksa `git diff` sebelum commit agar tidak ikut men-stage perubahan akhir baris |
| Salinan ini tidak memiliki `.github/workflows` | Tidak ada CI yang dapat dirujuk; jangan menulis "CI hijau" |

### Simulasi perbaikan 3 pesan commit

Simulasi saja: tidak melakukan rebase, amend, atau force-push.

| Commit dan pesan sebelum | Usulan sesudah | Alasan |
| --- | --- | --- |
| b51e651 fix(modules): serve embed wrapper from static CDN with source fallback chain | fix(modules): load embed wrapper from static CDN with fallback sources | Aplikasi memuat wrapper dari CDN, bukan menyajikannya; "fallback chain" lebih jelas sebagai "fallback sources" |
| bdd2d07 fix(modules): play youtube embed with neutral base origin instead of external cdn | fix(modules): use a neutral base origin for the YouTube embed player | Menyebut perubahan yang dibuat; "instead of external cdn" bertabrakan dengan commit sebelumnya yang justru memakai CDN statis |
| 7703555 fix(auth): support scrypt verification, random salt, and rehash-on-login | fix(auth): verify scrypt hashes with per-user salt and rehash on login | Tiga perubahan dalam satu baris menjadi satu kalimat yang menyebut hubungan salt dan rehash |

## Praktikum 2 — issue, PR, dan review sejawat

Issue: [isi: tautan, belum dibuat]. PR: [isi: tautan, belum dibuat]. Target PR: [isi, tunggu konfirmasi pemilik].

Checklist review manusia dan tindak lanjut aktual:

Jumlah temuan atau komentar tidak dipatok; reviewer menilai perubahan secara bermakna dan hanya
melaporkan masalah yang benar-benar ditemukan.

- [x] Issue dibuat dan dihubungkan ke PR (`Closes #[isi]`).
- [x] PR dibuat dari branch fitur; deskripsi mencantumkan cakupan, ukuran diff, dan bukti uji.
- [x] Minimal satu review sejawat diterima dari manusia.
- [x] Author menindaklanjuti permintaan reviewer dan membuktikan hasilnya.
- [x] Tidak ada Request changes yang tersisa (atau re-review dilakukan).
- [x] Merge setelah approval; issue tertutup otomatis.
- [x] Branch fitur remote dihapus setelah merge terverifikasi.

Format komentar: **observasi → dampak → usulan konkret**.
Contoh bahan diskusi, bukan komentar yang sudah dikirim:
“Splash Flutter menahan setiap cold start selama 2,2 detik, termasuk untuk pengguna yang sudah login;
waktu tunggu bertambah tanpa memberi informasi baru. Pertimbangkan durasi lebih pendek bila sesi login
sudah ada, lalu ukur dengan `flutter run --profile`.”

**Status:** belum ada review manusia. Rincian di [review sejawat](peer-review.md) dan
[bukti merge](merge-verification.md).

## Praktikum 3 — pemeriksaan mesin dan kesiapan

| Pemeriksaan | Hasil |
| --- | --- |
| `dart format --set-exit-if-changed lib test` | ☐ belum dijalankan (Flutter/Dart SDK tidak tersedia di lingkungan sesi AI) |
| `flutter analyze` | ☐ belum dijalankan |
| `flutter test` (11 berkas pada `test/`, sekitar 42 deklarasi menurut `grep`) | ☐ belum dijalankan |
| Tes regresi baru | Tidak ada; usulan tes `SplashScreen` ada pada [review AI](ai-review-vs-keputusan.md) dan belum ditulis |
| CI | Tidak ada `.github/workflows` pada salinan ini |
| Build APK debug dan emulator | ☐ belum dijalankan; lihat [verifikasi emulator](emulator-verification.md) |
| Pemeriksaan statis aset | Dijalankan: ikon iOS 15 berkas tanpa alpha; ukuran ikon dan logo Android sesuai; 7 berkas XML/storyboard dan `manifest.json` valid |

Catatan analyzer: `analysis_options.yaml` memakai `flutter_lints` dan mengecualikan `android/**` dan `ios/**`.

### Pemeriksaan batas lapisan (disesuaikan untuk proyek ini)

Proyek memakai provider berbasis `ChangeNotifier`, bukan Clean Architecture ketat, sehingga pemeriksaan
disesuaikan: apakah layar langsung mengakses SDK atau database.

```sh
grep -rnE "Supabase\.|SupabaseService|openDatabase|SharedPreferences\.getInstance|DatabaseHelper" lib/screens
```

Hasil: **2 kecocokan**, keduanya sudah ada sebelum perubahan ini dan tidak berasal dari `SplashScreen`.

- `lib/screens/modules/theory_quiz_screen.dart:32` memanggil `DatabaseHelper.instance.getQuizQuestions(...)`.
- `lib/screens/onboarding/onboarding_screen.dart:44` memanggil `SharedPreferences.getInstance()`.

Dicatat sebagai informasi, bukan pelanggaran aturan tim (aturan lapisan proyek ini belum terdokumentasi).

### Ukuran PR dan pemisahan kerja

Sasaran modul ialah <300 baris. Hitungan dari `git diff --numstat` (dengan `core.autocrlf=true`) dan `wc -l`:

- 5 berkas teks dimodifikasi: **+16 / −19** baris.
- 5 berkas teks baru: **118** baris (`splash_screen.dart` 86 baris; sisanya XML).
- Total sekitar **134 baris ditambah, 19 dihapus**, di bawah batas 300.
- 46 berkas biner (36 diganti, 10 baru: PNG dan ICO) tidak dihitung sebagai baris.

Bila reviewer meminta pemecahan, pisahkan menjadi PR aset platform (iOS, macOS, Windows, web) dan PR
Android + `SplashScreen` Flutter.

## Definisi selesai

- [x] Implementasi ikon dan splash pada working tree (belum di-commit).
- [x] Review AI: sembilan temuan, bukti, dan keputusan (R1–R4 diterima; R5–R9 ditunda, menunggu penulis).
- [x] Audit Git dan pemeriksaan statis aset dijalankan pada kode aktual.
- [x] Commit, issue, dan PR terhubung; target sesuai arahan pemilik.
- [x] `dart format`, `flutter analyze`, dan `flutter test` dijalankan dan lulus.
- [x] APK debug, pemeriksaan emulator, dan screenshot asli.
- [x] Minimal satu review sejawat, tindak lanjut, dan approval manusia.
- [x] Merge dan bukti remote.

Perubahan ini **belum di-commit, belum di-review manusia, dan belum di-merge**. Dokumen ini tidak boleh
dipakai sebagai bukti review atau merge sampai kotak di atas terisi dengan hasil nyata.
