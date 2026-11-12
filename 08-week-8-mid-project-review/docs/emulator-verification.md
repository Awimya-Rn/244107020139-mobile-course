# Verifikasi emulator Android

> **STATUS: SEBAGIAN TERVERIFIKASI (5 SCREENSHOT PERANGKAT).** Dokumen ini diperbarui hanya
> berdasarkan lima gambar bukti yang dilampirkan (`splash.png`, `onboarding1.jpg`,
> `onboarding2.jpg`, `onboarding3.jpg`, dan `login_after_onboarding.jpg`). Bagian "Pemeriksaan
> statis" tetap memuat hasil pemeriksaan kode; baris atau kolom yang tidak tampak pada kelima
> gambar tersebut dibiarkan belum terisi / belum diuji dan tidak diisi dari perkiraan.

Tanggal pengujian: [tidak tercantum pada gambar; waktu pada status bar pukul 19.52–20.00].
Catatan sumber gambar: kelima tangkapan layar berasal dari perangkat fisik Android (`splash.png`
berformat PNG, sedangkan empat berkas onboarding/login berformat JPG), bukan seluruhnya hasil
tangkapan langsung `adb exec-out screencap -p` pada AVD emulator.

## Lingkungan dan provenance

| Item | Nilai |
| --- | --- |
| AVD / perangkat | [tidak tercantum pada 5 gambar — tampak perangkat fisik Android (dual SIM, Wi-Fi, navigasi 3 tombol), bukan AVD emulator] |
| Versi Android / API | [tidak tercantum pada 5 gambar]. Uji minimal satu AVD **API 31+** (splash sistem) dan satu **API 21–30** (splash lama) |
| Resolusi dan densitas | [densitas tidak tercantum pada 5 gambar; layar potret rasio 9:20] |
| Application ID | `com.example.batikmu` (dari `android/app/build.gradle.kts`) |
| Build | debug, dari commit [tidak tercantum pada 5 gambar] |
| Flutter / Dart | [tidak tercantum pada 5 gambar]; batas SDK proyek `sdk: ^3.13.1` |
| Pembanding | [tidak tercantum pada 5 gambar] |

## Pemeriksaan statis yang sudah dijalankan

Dijalankan pada folder proyek hasil perubahan. Ini bukan pengganti uji emulator.

| Pemeriksaan | Hasil |
| --- | --- |
| Ikon iOS `AppIcon.appiconset` | 15 berkas, **0 berisi alpha** (iOS menolak ikon bertransparansi) |
| Ukuran `ic_launcher.png` (mdpi → xxxhdpi) | 48, 72, 96, 144, 192 px |
| Ukuran `ic_launcher_foreground.png` | 108, 162, 216, 324, 432 px (layer adaptive 108 dp) |
| Ukuran `launch_logo.png` | 160, 240, 320, 480, 640 px (160 dp di tiap densitas) |
| XML dan storyboard yang diubah/dibuat | 7 berkas (adaptive icon, `colors.xml`, `styles.xml` v31 dan night-v31, dua `launch_background.xml`, `LaunchScreen.storyboard`) valid saat di-parse; `web/manifest.json` valid JSON |
| Windows `app_icon.ico` | berisi 16, 24, 32, 48, 64, 128, 256 px |
| Jarak terjauh monogram dari pusat layer adaptive | ≈31,4 dp (batas aman 33 dp) |

Pratinjau topeng lingkaran/squircle dibuat dengan skrip untuk memeriksa pemotongan; itu **bukan**
screenshot emulator dan tidak boleh dilampirkan sebagai bukti emulator.

## Skenario yang harus dijalankan

