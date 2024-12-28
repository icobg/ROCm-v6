#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCmSoftwarePlatform/hipRAND/archive/rocm-$PKGVER.tar.gz
tar xf hipRAND-$LDIR.tar.gz
cd $ROCM_REL_DIR/hipRAND-$LDIR
sed -i 's|/hip/bin|/bin|g' toolchain-linux.cmake

rm -rf $ROCM_BUILD_DIR/hipRAND
mkdir -p $ROCM_BUILD_DIR/hipRAND
cd $ROCM_BUILD_DIR/hipRAND

DEST=$OUTPUT/package-hipRAND
PRGNAM=hipRAND
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_TOOLCHAIN_FILE=toolchain-linux.cmake \
    -D CMAKE_CXX_COMPILER=${ROCM_INSTALL_DIR}/bin/amdclang \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none" \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D BUILD_FORTRAN_WRAPPER=ON \
    $ROCM_REL_DIR/hipRAND-$LDIR

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
hipRAND: hipRAND (rocRAND marshalling library)
hipRAND:
hipRAND: hipRAND is a RAND marshalling library with multiple supported
hipRAND: backends. It sits between your application and the backend RAND
hipRAND: library, where it marshals inputs to the backend and results to the
hipRAND: application. hipRAND exports an interface that doesnt require the
hipRAND: client to change, regardless of the chosen backend.
hipRAND:
hipRAND: hipRAND supports rocRAND and cuRAND.
hipRAND:
hipRAND:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

# cd $ROCM_REL_DIR/hipRAND-$LDIR
# pip3 install .

popd
