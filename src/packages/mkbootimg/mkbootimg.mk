################################################################################
#
# mkbootimg
#
################################################################################

MKBOOTIMG_VERSION = 2019.09.20
MKBOOTIMG_SITE_METHOD = git
MKBOOTIMG_SITE = https://github.com/osm0sis/mkbootimg
MKBOOTIMG_LICENSE = GPL-2.0+
MKBOOTIMG_INSTALL_STAGING = YES

define HOST_MKBOOTIMG_BUILD_CMDS
	curl https://raw.githubusercontent.com/TeamWin/android_device_samsung_grandprimevelte/android-5.1/tools/mkbootimg.c > $(@D)/mkbootimg.c
	curl https://raw.githubusercontent.com/TeamWin/android_device_samsung_grandprimevelte/android-5.1/tools/bootimg.h > $(@D)/bootimg.h
	curl https://raw.githubusercontent.com/TeamWin/android_device_samsung_grandprimevelte/android-5.1/tools/dtbtool.c > $(@D)/dtbtool.c
	$(HOST_CONFIGURE_OPTS) $(MAKE) -C $(@D)
endef

define HOST_MKBOOTIMG_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/mkbootimg $(HOST_DIR)/bin/
	$(INSTALL) -D -m 0755 $(@D)/dtbtool $(HOST_DIR)/bin/
endef

$(eval $(host-generic-package))