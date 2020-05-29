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
	

rootfs: $(dir_output)/heimdall/rootfs.img $(dir_output)/sdcard/rootfs.tar.gz
	

recovery: $(dir_output)/heimdall/recovery.img $(dir_output)/odin/recovery.img.tar
	

flash: $(dir_output)/heimdall/rootfs.img $(dir_output)/heimdall/recovery.img
	heimdall \
		flash \
		--SYSTEM $(dir_output)/rootfs.img \
		--RECOVERY $(dir_output)/recovery.img

$(dir_output)/heimdall/rootfs.img: $(dir_work)/rootfs.ext4 $(dir_work)/android_img_repack_tools/img2simg
	mkdir -p $(dir_output)/heimdall
	./$(dir_work)/android_img_repack_tools/img2simg $< $@

$(dir_work)/android_img_repack_tools/img2simg:
	git clone \
		-b android-6.0.1 \
		https://github.com/ASdev/android_img_repack_tools \
		$(dir_work)/android_img_repack_tools
	cd $(dir_work)/android_img_repack_tools
	curl https://gist.githubusercontent.com/jedld/4f388496bda03b349f5744f367749a67/raw/47c9ac922e1c30e78d82ffa86232dc78e4f5e910/gistfile1.txt > $(dir_work)/android_img_repack_tools/patch
	cd $(dir_work)/android_img_repack_tools && ./configure
	cd $(dir_work)/android_img_repack_tools/core && patch -p1 < ../patch
	cd $(dir_work)/android_img_repack_tools/external/android_system_core && patch -p1 < ../../patch
	sed -i s/gcc-5/gcc/ $(dir_work)/android_img_repack_tools/Makefile
	cd $(dir_work)/android_img_repack_tools && make img2simg

$(dir_work)/rootfs.ext4: $(dir_output)/sdcard/rootfs.tar.gz
	truncate -s 512M $@
	mkfs.ext4 -F $@
	$(eval MOUNT_DIR=$(shell mktemp -d))
	mount $@ $(MOUNT_DIR)
	tar zxf $< -C $(MOUNT_DIR)
	umount $(MOUNT_DIR)
	rmdir $(MOUNT_DIR)
	resize2fs -M $@

$(dir_output)/sdcard/rootfs.tar.gz:
	mkdir -p $(dir_rootfs) $(dir_output)/sdcard
	@which qemu-debootstrap || echo "qemu-debootstrap not found in path, this will probably fail"
	qemu-debootstrap \
		--arch=armhf \
		--include=net-tools,openssh-server,wpasupplicant \
		buster \
		$(dir_rootfs) \
		http://ftp.debian.org/debian
	cp -r $(dir_src)/overlay/rootfs/* $(dir_rootfs)/
	cd $(dir_rootfs) && tar zcf ../../$(dir_output)/sdcard/rootfs.tar.gz *

$(dir_output)/odin/recovery.img.tar: $(dir_output)/heimdall/recovery.img
	mkdir -p $(dir_output)/odin
	tar cvf $@ \
		-C $(dir_output)/heimdall \
		recovery.img

$(dir_output)/heimdall/recovery.img: $(dir_kernel)/arch/arm64/boot/uImage $(dir_work)/dt.img $(dir_buildroot)/output/images/rootfs.cpio.gz $(dir_buildroot)/output/host/bin/mkbootimg
	mkdir -p $(dir_output)/heimdall
	$(dir_buildroot)/output/host/bin/mkbootimg \
		--kernel $(dir_kernel)/arch/arm64/boot/uImage \
		--ramdisk $(dir_buildroot)/output/images/rootfs.cpio.gz \
		--base 0x10000000 \
		--pagesize 2048 \
		--dt $(dir_work)/dt.img \
		--output $@

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
        -d $< \
        $@

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
	ln -sf `pwd`/$(dir_configs)/kernel $@

$(dir_buildroot)/output/host/bin/dtbtool: buildroot
	

$(dir_buildroot)/output/host/bin/mkbootimg: buildroot
	

$(dir_buildroot)/output/host/bin/mkimage: buildroot
	

$(dir_buildroot)/output/images/rootfs.cpio.gz: buildroot
	

buildroot: $(dir_buildroot) $(dir_buildroot)/.config
	$(MAKE) -j`nproc` -C $(dir_buildroot)

$(dir_downloads)/$(archive_buildroot):
	mkdir -p $(dir_downloads)
	curl $(url_buildroot) > $@
	touch $@

$(dir_buildroot): $(dir_downloads)/$(archive_buildroot)
	mkdir -p $@
	tar zxf $< -C $@ --strip-components=1
	patch -p0 < $(dir_patches)/buildroot/0001-add-mkbootimg.patch
	ln -sf `pwd`/$(dir_src)/packages/mkbootimg $@/package/

$(dir_buildroot)/.config:
	ln -sf `pwd`/$(dir_configs)/buildroot $@

clean:
	rm -rf $(dir_work) $(dir_output)
