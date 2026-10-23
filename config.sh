#!/bin/bash
# config.sh - Configuration for Taptap-GKI Builder (kernel dipatok di 5.10.270)

# ==========================================
# 1. Project Configuration
# ==========================================
KERNEL_NAME="Taptap-GKI"
KERNEL_SOURCE="https://github.com/zylhdrXP/android_kernel_common-5.10"
# Basis = branch utama zylhdrXP pada commit .269 — garis keturunan semua
# kernel FleurX yang terbukti boot. Versi .270 dicapai dengan tambalan
# (patches/stable-5.10.270.patch + overlay-270/), BUKAN dengan mengambil
# jalur -lts Google polos — kernel dari jalur -lts terbukti tidak boot.
KERNEL_BASE_COMMIT="82ea428432eb2b6266bf84cee1ac61a02c6d4bc2"
KERNEL_TARBALL_URL="https://codeload.github.com/zylhdrXP/android_kernel_common-5.10/tar.gz/82ea428432eb2b6266bf84cee1ac61a02c6d4bc2"
KERNEL_VERSION="5.10.270"
BUILD_VERSION="1.0.0"
KBUILD_USER="taptap"
KBUILD_HOST="fauermeuar"
TIMEZONE="Asia/Jakarta"

# ==========================================
# 2. AnyKernel3 Configuration
# ==========================================
ANYKERNEL_REPO="https://github.com/zylhdrXP/AnyKernel3"
ANYKERNEL_BRANCH="gki"

# ==========================================
# 3. Toolchain Configuration
# ==========================================
CLANG_URL="https://github.com/Neutron-Toolchains/clang-build-catalogue/releases/download/06092026/neutron-clang-06092026.tar.zst"

# ==========================================
# 4. Default Build Options
# ==========================================
# Options: Vanilla, KSUN_SUSFS, ReSukiSU_SUSFS
DEFAULT_VARIANT="KSUN_SUSFS"
