#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/rocprofiler/archive/rocm-$PKGVER.tar.gz
tar xf rocprofiler-$LDIR.tar.gz
rm -rf $ROCM_BUILD_DIR/rocprofiler
mkdir -p $ROCM_BUILD_DIR/rocprofiler
cd $ROCM_BUILD_DIR/rocprofiler

DEST=$OUTPUT/package-rocprofiler
PRGNAM=rocprofiler
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1
rm -rf $DEST

pushd .

# need HSA profile binary which is closed source
# https://repo.radeon.com/rocm/apt/6.1/pool/main/h/hsa-amd-aqlprofile/hsa-amd-aqlprofile_1.0.0.60100.60100-82~22.04_amd64.deb
# https://repo.radeon.com/rocm/apt/6.2/pool/main/h/hsa-amd-aqlprofile/hsa-amd-aqlprofile_1.0.0.60200.60200-66~24.04_amd64.deb

# Unable to compile release with Perfetto module, need git version

HIP_CLANG_PATH=${ROCM_INSTALL_DIR}/llvm/bin \
cmake \
    -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=${ROCM_INSTALL_DIR} \
    -D ROCPROFILER_BUILD_TESTS=OFF \
    -D ROCPROFILER_BUILD_PLUGIN_PERFETTO=OFF \
    -D CMAKE_CXX_FLAGS="${CXXFLAGS} -fcf-protection=none -fPIC" \
    -D PROF_API_HEADER_PATH=$ROCM_REL_DIR/roctracer-$LDIR/inc/ext \
    $ROCM_REL_DIR/rocprofiler-$LDIR

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
rocprofiler: rocprofiler (Profiling with perf-counters and derived metrics.)
rocprofiler:
rocprofiler: ROCProfiler is AMD’s tooling infrastructure that provides a hardware
rocprofiler: specific low level performance analysis interface for the profiling
rocprofiler: and the tracing of GPU compute applications.
rocprofiler:
rocprofiler:
rocprofiler:
rocprofiler:
rocprofiler:
rocprofiler:
END

cd $DEST
makepkg -l y -c n $OUTPUT/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd

