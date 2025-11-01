#!/bin/bash

set -e

cd $ROCM_REL_DIR
wget https://github.com/ROCm/llvm-project/archive/rocm-$PKGVER.tar.gz
wget https://www.ixip.net/rocm/130334.diff
wget https://www.ixip.net/rocm/platform_limits_posix.patch
tar xf llvm-project-rocm-$PKGVER.tar.gz
cd llvm-project-rocm-$PKGVER

patch -Np1 -i $ROCM_REL_DIR/130334.diff
patch -Np1 -i $ROCM_REL_DIR/platform_limits_posix.patch

rm -rf $ROCM_BUILD_DIR/llvm-amdgpu
mkdir -p $ROCM_BUILD_DIR/llvm-amdgpu
cd $ROCM_BUILD_DIR/llvm-amdgpu
DEST=$OUTPUT/package-rocm-llvm
PRGNAM=llvm-project
NUMJOBS=${NUMJOBS:-" -j$(expr $(nproc) + 1) "}
BUILD=1

rm -rf $DEST

pushd .
cmake \
    -DCLANG_ENABLE_AMDCLANG=ON \
    -DCLANG_DEFAULT_LINKER=lld \
    -DCLANG_DEFAULT_RTLIB=compiler-rt \
    -DCLANG_DEFAULT_UNWINDLIB=libgcc \
    -DCLANG_INCLUDE_TESTS=OFF \
    -DCLANG_LINK_FLANG_LEGACY=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX='/opt/rocm/lib/llvm' \
    -DCMAKE_CXX_STANDARD=17 \
    -DFFI_INCLUDE_DIR='/usr/include' \
    -DFFI_LIBRARY_DIR='/usr/lib64' \
    -DGPU_TARGETS='gfx803,gfx900,gfx906,gfx908,gfx90a,gfx942,gfx950,gfx1010,gfx1011,gfx1012,gfx1030,gfx1031,gfx1032,gfx1034,gfx1035,gfx1100,gfx1101,gfx1102,gfx1103,gfx1150,gfx1151,gfx1200,gfx1201' \
    -DLLVM_ENABLE_PROJECTS='llvm;clang;lld;clang-tools-extra;mlir;flang' \
    -DLLVM_ENABLE_RUNTIMES='compiler-rt;libcxx;libcxxabi;libunwind' \
    -DLLVM_TARGETS_TO_BUILD='AMDGPU;NVPTX;X86' \
    -DLLVM_INSTALL_UTILS=ON \
    -DLLVM_LINK_LLVM_DYLIB=OFF \
    -DLLVM_BUILD_LLVM_DYLIB=OFF \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_ENABLE_OCAMLDOC=OFF \
    -DLLVM_INCLUDE_BENCHMARKS=OFF \
    -DLLVM_BUILD_TESTS=OFF \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_BUILD_DOCS=OFF \
    -DLLVM_ENABLE_SPHINX=OFF \
    -DLLVM_ENABLE_ASSERTIONS=OFF \
    -DLLVM_ENABLE_Z3_SOLVER=OFF \
    -DLLVM_BINUTILS_INCDIR=/usr/include \
    -DLLVM_ENABLE_ZLIB=ON \
    -DLIBCXX_ENABLE_STATIC=ON \
    -DLIBCXXABI_ENABLE_STATIC=ON \
    -DMLIR_ENABLE_VULKAN_RUNNER=ON \
    -DMLIR_ENABLE_ROCM_RUNNER=ON \
    -DSANITIZER_AMDGPU=OFF \
    -DPACKAGE_VENDOR=AMD \
    $ROCM_REL_DIR/$PRGNAM-$LDIR/llvm

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
rocm-llvm: rocm-llvm (Radeon Open Compute - LLVM toolchain (llvm, clang, lld))
rocm-llvm:
rocm-llvm: AMD Fork of The LLVM Compiler Infrastructure
rocm-llvm:
rocm-llvm: The AMD fork aims to contain all of upstream LLVM, and also includes
rocm-llvm: several AMD-specific additions in the llvm-project/amd directory:
rocm-llvm:
rocm-llvm: amd/comgr
rocm-llvm: amd/device-libs
rocm-llvm: amd/hip
rocm-llvm:
END

cd $DEST
mkdir -p opt/rocm/lib/llvm/lib/bfd-plugins
ln -s /opt/rocm/lib/llvm/lib/LLVMgold.so $DEST/opt/rocm/lib/llvm/lib/bfd-plugins/LLVMgold.so
ln -s /opt/rocm/lib/llvm $DEST/opt/rocm/llvm
( mkdir -p $DEST/opt/rocm/bin && cd $DEST/opt/rocm/bin && ln -sf ../lib/llvm/bin/amdclang++ . && ln -sf ../lib/llvm/bin/amdclang .)
# Fix rpath to avoid error when running amdclang and friends
# (error while loading shared libraries: libunwind.so.1: cannot open shared object file: No such file or directory)
patchelf --set-rpath '$ORIGIN' "$DEST/opt/rocm/lib/llvm/lib/libc++abi.so"

makepkg -l y -c n $OUTPUT/rocm-$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
