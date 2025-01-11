#!/bin/bash

set -e
PRGNAM=rocm-opencl-runtime
cd $ROCM_REL_DIR
wget https://github.com/ROCm/clr/archive/rocm-$PKGVER.tar.gz
tar xf clr-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

DEST=$OUTPUT/package-$PRGNAM

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

cmake \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -DCLR_BUILD_OCL=ON \
    $ROCM_REL_DIR/clr-$LDIR

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
rocm-opencl-runtime: rocm-opencl-runtime (OpenCL implementation for AMD)
rocm-opencl-runtime:
rocm-opencl-runtime: AMD Common Language Runtime contains source codes for AMDs compute
rocm-opencl-runtime: languages runtimes: HIP and OpenCL-tm.
rocm-opencl-runtime:
rocm-opencl-runtime:
rocm-opencl-runtime:
rocm-opencl-runtime:
rocm-opencl-runtime:
rocm-opencl-runtime:
rocm-opencl-runtime:
END

cd $DEST
mkdir -p etc/OpenCL/vendors
echo '/opt/rocm/lib/libamdocl64.so' > etc/OpenCL/vendors/amdocl64.icd
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
