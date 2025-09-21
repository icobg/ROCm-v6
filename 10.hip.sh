#!/bin/bash

if [[ -z "${VIRTUAL_ENV}" ]]; then
    printf "\n This module requires enabling the Python virtual environment! \n"
    read
fi

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/HIP/archive/rocm-$PKGVER.tar.gz
wget https://github.com/ROCm/clr/archive/rocm-$PKGVER.tar.gz

tar xf HIP-$LDIR.tar.gz
tar xf clr-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/clr
mkdir -p $ROCM_BUILD_DIR/clr

DEST=$OUTPUT/package-hip
PRGNAM=hip-runtime-amd
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1

rm -rf $DEST

pushd .

ROCclr_DIR=$ROCM_REL_DIR/clr-$LDIR
OPENCL_DIR=$ROCM_REL_DIR/ROCm-OpenCL-Runtime
HIP_DIR=$ROCM_REL_DIR/HIP-$LDIR

cd $ROCM_BUILD_DIR/clr
cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/amdclang++ \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -DNDEBUG" \
    -D CMAKE_C_COMPILER=${ROCM_INSTALL_DIR}/bin/amdclang \
    -D CMAKE_C_FLAGS="${CXXFLAGS} -DNDEBUG" \
    -D HIP_COMMON_DIR="$HIP_DIR" \
    -D PROF_API_HEADER_DIR=${ROCM_INSTALL_DIR}/include/rocprofiler-register \
    -D HIP_CATCH_TEST=0 \
    -D CLR_BUILD_HIP=ON \
    -D CLR_BUILD_OCL=OFF \
    -D ROCCLR_ENABLE_HSA=ON \
    -D ROCCLR_ENABLE_LC=ON \
    -G Ninja \
    $ROCM_REL_DIR/clr-$LDIR

"${NINJA:=ninja}" $NUMJOBS || exit 1
DESTDIR=$DEST "$NINJA" install/strip || exit 1

mkdir -p $DEST/usr/lib64
mkdir -p $DEST/usr/include

ln -s /opt/rocm/lib64/libamdhip64.so $DEST/usr/lib64/libamdhip64.so
ln -s /opt/rocm/lib64/libamdhip64.so.7 $DEST/usr/lib64/libamdhip64.so.7
ln -s /opt/rocm/include/hip $DEST/usr/include/hip

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

               |-----handy-ruler------------------------------------------------------|
hip-runtime-amd: Heterogeneous Interface for Portability ROCm (hip-runtime-amd)
hip-runtime-amd:
hip-runtime-amd: HIP is a C++ Runtime API and Kernel Language that allows developers
hip-runtime-amd: to create portable applications for AMD and NVIDIA GPUs from single
hip-runtime-amd: source code.
hip-runtime-amd:
hip-runtime-amd:
hip-runtime-amd:
hip-runtime-amd:
hip-runtime-amd:
hip-runtime-amd:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
