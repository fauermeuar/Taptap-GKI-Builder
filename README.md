# Taptap-GKI-Builder

Builder kernel GKI 5.10 punya TapTap — hasil adaptasi dari FleurX-GKI-Builder
(zylhdrXP), dengan tiga perubahan:

1. Nama kernel jadi **Taptap-GKI**, dengan versi build tetap **1.0.0**.
   String kernel yang tampil di manager:
   `5.10.270-Taptap-GKI-1.0.0 (aarch64)`.
2. Versi kernel **dipatok di 5.10.270** (tidak mengikuti ujung branch yang
   sekarang sudah 5.10.272).
3. Hasil build diunduh dari **GitHub Actions Artifact** — tidak pakai
   GitHub Release, tidak pakai Telegram.

## Versi 5.10.270 dipatok di mana

Di `config.sh`:

- `KERNEL_COMMIT="41a2213127d9b08076e88c1a70a23ac8f792ea4f"` — commit
  "Merge 5.10.270 into android12-5.10-lts" di repo source
  `zylhdrXP/android_kernel_common-5.10` (Makefile-nya persis 5.10.270).
- `build.sh` clone source, checkout commit itu, lalu **memeriksa**
  `make kernelversion` harus `5.10.270` — kalau bukan, build berhenti.
  Jadi tidak ada risiko versi diam-diam naik.

Catatan: branch `android12-5.10` sendiri tidak pernah berhenti di 5.10.270
(dia melompat dari 5.10.269 ke 5.10.272), makanya yang dipakai commit
penggabungan 5.10.270 di jalur LTS-nya.

## Cara pakai

1. Buat repo GitHub baru, misalnya `Taptap-GKI-Builder`, lalu unggah semua
   file builder ini ke sana (struktur folder `.github/workflows/` ikutkan).
2. Buka tab **Actions** → **Build Taptap-GKI Kernel (5.10.270)** →
   **Run workflow** → pilih varian:
   - `KSUN_SUSFS` — ReSukiSU + SUSFS (bawaan)
   - `Vanilla` — tanpa KernelSU/SUSFS
   - `ReSukiSU_SUSFS` — ReSukiSU + SUSFS
3. Tunggu build selesai (±15–30 menit), lalu unduh hasilnya di bagian
   **Artifacts** di halaman run itu:
   `Taptap-GKI-1.0.0-5.10.270-<varian>.zip` (paket AnyKernel3,
   siap flash) + `build-info.txt` (berisi SHA-256 zip-nya).

## Peringatan

- Zip hasil build adalah paket AnyKernel3 untuk kernel **GKI 5.10 arm64**
  (target sama seperti FleurX-GKI: fleur / Redmi Note 11S 4G / POCO M4 Pro 4G).
  Cadangkan boot/kernel yang sedang dipakai sebelum flash.
- Varian SUSFS memasang ReSukiSU persis seperti builder aslinya.

## Kredit

- Builder & source: zylhdrXP (FleurX-GKI-Builder, android_kernel_common-5.10)
- Kernel: AOSP kernel/common android12-5.10-lts + Linux stable 5.10.270
- ReSukiSU, SUSFS (simonpunk), AnyKernel3, Neutron Clang
