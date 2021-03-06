#!/bin/sh

BINUTILS_URL=http://ftp.gnu.org/gnu/binutils/$BINUTILS_PKG
GCC_URL=http://gcc.cybermirror.org/releases/gcc-"$GCC_VERSION"/"$GCC_PKG"
FLEX_URL=http://downloads.sourceforge.net/project/flex/"$FLEX_PKG"
ZLIB_URL=http://zlib.net/"$ZLIB_PKG"
BASH_URL=https://ftp.gnu.org/gnu/bash/"$BASH_PKG"
COREUTILS_URL=http://ftp.gnu.org/gnu/coreutils/"$COREUTILS_PKG"
E2FSPROGS_URL=https://www.kernel.org/pub/linux/kernel/people/tytso/e2fsprogs/v"$E2FSPROGS_VERSION"/"$E2FSPROGS_PKG"
PKGCONFIGLITE_URL=http://downloads.sourceforge.net/project/pkgconfiglite/"$PKGCONFIGLITE_VERSION"/"$PKGCONFIGLITE_PKG"
LIBUUID_URL=http://downloads.sourceforge.net/project/libuuid/"$LIBUUID_PKG"
UTIL_LINUX_URL=https://www.kernel.org/pub/linux/utils/util-linux/v"$UTIL_LINUX_BASE_VERSION"/"$UTIL_LINUX_PKG"
GRUB_URL=ftp://ftp.gnu.org/gnu/grub/"$GRUB_PKG"
SHADOW_URL=http://pkg-shadow.alioth.debian.org/releases/"$SHADOW_PKG"
SED_URL=http://ftp.gnu.org/gnu/sed/"$SED_PKG"
GMP_URL=http://ftp.gnu.org/gnu/gmp/"$GMP_PKG"
MPFR_URL=http://mpfr.org/mpfr-current/"$MPFR_PKG"
MPC_URL=ftp://ftp.gnu.org/gnu/mpc/"$MPC_PKG"
NCURSES_URL=ftp://ftp.gnu.org/gnu/ncurses/"$NCURSES_PKG"
VIM_URL=ftp://ftp.vim.org/pub/vim/unix/"$VIM_PKG"

unpack () {
   if [ -d "$3" ]; then
      return 0
   fi
   print_info "unpacking $2" &&
   tar $1 $2
}

download () {
   if [ -f $1 ]; then
      return 0
   fi
   wget $2
}

download_gnumach () {
   if [ -d gnumach ]; then
      return 0
   fi
   git clone http://git.savannah.gnu.org/cgit/hurd/gnumach.git/
}

download_mig () {
   if [ -d mig ]; then
      return 0
   fi
   git clone http://git.savannah.gnu.org/cgit/hurd/mig.git/
}

download_hurd () {
   if [ -d hurd ]; then
      return 0
   fi
   git clone http://git.savannah.gnu.org/cgit/hurd/hurd.git/ &&
   cd hurd &&
   apply_patch $SCRIPT_DIR/patches/hurd/hurd-libs.patch 1 &&
   apply_patch $SCRIPT_DIR/patches/hurd/hurd-cross.patch 1 &&
   cd ..
}

apply_patch() {
   print_info "Using patch $1 (level: $2)"
   patch -p$2 < $1 || exit 1
}

download_glibc () {
   if [ -d glibc ]; then
      return 0
   fi
   git clone http://git.savannah.gnu.org/cgit/hurd/glibc.git/ &&
   cd glibc &&
   git pull origin tschwinge/Roger_Whittaker &&
   git clone http://git.savannah.gnu.org/cgit/hurd/libpthread.git/ &&
   cd libpthread &&
   (for p in $SCRIPT_DIR/patches/libpthread/*; do
      apply_patch $p 0
   done) &&
   cd .. &&
   (for p in $SCRIPT_DIR/patches/glibc/*; do
      apply_patch $p 1
   done) &&
   cd ..
}

unpack_gcc () {
   unpack jxf $GCC_PKG $GCC_SRC &&
   cd $GCC_SRC &&
   pwd &&
   apply_patch $SCRIPT_DIR/patches/gcc/specs.patch 1 &&
   cd ..
}

download_gcc () {
   download $GCC_PKG $GCC_URL &&
   if [ -d "$GCC_SRC" ]; then
      return 0
   fi
   unpack_gcc
}

download_coreutils () {
   download $COREUTILS_PKG $COREUTILS_URL &&
   if [ ! -d "$COREUTILS_SRC" ]; then
	   unpack Jxf $COREUTILS_PKG $COREUTILS_SRC &&
		cd $COREUTILS_SRC &&
	   apply_patch $SCRIPT_DIR/patches/coreutils/*.patch 1 &&
	cd ..
   fi
}

download_sed () {
	download $SED_PKG $SED_URL &&
	if [ -d "$SED_SRC" ]; then
		return 0
	fi
	unpack zxf $SED_PKG $SED_SRC
	cd "$SED_SRC" &&
	apply_patch $SCRIPT_DIR/patches/sed/debian.patch 1 &&
	cd ..
}

download_ncurses () {
  download $NCURSES_PKG $NCURSES_URL &&
  if [ -d "$NCURSES_SRC" ]; then
    return 0
  fi
  unpack zxf $NCURSES_PKG $NCURSES_SRC
}

download_vim () {
  download $VIM_PKG $VIM_URL &&
  if [ -d "vim$VIM_BASE_VERSION" ]; then
    return 0
  fi
  unpack jxf $VIM_PKG $VIM_SRC
}

