TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = SpringBoard
THEOS_DEVICE_IP = 172.20.10.1
THEOS_DEVICE_PORT = 22


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LockBtc

LockBtc_FILES = Tweak.x
LockBtc_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
