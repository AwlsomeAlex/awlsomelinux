#!/bin/sh

## AwlsomeLinux Core Creation Script
## Created by AwlsomeAlex (GNU GPLv3)

##############################
# -------------------------- #
# AwlsomeLinux Configuration #
# -------------------------- #
##############################



##########################
# AwlsomeLinux Variables #
##########################

SRC_DIR=$(pwd)
JOB_FACTOR=1
NUM_CORES=$(grep ^processor /proc/cpuinfo | wc -l)
NUM_JOBS=$((NUM_CORES * JOB_FACTOR))



##############################
# AwlsomeLinux Main Packages #
##############################

KERNEL_DOWNLOAD_URL=http://kernel.org/pub/linux/kernel/v4.x/linux-4.4.25.tar.xz
KERNEL_ARCHIVE_FILE=${KERNEL_DOWNLOAD_URL##*/}
GLIBC_DOWNLOAD_URL=http://ftp.gnu.org/gnu/glibc/glibc-2.24.tar.bz2
GLIBC_ARCHIVE_FILE=${GLIBC_DOWNLOAD_URL##*/}



############################
# ------------------------ #
# AwlsomeLinux Core Script #
# ------------------------ #
############################



##########
# Kernel #
##########

get_kernel() {
	echo "== Get Kernel (Start) =="
	
	# Change Directory to 'core/source'
	cd core/source
	
	# Download Kernel Version Defined in AwlsomeLinux Main Packages
	wget -c $KERNEL_DOWNLOAD_URL
	
	# Clean out old Kernel Work Directory (If 'make clean' or 'make all' wasn't executed)
	rm -rf $SRC_DIR/core/work/kernel
	mkdir $SRC_DIR/core/work/kernel
	
	# Extract .xz Archive to 'core/work/kernel'
	tar -xvf $KERNEL_ARCHIVE_FILE -C $SRC_DIR/core/work/kernel
	
	cd $SRC_DIR
	
	echo "== Get Kernel (Stop) =="
}

build_kernel() {
	echo "== Build Kernel (Start) =="
	
	# Change Directory to Kernel Work
	cd core/work/kernel
	
	# Prepare Kernel Install Area
	rm -rf $SRC_DIR/core/install/kernel
	mkdir $SRC_DIR/core/install/kernel
	
	# Change Directory to Extracted Archive Folder
	cd $(ls -d linux-*)
	
	# Clean Kernel Configuration
	echo "Cleaning Kernel Configuration..."
	make mrproper -j $NUM_JOBS
	
	# Create Default Configuration
	echo "Creating Default Kernel Configuration..."
	make defconfig -j $NUM_JOBS
	
	# Configure Kernel:
	echo "Adding Extra Kernel Arguments for Configuration..."
	sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"awlsomelinux\"/" .config
	sed -i "s/.*CONFIG_OVERLAY_FS.*/CONFIG_OVERLAY_FS=y/" .config
	sed -i "s/.*\\(CONFIG_KERNEL_.*\\)=y/\\#\\ \\1 is not set/" .config 
	sed -i "s/.*CONFIG_KERNEL_XZ.*/CONFIG_KERNEL_XZ=y/" .config
	sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config
	sed -i "s/.*CONFIG_LOGO_LINUX_CLUT224.*/CONFIG_LOGO_LINUX_CLUT224=y/" .config
	sed -i "s/^CONFIG_DEBUG_KERNEL.*/\\# CONFIG_DEBUG_KERNEL is not set/" .config
	sed -i "s/.*CONFIG_EFI_STUB.*/CONFIG_EFI_STUB=y/" .config
	grep -q "CONFIG_X86_32=y" .config
	if [ $? = 1 ] ; then
		echo "CONFIG_EFI_MIXED=y" >> .config
	fi
	
	# Build Linux Kernel
	echo "Building Linux Kerne..."
	make \
		CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
		bzImage -j $NUM_JOBS
		
	# Install Linux Kernel
	echo "Installing Linux Kernel..."
	cp arch/x86/boot/bzImage \
		$SRC_DIR/core/install/kernel/kernel
		
	# Generate Linux Kernel Header Files
	echo "Generating Linux Kernel Headers..."
	make \
		INSTALL_HDR_PATH=$SRC_DIR/core/install/kernel \
		headers_install -j $NUM_JOBS
		
	echo "== Build Kernel (Stop) =="
}



#########
# Glibc # 
#########

get_glibc() {
	#echo "== Get Glibc (Start) =="
	
	# Change Directory to 'core/source'
	#cd core/source
	
	# Download Kernel Version Defined in AwlsomeLinux Main Packages
	#wget -c $GLIBC_DOWNLOAD_URL
	
	# Clean out old Glibc Work Directory (If 'make clean' or 'make all' wasn't executed)
	#rm -rf ../work/glibc
	#mkdir ../work/glibc
	
	# Extract .xz Archive to 'core/work/glibc'
	#tar -xvf $GLIBC_ARCHIVE_FILE -C ../work/glibc
	
	#cd $SRC_DIR
	
	#echo "== Get Glibc (Stop) =="
}

build_glibc() {
	#echo "== Build Glibc (Start) =="
	
	# Change Directory to Glibc Work
	#cd core/work/glibc
	
	# Prepare Glibc Work Area
	#rm -rf glibc_objects
	#mkdir glibc_objects
	
	# Prepare Glibc Install Area & Remember it
	#rm -rf glibc_installed
	#mkdir glibc_installed
	#GLIBC_INSTALLED=$(pwd)/glibc_installed
	
	# Change Directory to Extracted Archive Folder and Remember it
	#cd $(ls -d linux-*)
	#GLIBC_SRC=$(pwd)
	#cd ..
	
	# Change Directory to 'core/work/glibc/glibc_objects'
	#cd glibc_objects
	
	# Configure Glibc
	#$GLIBC_SRC/configure \
		--prefix= \
		--with-headers=$KERNEL_INSTALLED/include \
		--without-gd \
		--without-selinux \
		--disable-werror \
		CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE"
	
	# Compile Glibc from Configuration
	#make -j $NUM_JOBS
	
	# Configure Kernel:
	#echo "Adding Extra Kernel Arguments for Configuration..."
	#sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"awlsomelinux\"/" .config
	#sed -i "s/.*CONFIG_OVERLAY_FS.*/CONFIG_OVERLAY_FS=y/" .config
	#sed -i "s/.*\\(CONFIG_KERNEL_.*\\)=y/\\#\\ \\1 is not set/" .config 
	#sed -i "s/.*CONFIG_KERNEL_XZ.*/CONFIG_KERNEL_XZ=y/" .config
	#sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config
	#sed -i "s/.*CONFIG_LOGO_LINUX_CLUT224.*/CONFIG_LOGO_LINUX_CLUT224=y/" .config
	#sed -i "s/^CONFIG_DEBUG_KERNEL.*/\\# CONFIG_DEBUG_KERNEL is not set/" .config
	#sed -i "s/.*CONFIG_EFI_STUB.*/CONFIG_EFI_STUB=y/" .config
	#grep -q "CONFIG_X86_32=y" .config
	#if [ $? = 1 ] ; then
	#	echo "CONFIG_EFI_MIXED=y" >> .config
	#fi
	
	# Build Linux Kernel
	#echo "Building Linux Kerne..."
	#make \
		CFLAGS="-Os -s -fno-stack-protector -U_FORTIFY_SOURCE" \
		bzImage -j $NUM_JOBS
		
	# Install Linux Kernel
	#echo "Installing Linux Kernel..."
	#cp arch/x86/boot/bzImage \
		$SRC_DIR/core/work/kernel/kernel_ready/kernel
		
	# Generate Linux Kernel Header Files
	#echo "Generating Linux Kernel Headers..."
	#make \
		INSTALL_HDR_PATH=$SRC_DIR/core/work/kernel/kernel_ready \
		headers_install -j $NUM_JOBS
		
	#echo "== Build Kernel (Stop) =="
}

prepare_glibc() {
	echo "Prepare Glibc"
}



###################
# Busybox Compile #
###################

get_busybox() {
	echo "Get Busybox"
}

build_busybox() {
	echo "Build Busybox"
}



###################
# RootFS Creation #
###################

prepare_src() {
	echo "Prepare Source Code"
}

generate_rootfs() {
	echo "Generate RootFS"
}

pack_rootfs() {
	echo "Pack RootFS"
}



####################
# Extract Syslinux #
####################

get_syslinux() {
	echo "Get Syslinux"
}

get_kernel
build_kernel
