#import <Preferences/Preferences.h>

@interface ShowSongMetadataListController: PSListController {
}
@end

@implementation ShowSongMetadataListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ShowSongMetadata" target:self] retain];
	}
	return _specifiers;
}


// From http://iphonedevwiki.net/index.php/PreferenceBundles
// Loading Preferences -> Into sandboxed/unsandboxed processes in iOS 8

#define settingsPath @"/User/Library/Preferences/com.kyewei.showsongmetadata.plist"

-(id) readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
	if (!tweakSettings[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}
	return tweakSettings[specifier.properties[@"key"]];
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
	[defaults setObject:value forKey:specifier.properties[@"key"]];
	[defaults writeToFile:settingsPath atomically:YES];
	//NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
	CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
	if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}

@end

// vim:ft=objc
