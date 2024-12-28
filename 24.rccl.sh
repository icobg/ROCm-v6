#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCmSoftwarePlatform/rccl/archive/rocm-$PKGVER.tar.gz
tar xf rccl-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/rccl
mkdir -p $ROCM_BUILD_DIR/rccl
cd $ROCM_BUILD_DIR/rccl

DEST=$OUTPUT/package-rccl
PRGNAM=rccl
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .


export HIPCC_COMPILE_FLAGS_APPEND="-parallel-jobs=$(nproc)"
export HIPCC_LINK_FLAGS_APPEND="-parallel-jobs=$(nproc)"

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/hipcc \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none" \
    -D BUILD_TESTS=OFF \
    -D HIP_CLANG_INCLUDE_PATH=${ROCM_INSTALL_DIR}/llvm/include \
    -D ENABLE_MSCCLPP=OFF \
    -D ENABLE_MSCCL_KERNEL=ON \
    $ROCM_REL_DIR/rccl-$LDIR

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
rccl: rccl (ROCm Communication Collectives Library)
rccl:
rccl: RCCL (pronounced 'Rickle') is a stand-alone library of standard
rccl: collective communication routines for GPUs, implementing all-reduce,
rccl: all-gather, reduce, broadcast, reduce-scatter, gather, scatter, and
rccl: all-to-all. There is also initial support for direct GPU-to-GPU send
rccl: and receive operations.
rccl:
rccl:
rccl:
rccl:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
