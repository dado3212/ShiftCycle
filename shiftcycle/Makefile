ARCHS = armv7 armv7s arm64 arm64e

include theos/makefiles/common.mk

BUNDLE_NAME = ShiftCycle
ShiftCycle_FILES = ShiftCycle.mm
ShiftCycle_INSTALL_PATH = /Library/PreferenceBundles
ShiftCycle_FRAMEWORKS = UIKit
ShiftCycle_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ShiftCycle.plist$(ECHO_END)
