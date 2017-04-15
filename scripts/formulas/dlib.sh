#! /bin/bash
#
# DLIB
#
# uses CMake

# define the version
VER=19.4

# tools for git use
GIT_URL="https://github.com/davisking/dlib"
#GIT_TAG="v$VER"
GIT_TAG=

FORMULA_TYPES=( "osx" "android" "linux64")

# download the source code
function download() {
		git clone --depth 1 $GIT_URL
}

# prepare the build environment, executed inside the lib src dir
function prepare() {
   	if [ "$TYPE" == "android" ] ; then
   		cp -rf $FORMULA_DIR/jni/  jni
	fi
}

# executed inside the lib src dir
function build() {
  if [ "$TYPE" == "osx" ] || [ "$TYPE" == "linux64" ] ; then
		cd dlib
		mkdir -p build
		cd build
		export MAKEFLAGS="-j$PARALLEL_MAKE -s"
		cmake -D DLIB_NO_GUI_SUPPORT=yes -D CMAKE_INSTALL_PREFIX=$LIBS_DIR/dlib/install ..
		cmake ..
		cmake --build . --config Release
		cd ../../
	elif [ "$TYPE" == "android" ] ; then
		${NDK_ROOT}/ndk-build -j4 NDK_DEBUG=0 NDK_PROJECT_PATH=.
	fi
}
# executed inside the lib src dir, first arg $1 is the dest libs dir root
function copy() {
    # headers
	if [ -d $1/include ]; then
	    rm -rf $1/include
	fi
	mkdir -p $1/include

	if [ "$TYPE" == "osx" ] || [ "$TYPE" == "linux64" ] ; then
		cd $BUILD_DIR/dlib/dlib/build
		make install
		cd -
		mkdir -p  $1/lib/$TYPE/
		mv $1/install/lib/libdlib.a $1/lib/$TYPE/
		mv $1/install/include/dlib $1/include/
		rm -r $1/install
	elif [ "$TYPE" == "android" ] ; then
	    cp -vr dlib/ $1/include/dlib
		rm -rf $1/include/dlib/build
	    rm -rf $1/include/dlib/test
	    rm  $1/include/dlib/all_gui.cpp
	    cp -vr obj/local/armeabi-v7a/libdlib.a $1/lib/android/armeabi-v7a/libdlib.a
	    cp -vr obj/local/x86/libdlib.a $1/lib/android/x86/libdlib.a
	fi
	OFXDLIB_LIBS_INCLUDE="$ADDONS_DIR/ofxDLib/libs/dlib/include"
	OFXDLIB_LIBS_LIB="$ADDONS_DIR/ofxDLib/libs/dlib/lib/$TYPE"
	rm -rf $OFXDLIB_LIBS_INCLUDE 
	rm -rf $OFXDLIB_LIBS_LIB

	mkdir -p $OFXDLIB_LIBS_INCLUDE
	mkdir -p $OFXDLIB_LIBS_LIB
	
	echo "Copying ..."
	cp -vR $1/include/ $OFXDLIB_LIBS_INCLUDE
	cp -vR $1/lib/$TYPE/ $OFXDLIB_LIBS_LIB
}

# executed inside the lib src dir
function clean() {
	if [ "$TYPE" == "osx" ] ; then
   		cd dlib/build
   		cmake clean .
   		cd ..
   		rm -rf build
		cd ..
	elif [ "$TYPE" == "android" ] ; then
		rm -rf obj
	fi

}
