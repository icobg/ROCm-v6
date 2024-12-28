#!/bin/bash

export ROCM_INSTALL_DIR=/opt/rocm
export ROCM_MAJOR_VERSION=6
export ROCM_MINOR_VERSION=3
export ROCM_PATCH_VERSION=1
export ROCM_MAGIC=48
export PKGVER=6.3.1
export ROCM_LIBPATCH_VERSION=60301
export ROCM_VERSION=60301
export ROCM_PKGTYPE=TGZ
export ROCM_REL_DIR=/usr/local/src/rocm/release
export ROCM_BUILD_DIR=/usr/local/src/rocm/rocm-build/build
# Uncomment line bellow only if you will build all kernels, for home users autodetected is better
#export AMDGPU_TARGETS="gfx900;gfx906:xnack-;gfx908:xnack-;gfx90a;gfx942;gfx1010;gfx1012;gfx1030;gfx1100;gfx1101;gfx1102;gfx1151;gfx1200;gfx1201"
export PATH=$ROCM_INSTALL_DIR/bin:$ROCM_INSTALL_DIR/llvm/bin:$ROCM_INSTALL_DIR/hip/bin:$CMAKE_DIR/bin:$PATH
export ARCH=${ARCH:-x86_64}
export OUTPUT=${OUTPUT:-/usr/local/src/roc}
export LDIR=${LDIR:-rocm-}${PKGVER}
export TAG=condor
