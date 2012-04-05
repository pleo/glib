#!/bin/bash
# Copyright (c) 2012 Leon Pajk. All rights reserved.
# Use of this source code is governed by a LGPL-style license that can be
# found in the LICENSE file.
#

# nacl-glib-2.28.8.sh
#
# usage:  nacl-glib-2.28.8.sh
#
# this script downloads, patches, and builds glib for Native Client
#

readonly URL=http://commondatastorage.googleapis.com/nativeclient-mirror/nacl/glib-2.28.8.tar.bz2
# readonly URL=http://ftp.gnome.org/pub/gnome/sources/glib/2.28/glib-2.28.8.tar.bz2
readonly PATCH_FILE=nacl-glib-2.28.8.patch
readonly PACKAGE_NAME=glib-2.28.8

source ../../build_tools/common.sh

CustomConfigureStep() {
  Banner "Configuring ${PACKAGE_NAME}"
  # export the nacl tools
  export CC=${NACLCC}
  export CXX=${NACLCXX}
  export AR=${NACLAR}
  export RANLIB=${NACLRANLIB}
  export PKG_CONFIG_PATH=${NACL_SDK_USR_LIB}/pkgconfig
  export PKG_CONFIG_LIBDIR=${NACL_SDK_USR_LIB}
  export PATH=${NACL_BIN_PATH}:${PATH}
  ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_NAME}
  Remove ${PACKAGE_NAME}-build
  MakeDir ${PACKAGE_NAME}-build
  cp nacl.cache ${PACKAGE_NAME}-build/nacl.cache.tmp
  cd ${PACKAGE_NAME}-build
  
  sed -i 's@--cflags "zlib"@--libs "zlib"@g' ../configure
  sed -i '7970 i found_zlib=yes' ../configure
  sed -i 's@if test "$gt_cv_have_gettext" != "yes" ;@if test "$gt_cv_have_gettext" = "XXX" ;@g' ../configure
  sed -i 's@as_fn_error \$? "Could not determine values for AF_INET\* constants" "\$LINENO" 5@echo@g' ../configure
  sed -i 's@as_fn_error $? "Could not determine values for MSG_\* constants" "\$LINENO" 5@echo@g' ../configure
  sed -i 's@res_query("test", 0, 0, (void \*)0, 0);@@g' ../configure
  sed -i 's@as_fn_error \$? "not found" "\$LINENO" 5@echo@g' ../configure
  sed -i 's@SA_RESTART@0x10000000@g' ../glib/gmain.c ../glib/gtester.c
  sed -i 's@#include\s\+<unistd.h>@//\0@g' ../glib/gslice.c
  sed -i 's@\(sys_page_size\s*=\s*\)\(sysconf\)@\14096; //\1\2@g' ../glib/gslice.c
  sed -i 's@SSIZE_MAX@32767@g' ../glib/giounix.c
  sed -i 's@#ifdef HAVE_SYS_RESOURCE_H@#if 0 //\0@g' ../glib/gspawn.c
  sed -i 's@sysconf\s\?(_SC_OPEN_MAX)@1024; //\0@g' ../glib/gspawn.c
  sed -i 's@(gethostnam@(0);//\0@g' ../glib/gutils.c
  sed -i 's@ensure_unix_signal_handler_installed_unlocked@//\0@g' ../glib/gmain.c
  sed -i 's@g_child_watch_source_init_multi_threaded\s\+()@;//\0@g' ../glib/gmain.c
  sed -i 's@sigaction\s\+(@;//\0@g' ../glib/gmain.c
  sed -i 's@g_error ("%s: failed to allocate[^;]+;@;//\0@g' ../glib/gmem.c
  sed -i 'N;s/\(g_error\s\+([^\n]*\n\)\([^;]*\)/;\/\/\1\/\/\2/g;P;D;' ../glib/gmem.c
  sed -i "s@setlocale\s\+(@'xx';//\0@g" ../glib/guniprop.c
  
  export LANG=
  export LC_CTYPE="POSIX"
  export LC_NUMERIC="POSIX"
  export LC_TIME="POSIX"
  export LC_COLLATE="POSIX"
  export LC_MONETARY="POSIX"
  export LC_MESSAGES="POSIX"
  export LC_PAPER="POSIX"
  export LC_NAME="POSIX"
  export LC_ADDRESS="POSIX"
  export LC_TELEPHONE="POSIX"
  export LC_MEASUREMENT="POSIX"
  export LC_IDENTIFICATION="POSIX"
  export LC_ALL=
  
  ../configure \
    --host=nacl \
    --disable-shared \
    --prefix=${NACL_SDK_USR} \
    --exec-prefix=${NACL_SDK_USR} \
    --libdir=${NACL_SDK_USR_LIB} \
    --oldincludedir=${NACL_SDK_USR_INCLUDE} \
    --${NACL_OPTION}-mmx \
    --${NACL_OPTION}-sse \
    --${NACL_OPTION}-sse2 \
    --${NACL_OPTION}-asm \
    --cache-file=nacl.cache.tmp \
    --disable-nls \
    --disable-man \
    --disable-gtk-doc \
    --enable-gc-friendly
}

CustomPackageInstall() {
  DefaultPreInstallStep
  DefaultDownloadBzipStep
  DefaultExtractBzipStep
  DefaultPatchStep
  CustomConfigureStep
  DefaultBuildStep
  DefaultInstallStep
  DefaultCleanUpStep
}

CustomPackageInstall
exit 0
