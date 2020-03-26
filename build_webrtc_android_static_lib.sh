#!/bin/sh

# This script is used to build the webrtc static library.
# You need to put it into the webrtc source code root directory.

rm -rf out

# check the params
if [ $# != 1 ]; then
    echo "Usage:"
    echo "  sh build_webrtc_static_lib.sh STATIC_MODULE_NAME"
    echo "For example:"
    echo "  sh build_webrtc_static_lib.sh audio_processing"
    exit 1
fi

lib_name=$1

# build the 32bit static library
gn gen out/intermediate/arm --args='target_os="android" target_cpu="arm" use_custom_libcxx=false'

ninja -C out/intermediate/arm ${lib_name}

rm -rf out/intermediate/arm/tmp
mkdir -p out/intermediate/arm/tmp

# copy all .o files to a temp directory
find out/intermediate/arm/obj -name *.o | xargs -n1 -I {} cp {} ./out/intermediate/arm/tmp

cd out/intermediate/arm/tmp

# use the .o files to generate static library
ar rc lib${lib_name}.a *.o

cd ../../../..

mkdir -p out/lib/armeabi-v7a

cp out/intermediate/arm/tmp/lib${lib_name}.a out/lib/armeabi-v7a


# build the 64bit static library
gn gen out/intermediate/arm64 --args='target_os="android" target_cpu="arm64" use_custom_libcxx=false'

ninja -C out/intermediate/arm64 ${lib_name}

rm -rf out/intermediate/arm64/tmp
mkdir -p out/intermediate/arm64/tmp

# copy all .o files to a temp directory
find out/intermediate/arm64/obj -name *.o | xargs -n1 -I {} cp {} ./out/intermediate/arm64/tmp

cd out/intermediate/arm64/tmp

# use the .o files to generate static library
ar rc lib${lib_name}.a *.o

cd ../../../..

mkdir -p out/lib/arm64-v8a

cp out/intermediate/arm64/tmp/lib${lib_name}.a out/lib/arm64-v8a


# copy the header files
echo "copying the header files..."
mkdir -p out/include
find . -name "*.h" -type f -exec cp --parents {} ./out/include \;