#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/rocprofiler-register/archive/rocm-$PKGVER.tar.gz
tar xf rocprofiler-register-$LDIR.tar.gz
# Remove cpack packaging
sed -i '116d' "$ROCM_REL_DIR/rocprofiler-register-$LDIR/CMakeLists.txt"
# find_package() calls on global scope
sed -i 's/add_subdirectory(external)/find_package(fmt REQUIRED)\nfind_package(glog REQUIRED)/' \
    "$ROCM_REL_DIR/rocprofiler-register-$LDIR/CMakeLists.txt"

rm -rf $ROCM_BUILD_DIR/rocprofiler-register
mkdir -p $ROCM_BUILD_DIR/rocprofiler-register

DEST=$OUTPUT/package-rocprofiler-register
PRGNAM=rocprofiler-register
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST
#CHECKOUT=11a4668306e91d347d4343d421f7d524b9d3b0df
pushd .


cd $ROCM_BUILD_DIR/rocprofiler-register
#git clone https://github.com/ROCm/rocprofiler-register.git
#cd rocprofiler-register
#git checkout amd-staging
#git pull --rebase
##git checkout "$CHECKOUT"
#git checkout -b rocm-6.2.x
##git submodule deinit -f --all
##git submodule update --init --recursive
mkdir build
cd build
cmake \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_STATIC_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -D ROCPROFILER_REGISTER_BUILD_GLOG=OFF \
    -D ROCPROFILER_REGISTER_BUILD_FMT=OFF \
    $ROCM_REL_DIR/rocprofiler-register-$LDIR/

cmake --build . --target all --parallel 8
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
rocprofiler-register: rocprofiler-register
rocprofiler-register:
rocprofiler-register: The rocprofiler-register library is a helper library that coordinates
rocprofiler-register: the modification of the intercept API table(s) of the HSA/HIP/ROCTx
rocprofiler-register: runtime libraries by the ROCprofiler (v2) library. The purpose of
rocprofiler-register: this library is to provide a consistent and automated mechanism of
rocprofiler-register: enabling performance analysis in the ROCm runtimes which does not
rocprofiler-register: rely on environment variables or unique methods for each runtime
rocprofiler-register: library.
rocprofiler-register:
rocprofiler-register:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
