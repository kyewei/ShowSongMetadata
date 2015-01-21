include theos/makefiles/common.mk

TWEAK_NAME = ShowSongMetadata
ShowSongMetadata_FILES = Tweak.xm
ARCHS = armv7 arm64
ShowSongMetadata_FRAMEWORKS = UIKit Foundation MediaPlayer

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Music"
