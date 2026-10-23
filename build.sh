#!/bin/bash
# build.sh - Taptap-GKI Builder (5.10 Only, kernel dipatok di 5.10.270)
# Hasil akhir ditaruh di folder artifacts/ untuk diunduh dari GitHub Actions.

set -e

if [ ! -f "config.sh" ]; then
    echo "Error: config.sh not found!"
    exit 1
fi
source config.sh

# Inputs
VARIANT=${1:-$DEFAULT_VARIANT}

WORKDIR="$(pwd)"
OUTDIR="$WORKDIR/out"
KSRC="$WORKDIR/ksrc"
ARTIFACT_DIR="$WORKDIR/artifacts"

# Versi build tetap: string kernel menjadi 5.10.270-Taptap-GKI-1.0.0
RELEASE="$BUILD_VERSION"

KERNEL_DEFCONFIG="gki_defconfig"
SUSFS_BRANCH="gki-android12-5.10"

sudo timedatectl set-timezone "$TIMEZONE" || export TZ="$TIMEZONE"

echo "-> Downloading and setting up Clang..."
CLANG_DIR="$WORKDIR/clang"
if [ ! -d "$CLANG_DIR" ]; then
    wget -qO clang_archive "$CLANG_URL"
    mkdir -p "$CLANG_DIR"
    if [[ "$CLANG_URL" == *".tar.zst" ]]; then
        tar -I zstd -xf clang_archive -C "$CLANG_DIR"
    elif [[ "$CLANG_URL" == *".tgz" ]] || [[ "$CLANG_URL" == *".tar.gz" ]]; then
        tar -xf clang_archive -C "$CLANG_DIR"
    fi
    rm -f clang_archive
fi
export PATH="${CLANG_DIR}/bin:$PATH"
COMPILER_STRING=$(clang --version | head -n 1 | sed 's/(https..*//' | sed 's/ version//')

echo "-> Cloning Kernel Source (full clone, perlu commit lama)..."
if [ ! -d "$KSRC" ]; then
    git clone -b "$KERNEL_BRANCH" "$KERNEL_SOURCE" "$KSRC"
fi

cd "$KSRC"
git checkout -f "$KERNEL_COMMIT"
LINUX_VERSION=$(make kernelversion)
echo "-> Kernel source commit: $(git rev-parse HEAD)"
echo "-> Kernel version: $LINUX_VERSION"
if [ "$LINUX_VERSION" != "$KERNEL_VERSION" ]; then
    echo "Error: versi kernel $LINUX_VERSION, bukan $KERNEL_VERSION yang dipatok di config.sh!"
    exit 1
fi
k_lastcommit=$(git rev-parse --short HEAD)

mkdir -p "$ARTIFACT_DIR"

echo "-> Building Variant: $VARIANT"
cd "$KSRC"

# Reset kernel source to clean state (tetap di commit yang dipatok)
git checkout -f "$KERNEL_COMMIT"
git checkout . -f
git clean -fd

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"

