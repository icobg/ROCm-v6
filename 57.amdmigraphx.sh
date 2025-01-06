#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/AMDMIGraphX/archive/rocm-$PKGVER.tar.gz
wget https://www.ixip.net/rocm/migraphx-6.3-msgpack.patch
tar xf AMDMIGraphX-$LDIR.tar.gz
cd AMDMIGraphX-$LDIR

patch -Np1 -i $ROCM_REL_DIR/migraphx-6.3-msgpack.patch

rm -rf $ROCM_BUILD_DIR/amdmigraphx
mkdir -p $ROCM_BUILD_DIR/amdmigraphx
cd $ROCM_BUILD_DIR/amdmigraphx

DEST=$OUTPUT/package-amdmigrapx
PRGNAM=AMDMIGraphX
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1

pushd .

LDFLAGS=-lstdc++ cmake \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/amdclang \
    -D CMAKE_C_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/amdclang \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_PREFIX_PATH=${ROCM_INSTALL_DIR}/lib/llvm/lib/cmake \
    -D ROCM_GDB="${ROCM_INSTALL_DIR}/bin/rocdbg" \
    -D HALF_INCLUDE_DIR="${ROCM_INSTALL_DIR}/include" \
    -D MIGRAPHX_ENABLE_GPU=ON \
    -D MIGRAPHX_USE_COMPOSABLEKERNEL=OFF \
    -D BUILD_TESTING=OFF \
    -D MIGRAPHX_ENABLE_MLIR=ON \
    -D MIGRAPHX_ENABLE_CPU=OFF \
    -D AMDGPU_TARGETS="gfx900;gfx906:xnack-;gfx908:xnack-;gfx90a;gfx942;gfx1010;gfx1012;gfx1030;gfx1100;gfx1101;gfx1102;gfx1151;gfx1200;gfx1201" \
    -D GPU_TARGETS="gfx900;gfx906:xnack-;gfx908:xnack-;gfx90a;gfx942;gfx1010;gfx1012;gfx1030;gfx1100;gfx1101;gfx1102;gfx1151;gfx1200;gfx1201" \
    $ROCM_REL_DIR/AMDMIGraphX-$LDIR

sed -i 's|-Wl,-rpath-link|-Wl,-allow-shlib-undefined,-rpath-link|g' src/driver/CMakeFiles/driver.dir/link.txt
sed -i 's|-Wl,-rpath-link|-Wl,-allow-shlib-undefined,-rpath-link|g' src/targets/gpu/driver/CMakeFiles/gpu-driver.dir/link.txt
sed -i 's|-Wl,-rpath-link|-Wl,-allow-shlib-undefined,-rpath-link|g' src/targets/gpu/hiprtc/CMakeFiles/migraphx-hiprtc-driver.dir/link.txt

ulimit -n 4096
make $NUMJOBS
make DESTDIR=$DEST install

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

           |-----handy-ruler------------------------------------------------------|
AMDMIGraphX: AMDMIGraphX (AMD MIGraphX)
AMDMIGraphX:
AMDMIGraphX: AMD MIGraphX is AMDs graph inference engine, which accelerates
AMDMIGraphX: machine learning model inference. To use MIGraphX, you can install
AMDMIGraphX: the binaries or build from source code. Refer to the following
AMDMIGraphX: sections for Ubuntu installation instructions (well provide
AMDMIGraphX: instructions for other Linux distributions in the future).
AMDMIGraphX:
AMDMIGraphX:
AMDMIGraphX:
AMDMIGraphX:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

