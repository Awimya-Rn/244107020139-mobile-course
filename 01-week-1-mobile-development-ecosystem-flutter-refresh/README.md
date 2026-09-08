# Refleksi Teknis

---

## 1. Kapan Native Lebih Tepat Dipilih daripada Cross-Platform?

Pendekatan native lebih unggul dan tepat dipilih dalam kondisi berikut:

* **Integrasi Perangkat Keras dan API Tingkat Rendah:** Aplikasi membutuhkan akses intensif ke hardware spesifik, driver Bluetooth/BLE kustom, sensor khusus, kamera level rendah, atau framework eksklusif platform (misalnya ARKit atau CoreML).
* **Performa Ekstrem dan Latensi Nol:** Aplikasi dengan kebutuhan pemrosesan grafis berat, game 3D, rendering real-time, atau manipulasi audio/video berkecepatan tinggi tanpa overhead jembatan komunikasi (*bridge/FFI*).
* **Dukungan Fitur Baru Hari Pertama (Zero-Day OS Support):** Kebutuhan segera mengadopsi API, fitur privasi baru, atau perubahan desain sistem operasi pada hari pertama pembaruan OS diluncurkan.
* **Ukuran Biner dan Jejak Memori yang Sangat Ketat:** Native menghasilkan ukuran aplikasi yang lebih minimalis dan penggunaan memori yang lebih efisien karena tidak menyertakan runtime atau engine rendering terpisah.

---

## 2. Hubungan Perubahan State dengan Widget Tree dan UI Deklaratif

Dalam paradigma deklaratif, antarmuka merupakan fungsi langsung dari state: `UI = f(state)`.

* **Blueprint vs Elemen Riil:** *Widget Tree* adalah struktur blueprint ringan (*immutable*) yang mendeskripsikan tampilan pada kondisi data saat ini.
* **Pemicu Pembaruan (State Mutation):** Saat state berubah (misalnya pemanggilan `setState` atau mutasi pada *state management*), framework menandai bagian widget terkait sebagai *dirty*.
* **Rekonstruksi dan Komparasi (Rebuild & Diffing):** Framework membangun ulang sub-tree widget yang relevan, lalu membandingkannya (*diffing*) dengan representasi pohon elemen/render sebelumnya.
* **Efisiensi Render:** Hanya elemen yang mengalami perbedaan data atau konfigurasi yang akan diperbarui pada layar fisik, menjaga performa tetap optimal tanpa manipulasi DOM/view secara manual.

---

## 3. Manfaat Commit Kecil dengan Pesan Jelas untuk Tim dan Portfolio

### Manfaat bagi Pekerjaan Tim:
* **Review Kode Lebih Efisien:** Pull Request menjadi lebih terfokus, cepat dipahami, dan memudahkan reviewer menemukan potensi bug.
* **Pelacakan dan Debugging Cepat:** Mempermudah isolasi bug menggunakan tools seperti `git bisect` serta meminimalkan risiko konflik kode (*merge conflicts*).
* **Rollback yang Aman:** Memungkinkan pembatalan perubahan fitur secara spesifik (`git revert`) tanpa mengorbankan progres pekerjaan lain.

### Manfaat bagi Portfolio:
* **Transparansi Pola Pikir:** Menunjukkan kemampuan berpikir modular dan cara Anda memecah masalah besar menjadi langkah-langkah solutif yang terstruktur.
* **Standar Kerja Profesional:** Memperlihatkan kepatuhan terhadap standar industri (seperti *Conventional Commits*), kedisiplinan versi, dan kesiapan berkolaborasi di lingkungan produksi nyata.