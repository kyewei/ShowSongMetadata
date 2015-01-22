TARGET = iphone:latest:7.0
ARCHS = armv7 arm64

include theos/makefiles/common.mk

TWEAK_NAME = ShowSongMetadata
ShowSongMetadata_FILES = Tweak.xm

ShowSongMetadata_FRAMEWORKS = UIKit Foundation MediaPlayer

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Music"