# ReSukiSU and SUSFS
if [ "$VARIANT" == "ReSukiSU_SUSFS" ] || [ "$VARIANT" == "KSUN_SUSFS" ]; then
    echo "-> Setting up ReSukiSU and SUSFS..."
    # Remove existing KernelSU
    for KSU_PATH in drivers/staging/kernelsu drivers/kernelsu KernelSU KernelSU-Next; do
        if [[ -d $KSU_PATH || -L $KSU_PATH ]]; then
            echo "Removing existing $KSU_PATH"
            KSU_DIR=$(dirname "$KSU_PATH")
            [[ -f "$KSU_DIR/Kconfig" ]] && sed -i '/kernelsu/d' "$KSU_DIR/Kconfig"
            [[ -f "$KSU_DIR/Makefile" ]] && sed -i '/kernelsu/d' "$KSU_DIR/Makefile"
            rm -rf $KSU_PATH
        fi
    done

    # ReSukiSU
    curl -LSs "https://raw.githubusercontent.com/ReSukiSU/ReSukiSU/main/kernel/setup.sh" | bash

    # SUSFS
    if [ -d "$WORKDIR/susfs4ksu" ]; then
        SUSFS_DIR="$WORKDIR/susfs4ksu"
    else
        SUSFS_DIR="$WORKDIR/susfs"
    fi
    if [ ! -d "$SUSFS_DIR" ]; then
        git clone --depth=1 -q https://gitlab.com/simonpunk/susfs4ksu -b "$SUSFS_BRANCH" "$SUSFS_DIR"
    fi

    SUSFS_PATCHES="${SUSFS_DIR}/kernel_patches"
    cp -R "$SUSFS_PATCHES"/fs/* ./fs/
    cp -R "$SUSFS_PATCHES"/include/* ./include/

    patch -p1 < "$SUSFS_PATCHES/50_add_susfs_in_${SUSFS_BRANCH}.patch" || true

    # Apply extra ReSukiSU and SUSFS configs
    cat << EOF >> arch/arm64/configs/$KERNEL_DEFCONFIG
# Extras
CONFIG_OVERLAY_FS_XINO_AUTO=y
CONFIG_KALLSYMS=y
CONFIG_TMPFS_POSIX_ACL=y
# KSU
CONFIG_KSU=y
# CONFIG_KSU_DEBUG is not set
# CONFIG_KSU_TOOLKIT_SUPPORT is not set
# CONFIG_KSU_DISABLE_MANAGER is not set
# CONFIG_KSU_DISABLE_POLICY is not set
CONFIG_KSU_MULTI_MANAGER_SUPPORT=y
# CONFIG_KSU_TRACEPOINT_HOOK is not set
# CONFIG_KSU_MANUAL_HOOK is not set
CONFIG_KSU_SUSFS=y
CONFIG_KSU_SUSFS_SUS_PATH=y
CONFIG_KSU_SUSFS_SUS_MOUNT=y
CONFIG_KSU_SUSFS_SUS_KSTAT=y
CONFIG_KSU_SUSFS_SPOOF_UNAME=y
CONFIG_KSU_SUSFS_ENABLE_LOG=y
CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y
CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y
CONFIG_KSU_SUSFS_OPEN_REDIRECT=y
CONFIG_KSU_SUSFS_SUS_MAP=y
EOF

    SUSFS_VERSION=$(grep -E '^#define SUSFS_VERSION' ./include/linux/susfs.h | cut -d' ' -f3 | sed 's/"//g')
else
    # Vanilla config
    SUSFS_VERSION="None"
fi

# Set Localversion
./scripts/config --file arch/arm64/configs/$KERNEL_DEFCONFIG --set-str CONFIG_LOCALVERSION "-$KERNEL_NAME-$RELEASE"
./scripts/config --file arch/arm64/configs/$KERNEL_DEFCONFIG --disable CONFIG_LOCALVERSION_AUTO
sed -i 's/echo "+"/# echo "+"/g' scripts/setlocalversion

# Build Variables
export KBUILD_BUILD_USER="$KBUILD_USER"
export KBUILD_BUILD_HOST="$KBUILD_HOST"
export KBUILD_BUILD_TIMESTAMP=$(date)
export KCFLAGS="-w"

MAKE_ARGS=(
  O=$OUTDIR
  ARCH=arm64
  LLVM=1
  LLVM_IAS=1
  CROSS_COMPILE=aarch64-linux-gnu-
  CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
  CC=clang
)

echo "-> Building Kernel..."
echo "   Kernel : $LINUX_VERSION ($k_lastcommit)"
echo "   Variant: $VARIANT"

make "${MAKE_ARGS[@]}" $KERNEL_DEFCONFIG
make -j$(nproc --all) "${MAKE_ARGS[@]}"

KERNEL_IMAGE="$OUTDIR/arch/arm64/boot/Image"
if [ ! -f "$KERNEL_IMAGE" ]; then
    echo "-> Build Failed!"
    exit 1
fi

echo "-> Build Successful!"

# AnyKernel Packaging
cd "$WORKDIR"
if [ ! -d "AnyKernel3" ]; then
    git clone --depth=1 -b "$ANYKERNEL_BRANCH" "$ANYKERNEL_REPO" AnyKernel3
fi

AK3_ZIP_NAME="${KERNEL_NAME}-${RELEASE}-${LINUX_VERSION}-${VARIANT}.zip"
sed -i "s/kernel.string=.*/kernel.string=${KERNEL_NAME} ${RELEASE} ${LINUX_VERSION} ${VARIANT}/g" AnyKernel3/anykernel.sh
sed -i "s/supported_kver=.*/supported_kver='5.10'/g" AnyKernel3/anykernel.sh

rm -f AnyKernel3/Image AnyKernel3/Image.gz AnyKernel3/Image-dtb AnyKernel3/dtb AnyKernel3/*.zip
cp "$KERNEL_IMAGE" AnyKernel3/

cd AnyKernel3
zip -r9 "../${AK3_ZIP_NAME}" * -x .git README.md *placeholder
cd ..

# Taruh hasil di artifacts/ + info build untuk diunduh dari GitHub Actions
cp "${AK3_ZIP_NAME}" "$ARTIFACT_DIR/"
ZIP_SHA256=$(sha256sum "$ARTIFACT_DIR/${AK3_ZIP_NAME}" | cut -d' ' -f1)
cat << EOF > "$ARTIFACT_DIR/build-info.txt"
Kernel   : ${KERNEL_NAME} ${RELEASE}
Version  : ${LINUX_VERSION}
Variant  : ${VARIANT}
SuSFS    : ${SUSFS_VERSION}
Compiler : ${COMPILER_STRING}
Source   : ${KERNEL_SOURCE}
Commit   : ${KERNEL_COMMIT} (${k_lastcommit})
File     : ${AK3_ZIP_NAME}
SHA-256  : ${ZIP_SHA256}
EOF

echo "-> Artifact siap: artifacts/${AK3_ZIP_NAME}"
echo "-> All tasks completed successfully!"
