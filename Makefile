TARGET = iphone:latest:7.0
ARCHS = armv7 arm64 armv7s

include theos/makefiles/common.mk

TWEAK_NAME = ShowSongMetadata
ShowSongMetadata_FILES = Tweak.xm

ShowSongMetadata_FRAMEWORKS = UIKit Foundation MediaPlayer AVFoundation AudioToolbox

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Music"
SUBPROJECTS += showsongmetadata
include $(THEOS_MAKE_PATH)/aggregate.mk
