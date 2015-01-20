
#import "ShowSongMetadataHeader.h"


%hook MusicCollectionTrackTableViewCell

%new
-(void) displayPopup: (UIButton*) sender {
	if ([[sender class] isSubclassOfClass:[UIButton class]]){

		//sample info for now

		UIAlertView *alertView = [[UIAlertView alloc]
		initWithTitle:@"Song Metadata"
		message:@"Title: Feeling Good\nArtist: Michael Buble\nYear: 2005\nCopyright: 2005 Reprise Records\n"
		delegate:self
		cancelButtonTitle:@"Done"
		otherButtonTitles:nil];

		[alertView show];
	}
}

%new
- (id) getDetailButton:(MusicCollectionTrackTableViewCell*)cell {
	UITableViewCellDetailDisclosureView * disclosureView = MSHookIvar<UITableViewCellDetailDisclosureView*>(self, "_accessoryView");
	[disclosureView setUserInteractionEnabled:YES];
	UIButton * infoButton  = MSHookIvar<UIButton*>(disclosureView, "_infoButton");
	[infoButton setUserInteractionEnabled:YES];
	return infoButton;
}

- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 {
	id result = %orig;

	[self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	// UITableViewCellAccessoryDetailDisclosureButton is 2
	// UITableViewCellAccessoryDetailButton is 4


	UIButton * infoButton = [self getDetailButton:self];

	[infoButton addTarget:self
				action:@selector(displayPopup:)
				forControlEvents:UIControlEventTouchDown];
	//UIControlEventTouchDown is 1
	//UIControlEventTouchUpInside is 64, but doesn't work, maybe absorbed by other Gesture Recognizers?

	return result;
}

%end
