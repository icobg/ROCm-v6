#!/bin/bash

set -e

printf "Require 2 days for compilation\n"
printf "\nRecommend to be used with sccache"
printf "\nIf you will use sccache make sure the sccache is started with:"
printf "\nsccache --start-server\n\n"
printf "\nand start the script again with:\n"
printf "SCCACHE=yes ./27.composable-kernel.sh\n\n"
printf "\nI'm strongly recomend you to use ubuntu package because this package"
printf "\ndoes not compile every time and take a lot's of time and CK team usual respond"
printf "\non bug 2+ weeks\n"

read -p "Press any key to continue"

cd $ROCM_REL_DIR
wget https://github.com/ROCm/composable_kernel/archive/rocm-$PKGVER.tar.gz
wget https://www.ixip.net/rocm/composable_kernel-fix-dev-build.patch
tar xf composable_kernel-$LDIR.tar.gz
cd composable_kernel-$LDIR
patch -Np2 -i $ROCM_REL_DIR/composable_kernel-fix-dev-build.patch
sed -i '/add_subdirectory(test)/d' "$ROCM_REL_DIR/composable_kernel-$LDIR/CMakeLists.txt"

rm -rf $ROCM_BUILD_DIR/composable_kernel
mkdir -p $ROCM_BUILD_DIR/composable_kernel
cd $ROCM_BUILD_DIR/composable_kernel

DEST=$OUTPUT/package-composable_kernel
PRGNAM=composable_kernel
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) - 2 ) "}
BUILD=1
rm -rf $DEST

pushd .

#export HIPCC_COMPILE_FLAGS_APPEND="-parallel-jobs=$(nproc)"
#export HIPCC_LINK_FLAGS_APPEND="-parallel-jobs=$(nproc)"

# You can enable a lot of optional features by passing
# variables to the script (VAR=yes/no ./27.composable-kernel.sh).
# for example: SCCACHE=yes ./27.composable-kernel.sh
if ! command -v sccache &> /dev/null; then
    scpath=""
else
    scpath=`which sccache`
fi

if [[ "${SCCACHE:-no}" != "no" && -z "$scpath" ]]; then
    printf "\nsccache not found\n"
    exit
fi

sccache="" ; [ "${SCCACHE:-no}" != "no" ] && sccache="-DCMAKE_CXX_COMPILER_LAUNCHER=${scpath} -DCMAKE_C_COMPILER_LAUNCHER=${scpath}"

cmake \
    -Wno-dev \
    $sccache \
    -D CMAKE_HIP_COMPILER_ROCM_LIB=${ROCM_INSTALL_DIR}/lib \
    -D HIP_LANG=${ROCM_INSTALL_DIR}/lib64 \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/hipcc \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_HIP_ARCHITECTURES="gfx900;gfx906:xnack-;gfx908:xnack-;gfx90a;gfx942;gfx1010;gfx1012;gfx1030;gfx1100;gfx1101;gfx1102;gfx1151;gfx1200;gfx1201" \
    -D BUILD_DEV=OFF \
    -D BUILD_TESTING=OFF \
    -D USE_OPT_GFX11=ON \
    $ROCM_REL_DIR/composable_kernel-$LDIR

#    -D CMAKE_TOOLCHAIN_FILE=$ROCM_REL_DIR/composable_kernel-$LDIR/depend/cget/cget.cmake \

#    -D INSTANCES_ONLY=ON \

#    -D DTYPES="fp32;fp16" \

#"${NINJA:=ninja}" $NUMJOBS || exit 1
#DESTDIR=$DEST "$NINJA" install || exit 1

#make -j $NUMJOBS
make -j $NUMJOBS ckProfiler
exit
make $NUMJOBS install DESTDIR=$DEST
#mkdir -p $DEST/bin
#cp bin/ckProfiler $DEST/bin

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
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

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
