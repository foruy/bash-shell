#!/bin/bash

#
###########################################################################
#
# Don't change anything here
WORKING_DIR="$PWD";

ARCHS="x86 x86_64 armeabi armeabi-v7a arm64-v8a";
NDK_ROOT=$NDK_ROOT;
MBEDTLS_DIR="$PWD";
ANDROID_NATIVE_API_LEVEL=16 ;
ANDROID_TOOLCHAIN=clang ;
ANDROID_STL= ; #

# ======================= options ======================= 
while getopts "a:c:n:hl:r:t:-" OPTION; do
    case $OPTION in
        a)
            ARCHS="$OPTARG";
        ;;
        c)
            ANDROID_STL="$OPTARG";
        ;;
        n)
            NDK_ROOT="$OPTARG";
        ;;
        h)
            echo "usage: $0 [options] -n NDK_ROOT -r SOURCE_DIR [-- [cmake options]]";
            echo "options:";
            echo "-a [archs]                    which arch need to built, multiple values must be split by space(default: $ARCHS)";
            echo "-c [android stl]              stl used by ndk(default: $ANDROID_STL, available: system, stlport_static, stlport_shared, gnustl_static, gnustl_shared, c++_static, c++_shared, none)";
            echo "-n [ndk root directory]       ndk root directory.(default: $DEVELOPER_ROOT)";
            echo "-l [api level]                API level, see $NDK_ROOT/platforms for detail.(default: $ANDROID_NATIVE_API_LEVEL)";
            echo "-r [source dir]               root directory of this library";
            echo "-t [toolchain]                ANDROID_TOOLCHAIN.(gcc/clang, default: $ANDROID_TOOLCHAIN)";
            echo "-h                            help message.";
            exit 0;
        ;;
        r)
            MBEDTLS_DIR="$OPTARG";
        ;;
        t)
            ANDROID_TOOLCHAIN="$OPTARG";
        ;;
        l)
            ANDROID_NATIVE_API_LEVEL=$OPTARG;
        ;;
        -) 
            break;
            break;
        ;;
        ?)  #当有不认识的选项的时候arg为?
            echo "unkonw argument detected";
            exit 1;
        ;;
    esac
done

shift $(($OPTIND-1));

echo "Ready to build for ios";
echo "WORKING_DIR=${WORKING_DIR}";
echo "ARCHS=${ARCHS}";
echo "ANDROID_STL=${ANDROID_STL}";
echo "NDK_ROOT=${NDK_ROOT}";
echo "ANDROID_TOOLCHAIN=${ANDROID_TOOLCHAIN}";
echo "ANDROID_NATIVE_API_LEVEL=${ANDROID_NATIVE_API_LEVEL}";
echo "cmake options=$@";
echo "SOURCE=$SRC_DIR";


##########
if [ ! -e "$MBEDTLS_DIR/CMakeLists.txt" ]; then
    echo "$MBEDTLS_DIR/CMakeLists.txt not found";
    exit -2;
fi
MBEDTLS_DIR="$(cd "$MBEDTLS_DIR" && pwd)";

mkdir -p "$WORKING_DIR/lib";

for ARCH in ${ARCHS}; do
    echo "================== Compling $ARCH ==================";
    echo "Building mbedtls for android-$ANDROID_NATIVE_API_LEVEL ${ARCH}"
    
    # sed -i.bak '4d' Makefile;
    echo "Please stand by..."
    if [ -e "$WORKING_DIR/build/$ARCH" ]; then
        rm -rf "$WORKING_DIR/build/$ARCH";
    fi
    mkdir -p "$WORKING_DIR/build/$ARCH";
    cd "$WORKING_DIR/build/$ARCH";
    
    mkdir -p "$WORKING_DIR/lib/$ARCH";

    cmake "$MBEDTLS_DIR" -DCMAKE_LIBRARY_OUTPUT_DIRECTORY="$WORKING_DIR/lib/$ARCH" -DCMAKE_INSTALL_PREFIX="$WORKING_DIR/$ARCH" -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" -DANDROID_NDK="$NDK_ROOT" -DANDROID_NATIVE_API_LEVEL=$ANDROID_NATIVE_API_LEVEL -DANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN -DANDROID_ABI=$ARCH -DANDROID_STL=$ANDROID_STL -DANDROID_PIE=YES -DENABLE_TESTING=NO $@;
    make -j4;
    make install;
done

echo "Building done.";
