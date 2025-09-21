#!/bin/bash

set -e
PRGNAM=hsa-rocr
cd $ROCM_REL_DIR
wget https://github.com/ROCm/ROCR-Runtime/archive/rocm-$PKGVER.tar.gz
tar xf ROCR-Runtime-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM
DEST=$OUTPUT/package-$PRGNAM

NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

BASE_CLANG_DIR=$ROCM_INSTALL_DIR/llvm/lib/clang
export NEWEST_CLANG_VER=$(ls -1 $BASE_CLANG_DIR | sort -V | tail -n 1)

pushd .

cmake \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D CMAKE_PREFIX_PATH=${ROCM_INSTALL_DIR} \
    -D CMAKE_CXX_FLAGS="$CXXFLAGS -DNDEBUG" \
    -D BUILD_SHARED_LIBS=ON \
    -D LLVM_DIR=$ROCM_INSTALL_DIR/llvm/bin \
    -D OPENCL_INC_DIR=$BASE_CLANG_DIR/$NEWEST_CLANG_VER/include \
    $ROCM_REL_DIR/ROCR-Runtime-$LDIR

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
hsa-rocr: hsa-rocr (HSA Runtime API and runtime for ROCm)
hsa-rocr:
hsa-rocr: API interfaces and libraries necessary for host applications to
hsa-rocr: launch compute kernels to available HSA ROCm kernel agents. Reference
hsa-rocr: source code for the core runtime is also available.
hsa-rocr:
hsa-rocr:
hsa-rocr:
hsa-rocr:
hsa-rocr:
hsa-rocr:
END


mkdir -p $DEST/usr/lib64
ln -s /opt/rocm/lib64/libhsa-runtime64.so $DEST/usr/lib64/libhsa-runtime64.so
ln -s /opt/rocm/lib64/libhsa-runtime64.so.1 $DEST/usr/lib64/libhsa-runtime64.so.1
ln -s /opt/rocm/lib64/libhsa-runtime64.so.1.18.0 $DEST/usr/lib64/libhsa-runtime64.so.1.18.0

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