| ID | Langkah | Hasil yang diharapkan | Hasil teramati |
| --- | --- | --- | --- |
| E01 | Install APK, cold launch pada AVD API 31+ | Splash sistem: ikon KB di atas latar krem, lalu `SplashScreen` Flutter menampilkan logo sekitar 2,2 detik tanpa kedipan putih | ⚠ sebagian diamati (`splash.png`): ikon KB tampil di tengah dalam squircle krem, namun latar luar splash sistem tampak gelap/hitam (bukan krem), dan belum ada tangkapan terpisah untuk `SplashScreen` Flutter maupun bukti AVD API 31+ |
| E02 | Lihat ikon di home screen dan app drawer | Ikon KB tampil utuh pada bentuk topeng launcher (tidak terpotong) | ☐ belum diuji (tidak ada gambar home screen / app drawer dalam 5 gambar) |
| E03 | Cold launch pada AVD API 21–30 | Latar krem dengan logo 160 dp di tengah (dari `launch_background`), lalu splash Flutter | ☐ belum diuji (tidak ada bukti AVD API 21–30 dalam 5 gambar) |
| E04 | Aktifkan mode gelap (`adb shell cmd uimode night yes`), cold launch | Latar splash tetap krem; logo terlihat jelas | ⚠ sebagian diamati (`splash.png`): pada tampilan splash yang tertangkap, latar luar layar berwarna gelap/hitam (tidak tetap krem penuh), sedangkan ikon KB di dalam squircle krem tetap terlihat jelas |
| E05 | `adb shell pm clear com.example.batikmu`, cold launch | Setelah splash, tujuan sesuai logika `initialScreen` untuk pengguna baru | ☑ teramati (`onboarding1.jpg`–`onboarding3.jpg`, `login_after_onboarding.jpg`): setelah splash, aplikasi menampilkan 3 layar onboarding (*Kenali Warisan Leluhur Nusantara* → *Belajar Ragam & Goresan Canting* → *Pindai Cerdas Deteksi Realtime*) lalu menuju layar Login (*Jelajahi Keindahan Batik Nusantara*) |
| E06 | Login, tutup aplikasi, cold launch | Setelah splash, tujuan sesuai logika `initialScreen` untuk pengguna yang sudah login | ☐ belum diuji (`login_after_onboarding.jpg` hanya menampilkan formulir login kosong, belum ada bukti sesudah login) |
| E07 | Layar kecil (`wm size 840x1470`) dan `font_scale=1.3` | Logo tidak terpotong dan tetap di tengah | ☐ belum diuji (tidak ada bukti pengaturan layar kecil / `font_scale=1.3` dalam 5 gambar) |
| E08 | Mode pesawat, cold launch | Splash tetap tampil dan aplikasi lanjut tanpa crash (Supabase gagal terhubung dengan aman) | ☐ belum diuji (status bar pada kelima gambar menunjukkan Wi-Fi dan sinyal seluler aktif, bukan mode pesawat) |
| E09 | Tekan Back saat splash tampil | Aplikasi keluar tanpa exception atau pesan timer tertunda pada log Flutter | ☐ belum diuji (tidak ada bukti uji tombol Back maupun log Flutter dalam 5 gambar) |
| E10 | Pulihkan ukuran, font, dan tema | Pengaturan emulator kembali normal | ☐ belum diuji (tidak ada bukti dalam 5 gambar) |

iOS dan macOS tidak dapat diuji tanpa macOS dan Xcode; uji `LaunchScreen.storyboard` dan `AppIcon`
hanya bila perangkat tersedia.

## Bukti gambar

### Gambar yang tersedia (5 berkas terlampir)

| File | Isi yang teramati | Status |
| --- | --- | --- |
| [splash.png](../screenshots/splash.png)| Tampilan awal peluncuran aplikasi (pukul 19.52): ikon monogram `KB` dalam squircle krem berornamen daun di tengah layar dengan latar luar gelap/hitam (terkait E01/E04) | ☑ ada |
| [onboarding1.png](../screenshots/onboarding1.png) | Layar onboarding 1/3 (pukul 19.56): badge `KENALI BUDAYA`, judul *Kenali Warisan Leluhur Nusantara*, tombol `Lewati` dan `Lanjut ->` (E05) | ☑ ada |
| [onboarding2.png](../screenshots/onboarding2.png) | Layar onboarding 2/3 (pukul 20.00): badge `BELAJAR & MENGGAMBAR`, judul *Belajar Ragam & Goresan Canting*, tombol `Lewati` dan `Lanjut ->` (E05) | ☑ ada |
| [onboarding3.png](../screenshots/onboarding3.png) | Layar onboarding 3/3 (pukul 20.00): badge `DETEKSI REALTIME`, judul *Pindai Cerdas Deteksi Realtime*, tombol `Mulai Sekarang ->` (E05) | ☑ ada |
| [login_after_onboarding.png](../screenshots/login_after_onboarding.png) | Layar tujuan setelah onboarding selesai, judul *Jelajahi Keindahan Batik Nusantara*, input `Email` dan `Kata Sandi`, opsi `Ingat saya di perangkat ini`, serta tombol `Masuk` (E05) | ☑ ada |

Screenshot ini bukan golden/snapshot test dan bukan gambar hasil generator yang diklaim sebagai aplikasi.
Splash native hanya tampak sebentar; ambil screenshot segera setelah perintah launch.

## Mengulang pengujian

```sh
flutter clean
flutter pub get
flutter build apk --debug --target-platform android-arm64
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
adb -s emulator-5554 shell monkey -p com.example.batikmu -c android.intent.category.LAUNCHER 1
adb -s emulator-5554 exec-out screencap -p > splash-native.png
sleep 1
adb -s emulator-5554 exec-out screencap -p > splash-flutter.png
adb -s emulator-5554 shell cmd uimode night yes
adb -s emulator-5554 shell wm size 840x1470
adb -s emulator-5554 shell settings put system font_scale 1.3
# Uji skenario E07, lalu pulihkan:
adb -s emulator-5554 shell wm size reset
adb -s emulator-5554 shell settings put system font_scale 1.0
adb -s emulator-5554 shell cmd uimode night no