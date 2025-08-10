#!/bin/sh

printf "AMD GPUPRO library \n"
printf "Also few libraries will be needed, this is the whole set - closed source \n"
printf "\n\n"
printf "The X is working but for some reason Wayland not work and I can't figure it out why \n"
printf "just start it when is needed with LD_LIBRARY_PATH=\"/opt/amdgpu/lib64/:${LD_LIBRARY_PATH}\" program\n"
printf ""
printf "\n\n"
read -p "press enter key to continue"

set -e

pushd .

PRGNAM=amdgpu-pro
PKGVER=25.10
ARCH=x86_64
BUILD=1
TAG=condor

major=25.10
major_short=25.10
minor=2194696
ubuntu_ver=24.04
repo_folder_ver=6.4.3
amf_ver=1.4.37
tmp=/tmp/condor/amdgpu
src=/tmp/gpu

rm -rf $tmp
mkdir -p $tmp
mkdir -p $src

cd $src

extract_deb() {
    local tmpdir="$(basename "${1%.deb}")"
    rm -Rf "$tmpdir"
    mkdir "$tmpdir"
    cd "$tmpdir"
    ar x "../$1"
    tar -C "${tmp}" -xf data.tar.xz
    rm *z debian-binary
    cd ..
    rm -Rf "$tmpdir"
}

wget https://repo.radeon.com/amdgpu/${repo_folder_ver}/ubuntu/pool/proprietary/a/amf-amdgpu-pro/amf-amdgpu-pro_${amf_ver}-${minor}.${ubuntu_ver}_amd64.deb
wget https://repo.radeon.com/amdgpu/${repo_folder_ver}/ubuntu/pool/proprietary/liba/libamdenc-amdgpu-pro/libamdenc-amdgpu-pro_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
wget https://repo.radeon.com/amdgpu/${repo_folder_ver}/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libegl1-amdgpu-pro-oglp_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
wget https://repo.radeon.com/amdgpu/${repo_folder_ver}/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-dri_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
wget https://repo.radeon.com/amdgpu/${repo_folder_ver}/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-ext_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
wget https://repo.radeon.com/amdgpu/${repo_folder_ver}/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-gbm_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
wget https://repo.radeon.com/amdgpu/${repo_folder_ver}/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgl1-amdgpu-pro-oglp-glx_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
wget https://repo.radeon.com/amdgpu/${repo_folder_ver}/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles1-amdgpu-pro-oglp_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
wget https://repo.radeon.com/amdgpu/${repo_folder_ver}/ubuntu/pool/proprietary/o/oglp-amdgpu-pro/libgles2-amdgpu-pro-oglp_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
wget https://repo.radeon.com/amdgpu/${repo_folder_ver}/ubuntu/pool/proprietary/v/vulkan-amdgpu-pro/vulkan-amdgpu-pro_${major_short}-${minor}.${ubuntu_ver}_amd64.deb

files="
amf-amdgpu-pro_${amf_ver}-${minor}.${ubuntu_ver}_amd64.deb
libamdenc-amdgpu-pro_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
libegl1-amdgpu-pro-oglp_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
libgl1-amdgpu-pro-oglp-dri_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
libgl1-amdgpu-pro-oglp-ext_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
libgl1-amdgpu-pro-oglp-gbm_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
libgl1-amdgpu-pro-oglp-glx_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
libgles1-amdgpu-pro-oglp_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
libgles2-amdgpu-pro-oglp_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
vulkan-amdgpu-pro_${major_short}-${minor}.${ubuntu_ver}_amd64.deb
"

for onefile in $files
do
   extract_deb $onefile
done


move_to_dir() {
    cd $tmp/usr
    mkdir -p $tmp/opt/amdgpu/lib64
    rm -rf $tmp/usr/share
    chmod +x $tmp/opt/amdgpu/lib/x86_64-linux-gnu/dri/amdgpu_dri.so
    mv $tmp/opt/amdgpu/lib/x86_64-linux-gnu/dri/amdgpu_dri.so $tmp/opt/amdgpu/lib64

    chmod +x $tmp/opt/amdgpu/lib/x86_64-linux-gnu/gbm/amdgpu_gbm.so
    mv $tmp/opt/amdgpu/lib/x86_64-linux-gnu/gbm/amdgpu_gbm.so $tmp/opt/amdgpu/lib64
    rm -rf $tmp/opt/amdgpu/lib
    rm -rf $tmp/usr/lib

    cd $tmp/opt/amdgpu-pro/lib/x86_64-linux-gnu
    chmod +x *.so
    mv * $tmp/opt/amdgpu/lib64
    rm -rf $tmp/opt/amdgpu-pro/lib/x86_64-linux-gnu

    cd $tmp/opt/amdgpu-pro/lib
    chmod +x xorg/modules/extensions/libglx.so
    mv xorg $tmp/opt/amdgpu/lib64
    rm -rf $tmp/opt/amdgpu-pro/lib/xorg

    mkdir -p $tmp/opt/amdgpu/etc/vulkan/icd.d
    cd $tmp/opt/amdgpu-pro
    cp -r etc $tmp/opt/amdgpu
    rm -rf $tmp/etc
    cd $tmp/opt/amdgpu/etc/vulkan/icd.d
    mv amd_icd64.json amd_pro_icd64.json
    sed -i "s#/opt/amdgpu-pro/lib/x86_64-linux-gnu/amdvlk64.so#/opt/amdgpu/lib64/amdvlk64.so#" $tmp/opt/amdgpu/etc/vulkan/icd.d/amd_pro_icd64.json
    rm -rf $tmp/opt/amdgpu-pro
    rm -rf $tmp/usr
}

move_to_dir

mkdir -p $tmp/install
cat >> $tmp/install/slack-desc << 'END'
# HOW TO EDIT THIS FILE:
# The "handy ruler" below makes it easier to edit a package description.
# Line up the first '|' above the ':' following the base package name, and
# the '|' on the right side marks the last column you can put a character in.
# You must make exactly 11 lines for the formatting to be correct.  It's also
# customary to leave one space after the ':' except on otherwise blank lines.

          |-----handy-ruler------------------------------------------------------|
amdgpu-pro: amdgpu-pro (AMDGPU Pro Advanced Multimedia Framework)
amdgpu-pro:
amdgpu-pro: amdgpu contain AMDGPU Pro libraries
amdgpu-pro:
amdgpu-pro: Do not replace the system libraries, the X works but Wayland does not.
amdgpu-pro:
amdgpu-pro:
amdgpu-pro:
amdgpu-pro:
amdgpu-pro: This is the BINARY VERSION
amdgpu-pro:
END

cd $tmp

makepkg -l y -c n $src/$PRGNAM-$PKGVER-$ARCH-${BUILD}$TAG.txz

popd
