#!/bin/bash

printf "Read documentation for starting as a deamon. Require gRPC specific version\n"
printf "Could be downloaded from here: https://www.ixip.net/rocm \n"
read -p "Press any key to continue"

set -e

PRGNAM=rdc

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
    -DGRPC_ROOT=/opt/grpc \
    $ROCM_REL_DIR/$PRGNAM-$LDIR

cmake --build . $NUMJOBS
DESTDIR=$DEST cmake --install .



mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

   |-----handy-ruler------------------------------------------------------|
rdc: rdc (ROCmTM Data Center Tool)
rdc:
rdc: The ROCm™ Data Center Tool simplifies the administration and addresses
rdc: key infrastructure challenges in AMD GPUs in cluster and datacenter
rdc: environments. The main features are:
rdc:
rdc: GPU telemetry
rdc: GPU statistics for jobs
rdc: Integration with third-party tools
rdc: Open source
rdc:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
