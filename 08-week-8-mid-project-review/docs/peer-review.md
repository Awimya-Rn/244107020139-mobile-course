# Review sejawat dan tindak lanjut

> **STATUS: BELUM ADA REVIEW SEJAWAT.** PR belum dibuat, sehingga belum ada reviewer, keputusan, maupun
> masukan. Isi kolom bertanda [isi] hanya dari review asli di GitHub. Review AI atau bot (mis. Copilot)
> **tidak dihitung** sebagai review sejawat; syaratnya adalah minimal satu review dan approval dari manusia.

PR: [isi: tautan PR], target [isi: branch target].

- Reviewer manusia: [isi: akun], [isi: peran, mis. anggota kolaborator repository].
- Keputusan: [isi: Approved / Changes requested / Commented] pada [isi: tanggal dan jam].
- [Review asli](isi-tautan-review).
- Commit yang direview: `[isi: hash]`; source PR tetap pada commit yang sama: [isi: ya/tidak].
- Inline comment atau Request changes: [isi].
- Syarat minimal satu review sejawat: [ ] terpenuhi.

## Fokus yang disarankan untuk reviewer

Perubahan yang diajukan hanya ikon aplikasi, splash native, dan `SplashScreen` Flutter
(sekitar 134 baris teks ditambah dan 19 dihapus, ditambah 46 berkas gambar). Hal yang layak dinilai:

- `lib/main.dart` hanya berubah satu baris (`home: SplashScreen(nextScreen: initialScreen)`).
- `lib/screens/splash/splash_screen.dart`: pembatalan `Timer`, guard `mounted`, dan durasi 2,2 detik.
- Berkas sumber daya Android (`mipmap-anydpi-v26`, `values-v31`, `values-night-v31`, `launch_background`).
- Apakah durasi splash wajar untuk pengguna yang sudah login.

Di luar cakupan PR ini: temuan R5–R9 pada [review AI](ai-review-vs-keputusan.md) (keamanan dan efisiensi
kode Supabase). Reviewer tidak perlu menyetujuinya lewat PR ini; bila diputuskan dikerjakan, buat issue dan PR terpisah.

## Masukan dan tindak lanjut

Isi satu baris per masukan nyata. Tulis hanya masukan yang benar-benar diberikan reviewer.

| Masukan reviewer | Tindak lanjut | Hasil |
| --- | --- | --- |
| [isi] | [isi: perintah/commit yang dijalankan] | [isi: bukti, mis. analyzer bersih, jumlah tes lulus, CI] |

Hasil pengujian ulang setelah review: [isi: hasil `flutter analyze` dan `flutter test`, jumlah tes lulus].

Pernyataan yang perlu dijaga tetap jujur:

- Bila review tidak menyebut reviewer menjalankan tes sendiri, jangan menulis bahwa reviewer menjalankannya.
- Bila emulator tidak diuji ulang setelah review, tulis bahwa bukti emulator merujuk commit yang sama
  atau diambil sebelumnya; jangan menyiratkan pengujian baru.
- Bila tidak ada perubahan kode setelah review, catat bahwa re-review tidak diperlukan hanya jika
  keputusan reviewer sudah Approve dan tidak ada Request changes.
- Bila ukuran diff melampaui sasaran (<300 baris) atau ada penyimpangan lain, ungkapkan dalam PR dan di sini.
  Perubahan ini sekitar 153 baris teks, di bawah batas, tidak termasuk berkas gambar.

## Status akhir pemeriksaan

- [x] Minimal satu review sejawat dan approval manusia.
- [x] Permintaan reviewer ditindaklanjuti dan hasilnya dibuktikan.
- [x] Source PR tetap sama dengan commit yang di-approve (atau re-review dilakukan).
- [x] Merge ke [isi: branch target]; lihat [bukti merge](merge-verification.md).

Review dan keputusan reviewer harus dapat diperiksa melalui tautan review asli di GitHub.
