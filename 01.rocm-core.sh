#!/bin/bash

set -e
PRGNAM=rocm-core
cd $ROCM_REL_DIR
wget https://github.com/ROCm/$PRGNAM/archive/rocm-$PKGVER.tar.gz
tar xf $PRGNAM-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/$PRGNAM
mkdir -p $ROCM_BUILD_DIR/$PRGNAM
cd $ROCM_BUILD_DIR/$PRGNAM
DEST=$OUTPUT/package-$PRGNAM

BUILD=1
rm -rf $DEST

pushd .

cmake \
  -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
  -D PROJECT_VERSION_MAJOR=${ROCM_MAJOR_VERSION} \
  -D PROJECT_VERSION_MINOR=${ROCM_MINOR_VERSION} \
  -D PROJECT_VERSION_PATCH=${ROCM_PATCH_VERSION} \
  -D ROCM_PATCH_VERSION=${ROCM_LIBPATCH_VERSION} \
  -D ROCM_VERSION=${PKGVER} \
  -D BUILD_ID=${BUILD} \
  $ROCM_REL_DIR/$PRGNAM-$LDIR

make -j $(nproc)
make install DESTDIR=$DEST

mkdir -p $DEST/install
cat >> $DEST/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

         |-----handy-ruler------------------------------------------------------|
rocm-core: rocm-core (ROCm Core)
rocm-core:
rocm-core: rocm-core is a utility which can be used to get ROCm release version.
rocm-core:
rocm-core:
rocm-core:
rocm-core:
rocm-core:
rocm-core:
rocm-core:
rocm-core:
END

cd $DEST
# This line will save you a lot of headaches
ln -s opt/rocm/lib opt/rocm/lib64
# Create the correct version
echo "${ROCM_MAJOR_VERSION}.${ROCM_MINOR_VERSION}.${ROCM_PATCH_VERSION}" > opt/rocm/.version
echo "#define ROCM_BUILD_INFO \"$ROCM_MAJOR_VERSION.$ROCM_MINOR_VERSION.$ROCM_PATCH_VERSION.0-$ROCM_MAGIC\"" >> opt/rocm/include/rocm_version.h
echo "#define ROCM_BUILD_INFO \"$ROCM_MAJOR_VERSION.$ROCM_MINOR_VERSION.$ROCM_PATCH_VERSION.0-$ROCM_MAGIC\"" >> opt/rocm/include/rocm-core/rocm_version.h
mkdir -p etc/ld.so.conf.d
echo '/opt/rocm/lib' > etc/ld.so.conf.d/rocm.conf
mkdir -p etc/profile.d
cat >> etc/profile.d/rocm.sh << 'END'
PATH="$PATH:/opt/rocm/bin"
export PATH
END

makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
