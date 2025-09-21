#!/bin/bash

read -p "Taking few hours"

if [[ ! -z "${VIRTUAL_ENV}" ]]; then
    printf "\n Deactivate your Python virtual environment \n"
    read
fi

set -e

PRGNAM=rocBLAS
cd $ROCM_REL_DIR
wget https://github.com/ROCmSoftwarePlatform/$PRGNAM/archive/rocm-$PKGVER.tar.gz
wget https://github.com/ROCmSoftwarePlatform/Tensile/archive/rocm-7.0.0.tar.gz
tar xf $PRGNAM-$LDIR.tar.gz
tar xf Tensile-rocm-7.0.0.tar.gz
cp Tensile-rocm-7.0.0.tar.gz Tensile-$LDIR.tar.gz
mv Tensile-rocm-7.0.0 Tensile-$LDIR

tensile_dir=$(basename Tensile-$LDIR.tar.gz)
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM

DEST=$OUTPUT/package-$PRGNAM

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1

rm -rf $DEST

pushd .

export HIPCC_COMPILE_FLAGS_APPEND="-parallel-jobs=$(nproc)"
export HIPCC_LINK_FLAGS_APPEND="-parallel-jobs=$(nproc)"


cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/amdclang++ \
    -D CMAKE_C_COMPILER=${ROCM_INSTALL_DIR}/llvm/bin/amdclang \
    -D CMAKE_TOOLCHAIN_FILE=toolchain-linux.cmake \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_PREFIX_PATH=${ROCM_INSTALL_DIR}/llvm/lib/cmake/llvm \
    -D amd_comgr_DIR=${ROCM_INSTALL_DIR}/lib/cmake/amd_comgr \
    -D BUILD_WITH_TENSILE=ON \
    -D TENSILE_USE_HIP=ON \
    -D TENSILE_USE_LLVM=ON \
    -D TENSILE_USE_MSGPACK=OFF \
    -D TENSILE_USE_OPENMP=ON \
    -D TENSILE_VENV_UPGRADE_PIP=ON \
    -D Tensile_LIBRARY_FORMAT=yaml \
    -D Tensile_TEST_LOCAL_PATH="$ROCM_REL_DIR/$tensile_dir" \
    -D TENSILE_ROCM_OFFLOAD_BUNDLER_PATH=${ROCM_INSTALL_DIR}/llvm/bin/clang-offload-bundler \
    -D TENSILE_GPU_ARCHS="gfx900;gfx90a;gfx942;gfx1030;gfx1100;gfx1101;gfx1102;gfx1200;gfx1201" \
    -D Tensile_ARCHITECTURE="gfx900;gfx90a;gfx942;gfx1030;gfx1100;gfx1101;gfx1102;gfx1200;gfx1201" \
    -G "Unix Makefiles" \
    $ROCM_REL_DIR/$PRGNAM-$LDIR

#echo "Disable bug into Tensile verifying process"
#patch -Np1 -i $ROCM_REL_DIR/rocblas-6.3-disable-verify.patch

#    -D TENSILE_GPU_ARCHS="gfx803;gfx900;gfx906;gfx908;gfx90a;gfx1010;gfx1011;gfx1012;gfx1030;gfx1031;gfx1032;gfx1034;gfx1035;" \
#    -D Tensile_ARCHITECTURE="gfx900;gfx906:xnack-;gfx908:xnack-;gfx90a;gfx1010;gfx1012;gfx1030;gfx1151;" \


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
rocBLAS: rocBLAS (Next generation BLAS implementation for ROCm platform)
rocBLAS:
rocBLAS: rocBLAS is the ROCm Basic Linear Algebra Subprograms (BLAS) library.
rocBLAS: rocBLAS is implemented in the HIP programming language and optimized
rocBLAS: for AMD GPUs.
rocBLAS:
rocBLAS:
rocBLAS:
rocBLAS:
rocBLAS:
rocBLAS:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
