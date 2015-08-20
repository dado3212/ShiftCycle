ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = ShiftCycle
ShiftCycle_FILES = Tweak.xm
ShiftCycle_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += shiftcycle
include $(THEOS_MAKE_PATH)/aggregate.mk
