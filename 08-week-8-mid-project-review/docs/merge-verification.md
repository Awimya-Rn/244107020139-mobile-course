# Bukti merge PR

> **STATUS: BELUM ADA PR DAN BELUM ADA MERGE.** Perubahan logo/splash masih berada pada working tree lokal
> (belum di-commit, belum di-push). Dokumen ini disiapkan sebagai kerangka; setiap baris bertanda ☐ harus
> diisi dari hasil nyata di GitHub. Jangan menulis "merged", nomor PR, atau hash commit sebelum benar-benar ada.

Repository: [Kenali-Batikmu/Kenali-Batikmu-Mobile](https://github.com/Kenali-Batikmu/Kenali-Batikmu-Mobile).
Basis: commit `0fc7cf8` (merge PR #15 dari branch `hafizh`), branch lokal `dev`.
Target PR (`dev` atau `main`) belum dikonfirmasi; tentukan mengikuti aturan tim, lalu catat di sini: [isi].

## Ringkasan merge

- [x] PR: [isi: tautan PR] sudah **MERGED ke [isi: branch target]** pada [isi: tanggal dan jam WIB / UTC], oleh [isi: akun].
- [x] Review manusia: **APPROVED oleh [isi: akun reviewer]** pada head [isi: hash head PR].
- [x] CI pada head PR: [isi]. Catatan: salinan proyek ini **tidak memiliki** `.github/workflows`; bila CI belum
  dibuat, tulis "tidak ada CI" dan jangan mengklaim hijau.
- [x] Merge commit: [isi: tautan dan hash].
- [x] Issue: [isi: tautan] **CLOSED** otomatis melalui `Closes #[isi]` pada deskripsi PR.
- [x] Remote `origin/[isi: branch target]` menunjuk merge commit tersebut.
- [x] Diff seluruh tree antara head yang direview dan `origin/[isi: branch target]` kosong, sehingga hasil merge
  sama dengan kode yang diuji dan disetujui.

## Verifikasi repository

Ganti placeholder dengan hash nyata, jalankan, lalu tempel hasilnya.

```sh
git fetch origin
git merge-base --is-ancestor <hash-merge-commit> origin/<branch-target>
echo $?
git diff --stat <hash-head-yang-direview> origin/<branch-target>
git ls-remote origin refs/heads/<branch-target>
```

Hasil: [isi: tempel keluaran perintah].

## Pemeriksaan setelah merge

- [x] Alur CI setelah push ke branch target selesai: [isi: tautan run dan status akhir] (atau "tidak ada CI").
- [x] Branch fitur remote dihapus **hanya setelah** ancestry terhadap branch target terverifikasi (exit 0).
  Branch milik anggota lain (`arifah`, `hafizh`, `ilham`, `julian`, `triya`) tidak disentuh.
- [x] Aturan proteksi/default branch tidak diubah.
- [x] Penyimpangan yang perlu dicatat secara transparan (mis. ukuran PR, penyesuaian target): [isi, atau "tidak ada"].

## Alur yang harus terbukti selesai

Issue → PR → minimal satu review sejawat → tindak lanjut → approval → merge.
Status saat ini: **hanya implementasi lokal yang selesai**; seluruh langkah berikutnya belum.
Lihat [review sejawat](peer-review.md) dan [checklist review](review-checklist.md).
