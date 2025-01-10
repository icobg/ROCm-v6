#!/bin/bash

set -e

read -p "Repack of Ubuntu package and save 2 days for compilation"

DEST=$OUTPUT/package-composable_kernel
PRGNAM=composable_kernel
BUILD=1

cd $ROCM_REL_DIR
#wget https://repo.radeon.com/rocm/apt/${PKGVER}/pool/main/c/composablekernel-ckprofiler/composablekernel-ckprofiler_1.1.0.$ROCM_VERSION-$ROCM_MAGIC~24.04_amd64.deb
#wget https://repo.radeon.com/rocm/apt/${PKGVER}/pool/main/c/composablekernel-dev/composablekernel-dev_1.1.0.$ROCM_VERSION-$ROCM_MAGIC~24.04_amd64.deb
wget https://repo.radeon.com/rocm/apt/${PKGVER}/pool/main/c/composablekernel-ckprofiler/composablekernel-ckprofiler_1.1.0.$ROCM_VERSION-$ROCM_MAGIC~24.04_amd64.deb
wget https://repo.radeon.com/rocm/apt/${PKGVER}/pool/main/c/composablekernel-dev/composablekernel-dev_1.1.0.$ROCM_VERSION-$ROCM_MAGIC~24.04_amd64.deb

rm -rf $ROCM_BUILD_DIR/composable_kernel
mkdir -p $ROCM_BUILD_DIR/composable_kernel
cd $ROCM_BUILD_DIR/composable_kernel
mkdir tmp && cd tmp
ar x $ROCM_REL_DIR/composablekernel-ckprofiler_1.1.0.$ROCM_VERSION-$ROCM_MAGIC~24.04_amd64.deb
tar xf data.tar.xz
rm *z debian-binary
ar x $ROCM_REL_DIR/composablekernel-dev_1.1.0.$ROCM_VERSION-$ROCM_MAGIC~24.04_amd64.deb
tar xf data.tar.xz
rm *z debian-binary
mv opt/rocm-$PKGVER opt/rocm
mkdir -p install

cat >> install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

                 |-----handy-ruler------------------------------------------------------|
composable_kernel: composable_kernel (High Performance Composable Kernel for AMD GPUs)
composable_kernel:
composable_kernel: The Composable Kernel (CK) library provides a programming model for
composable_kernel: writing performance-critical kernels for machine learning workloads
composable_kernel: across multiple architectures (GPUs, CPUs, etc.). The CK library
composable_kernel: uses general purpose kernel languages, such as HIP C++.
composable_kernel:
composable_kernel:
composable_kernel:
composable_kernel:
composable_kernel:
END

makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz
