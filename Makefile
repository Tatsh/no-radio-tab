TARGET := iphone:8.1:7.1
ARCHS = armv7 armv7s arm64
include theos/makefiles/common.mk

TWEAK_NAME = NoRadioTab
NoRadioTab_FILES = Tweak.xm
NoRadioTab_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
