TARGET = iphone:latest:7.0
ARCHS = armv7 arm64 armv7s

include theos/makefiles/common.mk

BUNDLE_NAME = ShowSongMetadata
ShowSongMetadata_FILES = ShowSongMetadata.mm
ShowSongMetadata_INSTALL_PATH = /Library/PreferenceBundles
ShowSongMetadata_FRAMEWORKS = UIKit
ShowSongMetadata_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ShowSongMetadata.plist$(ECHO_END)
