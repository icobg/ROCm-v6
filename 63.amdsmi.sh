#!/bin/bash
# How it's work here -> https://rocm.blogs.amd.com/software-tools-optimization/amd-smi-overview/README.html
set -e

PRGNAM=amdsmi

cd $ROCM_REL_DIR
wget https://github.com/ROCm/$PRGNAM/archive/rocm-$PKGVER.tar.gz
tar xf $PRGNAM-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

pushd .

DEST=$OUTPUT/package-$PRGNAM
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_CXX_COMPILER=/opt/rocm/bin/amdclang++ \
    -D BUILD_TESTS=OFF \
    $ROCM_REL_DIR/$PRGNAM-$LDIR

cmake --build . $NUMJOBS
DESTDIR=$DEST cmake --install .

patchelf --set-rpath '$ORIGIN' src/amd_smi_ex
cp src/amd_smi_ex $DEST/opt/rocm/bin
patchelf --set-rpath '$ORIGIN' rocm_smi/rocm_smi_ex
cp rocm_smi/rocm_smi_ex $DEST/opt/rocm/bin
patchelf --set-rpath '$ORIGIN' example/amd_*
cp example/amd* $DEST/opt/rocm/bin

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

      |-----handy-ruler------------------------------------------------------|
amdsmi: amdsmi (AMD System Management Interface library)
amdsmi:
amdsmi: The AMD System Management Interface (AMD SMI) library offers a unified
amdsmi: tool for managing and monitoring GPUs, particularly in
amdsmi: high-performance computing environments. It provides a user-space
amdsmi: interface that allows applications to control GPU operations, 
amdsmi: monitor performance, and retrieve information about the systems
amdsmi: drivers and GPUs.
amdsmi:
amdsmi: 
amdsmi:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
