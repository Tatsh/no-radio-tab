TARGET := iphone:11.0:7.1
ARCHS = armv7 armv7s arm64
include theos/makefiles/common.mk

TWEAK_NAME = NoRadioTab
NoRadioTab_FILES = Tweak.xm
NoRadioTab_FRAMEWORKS = UIKit
NoRadioTab_LDFLAGS += -Wl,-segalign,4000

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
