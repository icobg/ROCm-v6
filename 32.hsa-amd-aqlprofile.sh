#!/bin/bash

set -e

PRGNAM=hsa-amd-aqlprofile
BUILD=1
cd $ROCM_REL_DIR
# need HSA profile binary which is closed source
#wget https://repo.radeon.com/rocm/apt/6.2/pool/main/h/hsa-amd-aqlprofile/hsa-amd-aqlprofile_1.0.0.60200.60200-66~24.04_amd64.deb
wget https://repo.radeon.com/rocm/apt/${PKGVER}/pool/main/h/hsa-amd-aqlprofile/hsa-amd-aqlprofile_1.0.0.${ROCM_VERSION}-${ROCM_MAGIC}~24.04_amd64.deb
mkdir tmp && cd tmp
ar x ../hsa-amd-aqlprofile_1.0.0.${ROCM_VERSION}-${ROCM_MAGIC}~24.04_amd64.deb
tar xf data.tar.gz
mkdir tempdir
BASE="${ROCM_REL_DIR}/tmp/tempdir"
DEST="${ROCM_REL_DIR}/tmp/tempdir"
mv opt tempdir
cd tempdir/opt
mv rocm-${PKGVER} rocm
cd $BASE
mkdir -p install
cat >> install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

                  |-----handy-ruler------------------------------------------------------|
hsa-amd-aqlprofile: hsa-amd-aqlprofile (AQLPROFILE library)
hsa-amd-aqlprofile:
hsa-amd-aqlprofile: AQLPROFILE library for AMD HSA runtime API extension support.
hsa-amd-aqlprofile:
hsa-amd-aqlprofile:
hsa-amd-aqlprofile:
hsa-amd-aqlprofile:
hsa-amd-aqlprofile:
hsa-amd-aqlprofile:
hsa-amd-aqlprofile: closed source
hsa-amd-aqlprofile:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz
