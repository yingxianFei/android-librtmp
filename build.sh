#!/bin/sh

# usage
function usage() {
cat << EOF
usage: $0 options

OPTIONS:
   -n [ndk base] 	base path to ndk
EOF
exit 1
}

# checks to ensure an exit code is 0
check_exit() {
	if [[ "$1" != "0" ]];
	then
		echo ""
		echo "********************************"
		echo "* EXITING FOR ERROR CODE: $1"
		echo "********************************"
		echo ""
		exit $1
	fi
}

NDK_BASE=$ANDROID_NDK_HOME
while getopts "p:n:" opt; do
    case $opt in
        n)
            NDK_BASE="$OPTARG"
            ;;
        ?)
            usage
            ;;
    esac
done

# clean first
if [[ -e build ]];
then
	rm -rf build
fi
mkdir build

$NDK_BASE/build/tools/make-standalone-toolchain.sh platform=android-19 --install-dir=$PWD/build/android-toolchain --system=linux-x86_64
export PATH=$PATH:$PWD/build/android-toolchain/bin
#build polarssl
cd polarssl-1.2.14
make CC=arm-linux-androideabi-gcc APPS=
make install DESTDIR=$PWD/../build/android-toolchain/sysroot
#build librtmp
cd ../rtmpdump
##for .so
make clean
make SYS=android CROSS_COMPILE=arm-linux-androideabi- INC="-I$PWD/../build/android-toolchain/sysroot/include" CRYPTO=POLARSSL
cp -RP librtmp/*.so* $PWD/../build/android-toolchain/sysroot/lib
##for .a
make clean
make SYS=android CROSS_COMPILE=arm-linux-androideabi- INC="-I$PWD/../build/android-toolchain/sysroot/include" CRYPTO=POLARSSL SHARED=
cp -RP librtmp/*.a* $PWD/../build/android-toolchain/sysroot/lib
cd ..