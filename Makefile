dir_work = work
dir_src = src
dir_output = output
dir_downloads = $(dir_work)/downloads
dir_buildroot = $(dir_work)/buildroot
dir_configs = $(dir_src)/configs
dir_patches = $(dir_src)/patches
dir_kernel = $(dir_work)/kernel
dir_rootfs = $(dir_work)/rootfs
dir_kernel_toolchain = $(dir_work)/kernel_toolchain
archive_buildroot = buildroot.tar.gz
url_buildroot = https://buildroot.org/downloads/buildroot-2020.02.tar.gz
url_kernel_toolchain = https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.8
url_kernel = https://github.com/Shubzz-02/Samsung_grandprimevelte_Kernel
revision_git_kernel = master
KERNEL_ARCH=arm64
KERNEL_CROSS_COMPILE=PLATFORM/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.8/aarch64-linux-android-

all: recovery rootfs
	

rootfs:
	mkdir -p $(dir_rootfs) $(dir_output)
	@which qemu-debootstrap || echo "qemu-debootstrap not found in path, this will probably fail"
	qemu-debootstrap \
		--arch=armhf \
		--include=net-tools,openssh-server,wpasupplicant \
		buster \
		$(dir_rootfs) \
		http://ftp.debian.org/debian
	cp -r $(dir_src)/overlay/rootfs/* $(dir_rootfs)/
	cd $(dir_rootfs) && tar zcf ../../$(dir_output)/rootfs.tar.gz *

flash_recovery: $(dir_output)/recovery.img
	heimdall \
		flash \
		--RECOVERY \
		$(dir_output)/recovery.img

recovery: $(dir_output)/recovery.img.tar
	

$(dir_output)/recovery.img.tar: $(dir_output)/recovery.img
	tar cvf $(dir_output)/recovery.img.tar \
		-C $(dir_output) \
		recovery.img

$(dir_output)/recovery.img: $(dir_kernel)/arch/arm64/boot/uImage $(dir_work)/dt.img $(dir_buildroot)/output/images/rootfs.cpio.gz $(dir_buildroot)/output/host/bin/mkbootimg
	$(dir_buildroot)/output/host/bin/mkbootimg \
		--kernel $(dir_kernel)/arch/arm64/boot/uImage \
		--ramdisk $(dir_buildroot)/output/images/rootfs.cpio.gz \
		--base 0x10000000 \
		--pagesize 2048 \
		--dt $(dir_work)/dt.img \
		--output $(dir_output)/recovery.img

$(dir_work)/dt.img: $(dir_buildroot)/output/host/bin/dtbtool $(dir_kernel)/arch/arm64/boot/dts/pxa1908-grandprimevelte-00.dtb $(dir_kernel)/arch/arm64/boot/dts/pxa1908-grandprimevelte-01.dtb
	mkdir -p $(dir_output)
	$(dir_buildroot)/output/host/bin/dtbtool \
		-o $(dir_work)/dt.img \
		-p $(dir_kernel)/scripts/dtc/ \
		-s 2048 \
		$(dir_kernel)/arch/arm64/boot/dts/

$(dir_kernel)/arch/arm64/boot/uImage: $(dir_kernel)/arch/arm64/boot/Image.gz $(dir_buildroot)/output/host/bin/mkimage
	$(dir_buildroot)/output/host/bin/mkimage \
        -A arm64 \
        -O linux \
        -T kernel \
        -C gzip \
        -a 01000000 \
        -e 01000000 \
        -d $(dir_kernel)/arch/arm64/boot/Image.gz \
        $(dir_kernel)/arch/arm64/boot/uImage

$(dir_kernel)/arch/arm64/boot/Image.gz: kernel_toolchain_link $(dir_kernel) $(dir_kernel)/.config
	export ARCH=$(KERNEL_ARCH)
	export CROSS_COMPILE=$(KERNEL_CROSS_COMPILE)
	$(MAKE) -j`nproc` -C $(dir_kernel)

$(dir_kernel)/arch/arm64/boot/dts/pxa1908-grandprimevelte-00.dtb: kernel_toolchain_link $(dir_kernel) $(dir_kernel)/.config
	export ARCH=$(KERNEL_ARCH)
	export CROSS_COMPILE=$(KERNEL_CROSS_COMPILE)
	$(MAKE) -j`nproc` -C $(dir_kernel) dtbs

$(dir_kernel)/arch/arm64/boot/dts/pxa1908-grandprimevelte-01.dtb: kernel_toolchain_link $(dir_kernel) $(dir_kernel)/.config
	export ARCH=$(KERNEL_ARCH)
	export CROSS_COMPILE=$(KERNEL_CROSS_COMPILE)
	$(MAKE) -j`nproc` -C $(dir_kernel) dtbs

kernel_toolchain_link: $(dir_kernel_toolchain)
	mkdir -p $(dir_work)/PLATFORM/prebuilts/gcc/linux-x86/aarch64
	ln -sf `pwd`/$(dir_kernel_toolchain) $(dir_work)/PLATFORM/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.8

$(dir_kernel_toolchain):
	git clone $(url_kernel_toolchain) $(dir_kernel_toolchain)

$(dir_kernel):
	git clone $(url_kernel) $(dir_kernel) -b $(revision_git_kernel)

$(dir_kernel)/.config:
	ln -sf `pwd`/$(dir_configs)/kernel $(dir_kernel)/.config

$(dir_buildroot)/output/host/bin/dtbtool: buildroot
	

$(dir_buildroot)/output/host/bin/mkbootimg: buildroot
	

$(dir_buildroot)/output/host/bin/mkimage: buildroot
	

$(dir_buildroot)/output/images/rootfs.cpio.gz: buildroot
	

buildroot: $(dir_buildroot) $(dir_buildroot)/.config
	$(MAKE) -j`nproc` -C $(dir_buildroot)

$(dir_downloads)/$(archive_buildroot):
	mkdir -p $(dir_downloads)
	curl $(url_buildroot) > $(dir_downloads)/$(archive_buildroot)
	touch $@

$(dir_buildroot): $(dir_downloads)/$(archive_buildroot)
	mkdir -p $(dir_buildroot)
	tar zxf $(dir_downloads)/$(archive_buildroot) -C $(dir_buildroot) --strip-components=1
	patch -p0 < $(dir_patches)/buildroot/0001-add-mkbootimg.patch
	ln -sf `pwd`/$(dir_src)/packages/mkbootimg $(dir_buildroot)/package/

$(dir_buildroot)/.config:
	ln -sf `pwd`/$(dir_configs)/buildroot $(dir_buildroot)/.config

clean:
	rm -rf $(dir_work) $(dir_output)
