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

## Versi 5.10.270 didapat dari mana

Basisnya **bukan** jalur -lts Google polos (kernel dari jalur itu terbukti
tidak boot di fleur). Resepnya:

1. Basis = branch utama zylhdrXP di commit `82ea4284` (5.10.269) — garis
   keturunan semua kernel FleurX yang terbukti boot, lengkap dengan
   patchset custom-nya (scheduler BORE, governor REFLEX/SCHEDHORIZON,
   iosched ADIOS, dll).
2. Dinaikkan ke 5.10.270 dengan `patches/stable-5.10.270.patch` — delta
   resmi 5.10.269 → 5.10.270 dari jalur -lts Google (173 file).
3. 8 file yang tambalannya bertabrakan dengan isi branch utama diganti
   utuh dari folder `overlay-270/` — isinya persis resolusi gabungan
   resmi Google (terverifikasi byte-for-byte sama dengan hasil merge
   Google di branch utama).

`build.sh` memeriksa hasil akhirnya: `make kernelversion` harus
`5.10.270` dan penanda basis branch utama (`CONFIG_SCHED_BORE=y`) harus
ada — kalau tidak, build berhenti.

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

## Catatan build di GitHub Actions

- Link kernel memakai **ThinLTO** (diatur otomatis di `build.sh`), bukan LTO
  penuh — link LTO penuh kehabisan RAM di runner GitHub (proses mati
  "Killed" di tahap `LTO vmlinux.o`). Swap workflow diset 16GB sebagai
  cadangan.

## Peringatan

- Zip hasil build adalah paket AnyKernel3 untuk kernel **GKI 5.10 arm64**
  (target sama seperti FleurX-GKI: fleur / Redmi Note 11S 4G / POCO M4 Pro 4G).
  Cadangkan boot/kernel yang sedang dipakai sebelum flash.
- Varian SUSFS memasang ReSukiSU persis seperti builder aslinya.

## Kredit

- Builder & source: zylhdrXP (FleurX-GKI-Builder, android_kernel_common-5.10)
- Kernel: AOSP kernel/common android12-5.10-lts + Linux stable 5.10.270
- ReSukiSU, SUSFS (simonpunk), AnyKernel3, Neutron Clang
