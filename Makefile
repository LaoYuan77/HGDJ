# 指定目标平台为 iOS 和架构
TARGET := iphone:clang:latest:14.0
ARCHS = arm64

# 你的插件名称
TWEAK_NAME = HongGuoPatch

# 指定需要编译的源文件
HongGuoPatch_FILES = Tweak.x
HongGuoPatch_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
