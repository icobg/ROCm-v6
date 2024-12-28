#!/bin/bash

read -p "Require few hours"

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCmSoftwarePlatform/rocFFT/archive/rocm-$PKGVER.tar.gz
tar xf rocFFT-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/rocfft
mkdir -p $ROCM_BUILD_DIR/rocfft
cd $ROCM_BUILD_DIR/rocfft

DEST=$OUTPUT/package-rocfft
PRGNAM=rocFFT
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) - 1) "}
BUILD=1
rm -rf $DEST

pushd .

export HIPCC_COMPILE_FLAGS_APPEND="-parallel-jobs=$(nproc)"
export HIPCC_LINK_FLAGS_APPEND="-parallel-jobs=$(nproc)"

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/hipcc \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none" \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    $ROCM_REL_DIR/rocFFT-$LDIR

cmake --build . $NUMJOBS
DESTDIR=$DEST cmake --install . --strip

#"${NINJA:=ninja}" $NUMJOBS || exit 1
#DESTDIR=$DEST "$NINJA" install || exit 1

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

      |-----handy-ruler------------------------------------------------------|
rocFFT: rocFFT (Next generation FFT implementation for ROCm)
rocFFT:
rocFFT: rocFFT is a software library for computing fast Fourier transforms
rocFFT: (FFTs) written in the HIP programming language. It's part of AMD's
rocFFT: software ecosystem based on ROCm. The rocFFT library can be used with
rocFFT: AMD and NVIDIA GPUs.
rocFFT:
rocFFT:
rocFFT:
rocFFT:
rocFFT:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
