#!/bin/bash

set -e

rm -rf $ROCM_BUILD_DIR/rocm-hipcc
mkdir -p $ROCM_BUILD_DIR/rocm-hipcc
cd $ROCM_BUILD_DIR/rocm-hipcc

LLVMNAM=llvm-project
DEST=$OUTPUT/package-hipcc
PRGNAM=rocm-hipcc
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1

rm -rf $DEST

echo "Building hipcc"
mkdir -p $ROCM_BUILD_DIR/rocm-hipcc
cd $ROCM_BUILD_DIR/rocm-hipcc
cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=$ROCM_INSTALL_DIR \
    -D CPACK_PACKAGING_INSTALL_PREFIX=$ROCM_INSTALL_DIR \
    -D FILE_REORG_BACKWARD_COMPATIBIL=ON \
    -D BUILD_TESTING=OFF \
    -D CMAKE_PREFIX_PATH="$ROCM_BUILD_DIR/rocm-device-libs;$ROCM_BUILD_DIR/rocm-comgr" \
    $ROCM_REL_DIR/$LLVMNAM-$LDIR/amd/hipcc

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
hipcc: HIP compiler driver (hipcc)
hipcc:
hipcc: hipcc is a compiler driver utility that will call clang or nvcc, depending on
hipcc: target, and pass the appropriate include and library options for the target
hipcc: compiler and HIP infrastructure.
hipcc:
hipcc: hipcc will pass-through options to the target compiler. The tools calling hipcc
hipcc: must ensure the compiler options are appropriate for the target compiler.
hipcc:
hipcc:
hipcc:

END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz
