ARCHS = armv7 armv7s arm64 arm64e


DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1




include $(THEOS)/makefiles/common.mk


TWEAK_NAME = LockApps

LockApps_FILES = LockApps.xm UIAlert+Blocks.m 
LockApps_FRAMEWORKS = LocalAuthentication
LockApps_CFLAGS = -fobjc-arc
LockApps_LIBRARIES = sparkapplist

include $(THEOS)/makefiles/tweak.mk
SUBPROJECTS += lockapps
include $(THEOS)/makefiles/aggregate.mk
