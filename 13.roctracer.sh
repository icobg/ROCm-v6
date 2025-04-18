#!/bin/bash

if [[ -z "${VIRTUAL_ENV}" ]]; then
    printf "\n This module requires enabling the Python virtual environment \n"
    read
fi

set -e
PRGNAM=roctracer
cd $ROCM_REL_DIR
wget https://github.com/ROCm/$PRGNAM/archive/rocm-$PKGVER.tar.gz
tar xf $PRGNAM-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

DEST=$OUTPUT/package-$PRGNAM

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

PACKAGE_ROOT=$ROCM_INSTALL_DIR/$PRGNAM
PACKAGE_PREFIX=$ROCM_INSTALL_DIR/$PRGNAM
LD_RUNPATH_FLAG="-Wl,--enable-new-dtags -Wl,--rpath,$ROCM_INSTALL_DIR/lib:$ROCM_INSTALL_DIR/lib64 -fPIC"
HIP_API_STRING=1
export HIP_PATH=$ROCM_INSTALL_DIR
export HSA_RUNTIME_INC=$ROCM_INSTALL_DIR/include/hsa/hsa.h

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D HIP_ROOT_DIR=${ROCM_INSTALL_DIR} \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none -fPIC" \
    -D CMAKE_C_FLAGS="${C_FLAGS} -fPIC" \
    -D CMAKE_SHARED_LINKER_FLAGS="$LD_RUNPATH_FLAG" \
    $ROCM_REL_DIR/$PRGNAM-$LDIR

cmake --build . $NUMJOBS || exit 1
DESTDIR=$DEST cmake --install . --strip || exit 1

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

         |-----handy-ruler------------------------------------------------------|
roctracer: roctracer (ROCm tracer library for performance tracing)
roctracer:
roctracer: ROC-tracer library: Runtimes Generic Callback/Activity APIs
roctracer: The goal of the implementation is to provide a generic independent
roctracer: from specific runtime profiler to trace API and asynchronous activity.
roctracer:
roctracer: ROC-TX library: Code Annotation Events API
roctracer: Includes API for:
roctracer: - roctxMark
roctracer: - roctxRangePush
roctracer: - roctxRangePop
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
