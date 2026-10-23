#!/bin/bash
# config.sh - Configuration for Taptap-GKI Builder (kernel dipatok di 5.10.270)

# ==========================================
# 1. Project Configuration
# ==========================================
KERNEL_NAME="Taptap-GKI"
KERNEL_SOURCE="https://github.com/zylhdrXP/android_kernel_common-5.10"
KERNEL_BRANCH="android12-5.10"
# Commit ini = "Merge 5.10.270 into android12-5.10-lts" (Makefile: 5.10.270).
# Source TIDAK mengikuti ujung branch (yang sekarang sudah 5.10.272) —
# build selalu berhenti tepat di commit ini.
KERNEL_COMMIT="41a2213127d9b08076e88c1a70a23ac8f792ea4f"
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
