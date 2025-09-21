#!/bin/bash

set -e
PRGNAM=ROCmValidationSuite
cd $ROCM_REL_DIR
wget https://github.com/ROCm/$PRGNAM/archive/rocm-$PKGVER.tar.gz
tar xf $PRGNAM-$LDIR.tar.gz

rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

DEST=$OUTPUT/package-$PRGNAM

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1

pushd .

cmake \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/amdclang++ \
    -D CMAKE_C_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/amdclang \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D AMDGPU_TARGETS="gfx900;gfx906:xnack-;gfx908:xnack-;gfx90a;gfx942;gfx950;gfx1010;gfx1012;gfx1030;gfx1100;gfx1101;gfx1102;gfx1151;gfx1200;gfx1201" \
    -D GPU_TARGETS="gfx900;gfx906:xnack-;gfx908:xnack-;gfx90a;gfx942;gfx950;gfx1010;gfx1012;gfx1030;gfx1100;gfx1101;gfx1102;gfx1151;gfx1200;gfx1201" \
    -D RVS_BUILD_TESTS=OFF \
    -D RVS_ROCBLAS=0 \
    -D RVS_ROCMSMI=0 \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -D OpenMP_C_FLAGS="-fopenmp -Wno-unused-command-line-argument" \
    -D OpenMP_C_LIB_NAMES="libomp;libgomp;libiomp5" \
    -D OpenMP_CXX_FLAGS="-fopenmp -Wno-unused-command-line-argument" \
    -D OpenMP_CXX_LIB_NAMES="libomp;libgomp;libiomp5" \
    -D OpenMP_libomp_LIBRARY="/opt/rocm/lib/libomp.so" \
    -D OpenMP_libgomp_LIBRARY="/opt/rocm/lib/libgomp.so" \
    -D OpenMP_libiomp5_LIBRARY="/opt/rocm/lib/libiomp5.so" \
    $ROCM_REL_DIR/$PRGNAM-$LDIR

cmake --build . $NUMJOBS
DESTDIR=$DEST cmake --install . --strip

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

                   |-----handy-ruler------------------------------------------------------|
rocmvalidationsuite: ROCmValidationSuite
rocmvalidationsuite:
rocmvalidationsuite: The ROCm Validation Suite (RVS) is a system validation and diagnostics
rocmvalidationsuite: tool for monitoring, stress testing, detecting and troubleshooting
rocmvalidationsuite: issues that affects the functionality and performance of AMD GPU(s)
rocmvalidationsuite: operating in a high-performance/AI/ML computing environment. RVS is
rocmvalidationsuite: enabled using the ROCm software stack on a compatible software and
rocmvalidationsuite: hardware platform.
rocmvalidationsuite:
rocmvalidationsuite:
rocmvalidationsuite:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
