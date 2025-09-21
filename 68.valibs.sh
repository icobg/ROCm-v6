#!/bin/bash

read -p "We will repack Ubuntu packages because for the moment. I'm unable to find the source codes"

set -e

PRGNAM=libva-amdgpu-dev
BUILD=1
DIRVER=6.4.2.1
ROCM_V=6.4
AMDBUILD=2187269
ROCM_VERSION=60402

BASE="${ROCM_REL_DIR}/temp/tempdir"
DEST="${ROCM_REL_DIR}/temp/tempdir"

function extractPacks()
{
    ar x ../$1
    tar xf data.tar.xz
}


cd $ROCM_REL_DIR
# need the library for rocDecode and rocJPEG

wget https://repo.radeon.com/amdgpu/${DIRVER}/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau1-amdgpu_${ROCM_V}-${AMDBUILD}.24.04_amd64.deb
wget https://repo.radeon.com/amdgpu/${DIRVER}/ubuntu/pool/main/libv/libvdpau-amdgpu/libvdpau-amdgpu-dev_${ROCM_V}-${AMDBUILD}.24.04_amd64.deb
wget https://repo.radeon.com/amdgpu/${DIRVER}/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-dev_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
wget https://repo.radeon.com/amdgpu/${DIRVER}/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-drm2_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
wget https://repo.radeon.com/amdgpu/${DIRVER}/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-glx2_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
wget https://repo.radeon.com/amdgpu/${DIRVER}/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-wayland2_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
wget https://repo.radeon.com/amdgpu/${DIRVER}/ubuntu/pool/main/libv/libva-amdgpu/libva-amdgpu-x11-2_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
wget https://repo.radeon.com/amdgpu/${DIRVER}/ubuntu/pool/main/libv/libva-amdgpu/libva2-amdgpu_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
wget https://repo.radeon.com/amdgpu/${DIRVER}/ubuntu/pool/main/libv/libva-amdgpu/va-amdgpu-driver-all_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb

mkdir temp && cd temp

extractPacks libvdpau1-amdgpu_${ROCM_V}-${AMDBUILD}.24.04_amd64.deb
extractPacks libvdpau-amdgpu-dev_${ROCM_V}-${AMDBUILD}.24.04_amd64.deb
extractPacks libva-amdgpu-dev_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
extractPacks libva-amdgpu-drm2_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
extractPacks libva-amdgpu-glx2_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
extractPacks libva-amdgpu-wayland2_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
extractPacks libva-amdgpu-x11-2_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
extractPacks libva2-amdgpu_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb
extractPacks va-amdgpu-driver-all_2.16.0.${ROCM_VERSION}-${AMDBUILD}.24.04_amd64.deb

mkdir tempdir

mv opt tempdir

cd $BASE
mkdir -p install
cat >> install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

                |-----handy-ruler------------------------------------------------------|
libva-amdgpu-dev: libva-amdgpu-dev (VA AMD GPU)
libva-amdgpu-dev:
libva-amdgpu-dev: Varios packages from AMD
libva-amdgpu-dev:
libva-amdgpu-dev:
libva-amdgpu-dev:
libva-amdgpu-dev:
libva-amdgpu-dev:
libva-amdgpu-dev:
libva-amdgpu-dev: closed source
libva-amdgpu-dev:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

cd $ROCM_REL_DIR
rm -rf temp

popd
