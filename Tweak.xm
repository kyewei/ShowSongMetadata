/*
 * ShowSongMetadata
 * Tweak.xm
 *
 * 2015 Kye Wei
*/

#import "ShowSongMetadataHeader.h"


%hook MusicTableViewCell

%new
- (id) getDetailButton:(MusicCollectionTrackTableViewCell*)cell {
	UITableViewCellDetailDisclosureView * disclosureView = MSHookIvar<UITableViewCellDetailDisclosureView*>(self, "_accessoryView");
	if (!disclosureView) {
		NSLog(@"Did not get disclosureView.");
		return nil;
	}
	[disclosureView setUserInteractionEnabled:YES];
	UIButton * infoButton  = MSHookIvar<UIButton*>(disclosureView, "_infoButton");
	if (!infoButton) {
		NSLog(@"Did not get infoButton.");
		return nil;
	}
	[infoButton setUserInteractionEnabled:YES];
	return infoButton;
}

%new
- (id)getTableView:(UITableViewCell*) cell {
	id view = [cell superview];
	while (view && [view isKindOfClass:[UITableView class]] == NO) {
		view = [view superview];
	}
	UITableView *tableView = (UITableView *)view;
	return tableView;
}

%new
- (AudioFileID) getAudioFileID:(ExtAudioFileRef)fileRef {
	OSStatus status;
	AudioFileID result = NULL;

	UInt32 size = sizeof(result);
	status = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_AudioFile, &size, &result);
	assert(status == noErr);

	return result;
}

%new
- (UInt32) getBitRate:(AudioFileID)audioFileId {
	OSStatus status;
	UInt32 result = 0;

	UInt32 size = sizeof(result);
	status = AudioFileGetProperty(audioFileId, kAudioFilePropertyBitRate, &size, &result);
	assert(status == noErr);

	return result;
}

%new
-(void) displayPopup: (UIButton*) sender {
	if ([[sender class] isSubclassOfClass:[UIButton class]]){

		MPConcreteMediaItem *songEntity = [self getMediaItem:self];
		if (!songEntity) {
			NSLog(@"Did not get songEntity.");
			return;
		}

		//NSLog(@"%@\n",[songEntity title]);

		NSURL *assetURL = [songEntity assetURL];
		AVAssetTrack *audioTrack;
		UInt32 bitRate;
		if (assetURL){
			AVURLAsset *asset = [AVAsset assetWithURL:assetURL];

			NSArray *audioTracks = [asset tracksWithMediaType:@"soun"]; // AVMediaTypeAudio=@"soun"

			audioTrack = [audioTracks objectAtIndex:0];

			//float bitRate = [audioTrack estimatedDataRate];
			//int sampleRate = [audioTrack naturalTimeScale];


			// Found here:
			//https://stackoverflow.com/questions/23241957/how-to-get-the-bit-rate-of-existing-mp3-or-aac-in-ios
			ExtAudioFileRef extAudioFileRef;
			OSStatus result = noErr;
			result = ExtAudioFileOpenURL((__bridge CFURLRef) assetURL, &extAudioFileRef);

			AudioFileID audioFileId = [self getAudioFileID:extAudioFileRef];;
			bitRate = [self getBitRate:audioFileId];
		} else {
			audioTrack = nil;
			bitRate = 0;
		}


		// Entire string:
		NSString *info = [NSString stringWithFormat:@"Title: %@\nArtist: %@\nAlbum Artist: %@\nComposer: %@\nGenre: %@\nYear: %llu\nRelease Date: %@\nComments: %@\nPlay Count: %llu\nSkip Count: %llu\nPlays Since Sync: %llu\nSkips Since Sync: %llu\nLast Played: %@\nBitrate: %dkbps\nSample Rate: %dHz",
		[songEntity title],
		[songEntity artist],
		[songEntity albumArtist],
		[songEntity composer],
		[songEntity genre],
		[songEntity year],
		[[songEntity releaseDate] dateWithCalendarFormat:@"%Y-%m-%d" timeZone:nil],
		[songEntity comments],
		[songEntity playCount],
		[songEntity skipCount],
		[songEntity playCountSinceSync],
		[songEntity skipCountSinceSync],
		[[songEntity lastPlayedDate] dateWithCalendarFormat:@"%Y-%m-%d" timeZone:nil],
		//(int)[audioTrack estimatedDataRate]/1000 ,// bitrate, but only works for AAC files (i.e. .m4a extension)
		(int)bitRate/1000,
		[audioTrack naturalTimeScale]]; //sampleRate

		UIAlertView *alertView = [[UIAlertView alloc]
		initWithTitle:@"Song Metadata"
		message:info
		delegate:self
		cancelButtonTitle:@"Done"
		otherButtonTitles:nil];

		[alertView show];
	} else {
		NSLog(@"Sender is not a UITableViewCell??");
	}
}
%end

%hook MusicCollectionTrackTableViewCell

%new
- (id) getMediaItem:(UITableViewCell*)cell {
	// Table View
	MusicTableView *tableView = [self getTableView:self];
	if (!tableView) {
		NSLog(@"Did not get tableView:MusicCollectionTrackTableViewCell.");
		return nil;
	}
	// Table's View Controller
	MusicAlbumsDetailViewController *controller =  [tableView delegate];  // or [tableView dataSource];
	if (!controller) {
		NSLog(@"Did not get controller:MusicCollectionTrackTableViewCell.");
		return nil;
	}

	// Want to get cell's position in Table View, which can then be used as an index
	NSIndexPath *cellPosition = [tableView indexPathForCell:self];
	if (!cellPosition) {
		NSLog(@"Did not get cellPosition:MusicCollectionTrackTableViewCell.");
		return nil;
	}
	int section = cellPosition.section;
	int row = cellPosition.row;

	// MusicActionTableViewCell (The Shuffle Button that appear when there is more than one album)
	//   shifts the sections by +1
	// Detect, and reverse this:

	UITableViewCell *checkCell = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
	if (/*checkCell && */[checkCell isKindOfClass:[self class]] == YES
		|| [NSStringFromClass([self class]) isEqualToString:@"MusicFlipsideAlbumTrackTableViewCell"]) {
			// For some reason MusicFlipsideAlbumTrackTableViewCell's tableView's cellForRowAtIndexPath produces null..

		// It is not a shuffle cell, don't do anything
	} else {
		// Then the shuffle section exists, and we have an off-by-one error;
		//Fix:
		section--;
	}

	/*NSDictionary *appliedProperties = MSHookIvar<NSDictionary*>(tableView, "_cellClassDict");
	id lookup = [appliedProperties objectForKey:@"MusicShuffleActionCellConfiguration"];
	NSLog(@"%d\n", (int)lookup);*/


	//NSLog(@"Clicked section %d, row %d\n", section, row);
	MusicArtistAlbumsDataSource *dataSource = [controller dataSource];
	if (!dataSource) {
		NSLog(@"Did not get dataSource:MusicCollectionTrackTableViewCell.");
		return nil;
	}

	NSArray *mediaEntities = [dataSource sectionEntities];
	if (!mediaEntities) {
		NSLog(@"Did not get mediaEntities:MusicCollectionTrackTableViewCell.");
		return nil;
	}
	//NSLog(@"%mediaEntities: length %d\n",[mediaEntities count]);
	if (section >= [mediaEntities count]){
		NSLog(@"Outofbounds mediaEntities:MusicCollectionTrackTableViewCell:%d %lu",section,(unsigned long)[mediaEntities count]);
		return nil;
	}
	MPConcreteMediaItemCollection *sectionCollection = [mediaEntities objectAtIndex: section];
	NSArray *songCollection = [sectionCollection items];
	if (!songCollection) {
		NSLog(@"Did not get songCollection.");
		return nil;
	}
	if (row >= [songCollection count]){
		NSLog(@"Outofbounds songCollection:MusicCollectionTrackTableViewCell:%d %lu",row,(unsigned long)[songCollection count]);
		return nil;
	}
	MPConcreteMediaItem *songEntity = [songCollection objectAtIndex: row];
	return songEntity;
}


- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 {
	id result = %orig;

	/*NSString *cellType = [self reuseIdentifier];
	if (!([cellType isEqualToString:@"MusicAlbumTracksCellConfiguration"])) {
		return result;
	}*/

	[self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	// UITableViewCellAccessoryDetailDisclosureButton is 2
	// UITableViewCellAccessoryDetailButton is 4


	UIButton * infoButton = [self getDetailButton:self];

	if (! infoButton) {
		NSLog(@"MusicCollectionTrackTableViewCell accessory button not made!");
	}

	[infoButton addTarget:self
	action:@selector(displayPopup:)
	forControlEvents:UIControlEventTouchDown];
	//UIControlEventTouchDown is 1
	//UIControlEventTouchUpInside is 64, but doesn't work, maybe absorbed by other Gesture Recognizers?

	return result;
}

%end

%hook MusicSongListTableViewCell

%new
- (int) rowsBeforeSection:(int)section inTable:(UITableView*)tableView {
	int start = 0;

	UITableViewCell *checkCell = [tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:0 inSection:0]];
	if (checkCell && [checkCell isKindOfClass:[self class]] == YES) {
		// It is not a shuffle cell, don't do anything
	} else {
		start = 1;
	}

	int cellCount=0;
	for (int i = start; i< section; ++i) {
		cellCount += [tableView numberOfRowsInSection:i];
	}
	return cellCount;
}

%new
- (id) getMediaItem:(UITableViewCell*)cell {
	// Table View
	MusicTableView *tableView = [self getTableView:self];
	if (!tableView) {
		NSLog(@"Did not get tableView:MusicSongListTableViewCell.");
		return nil;
	}

	// Table's View Controller
	MusicSongsViewController *controller =  [tableView delegate];  // or [tableView dataSource];
	if (!controller) {
		NSLog(@"Did not get controller:MusicSongListTableViewCell.");
		return nil;
	}

	// Want to get cell's position in Table View, which can then be used as an index
	NSIndexPath *cellPosition = [tableView indexPathForCell:self];
	if (!cellPosition) {
		NSLog(@"Did not get cellPosition:MusicSongListTableViewCell.");
		return nil;
	}
	int section = cellPosition.section;
	int row = cellPosition.row;

	int combinedNumber = [self rowsBeforeSection:section inTable:tableView];
	//NSLog(@"%d\n", combinedNumber);

	//NSLog(@"Clicked section %d, row %d\n", section, row);
	MusicSongsDataSource *dataSource = [controller dataSource];
	if (!dataSource) {
		NSLog(@"Did not get dataSource:MusicSongListTableViewCell.");
		return nil;
	}

	NSArray *songCollection = [dataSource entities];
	if (!dataSource) {
		NSLog(@"Did not get songCollection:MusicSongListTableViewCell.");
		return nil;
	}
	if (combinedNumber+row+1-1 >= [songCollection count]){
		NSLog(@"Outofbounds songCollection:MusicSongListTableViewCell:%d %lu",combinedNumber+row+1-1,(unsigned long)[songCollection count]);
		return nil;
	}

	MPConcreteMediaItem *songEntity = [songCollection objectAtIndex: combinedNumber+row+1-1];
	return songEntity;
}


- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 {
	id result = %orig;


	// Only hook if it is current class, not subclass
	Class $MusicSearchTableViewCell = objc_getClass("MusicSearchTableViewCell");
	if ([self isKindOfClass:[$MusicSearchTableViewCell class]]) {
		return result;
	}

	/*NSString *cellType = [self reuseIdentifier];

	if (!([cellType isEqualToString:@"MusicSongListCellConfiguration"]
		|| [cellType isEqualToString:@"MusicPlaylistSongCellConfiguration"])) {
		return result;
	}*/
	[self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	// UITableViewCellAccessoryDetailDisclosureButton is 2
	// UITableViewCellAccessoryDetailButton is 4


	UIButton * infoButton = [self getDetailButton:self];
	if (! infoButton) {
		NSLog(@"MusicSongListTableViewCell accessory button not made!");
	}

	[infoButton addTarget:self
	action:@selector(displayPopup:)
	forControlEvents:UIControlEventTouchDown];
	//UIControlEventTouchDown is 1
	//UIControlEventTouchUpInside is 64, but doesn't work, maybe absorbed by other Gesture Recognizers?

	return result;
}

%end

%hook MusicSearchTableViewCell

- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 {
	id result = %orig;

	NSString *cellType = [self reuseIdentifier];

	if (!([cellType isEqualToString:@"MusicSearchSongCellConfiguration"])) {
		return result;
	}

	[self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];

	UIButton * infoButton = [self getDetailButton:self];
	if (! infoButton) {
		NSLog(@"MusicSearchTableViewCell accessory button not made!");
	}

	[infoButton addTarget:self
	action:@selector(displayPopup:)
	forControlEvents:UIControlEventTouchDown];

	return result;
}

%new
- (id) getMediaItem:(UITableViewCell*)cell {
	// Table View
	MusicSearchTableView *tableView = [self getTableView:self];
	if (!tableView) {
		NSLog(@"Did not get tableView:MusicSearchTableViewCell.");
		return nil;
	}

	// Table's View Controller
	MusicSearchViewController *controller =  [tableView delegate];  // or [tableView dataSource];
	if (!controller) {
		NSLog(@"Did not get controller:MusicSearchTableViewCell.");
		return nil;
	}

	// Want to get cell's position in Table View, which can then be used as an index
	NSIndexPath *cellPosition = [tableView indexPathForCell:self];
	if (!cellPosition) {
		NSLog(@"Did not get cellPosition:MusicSearchTableViewCell.");
		return nil;
	}
	//int section = cellPosition.section;
	int row = cellPosition.row;

	//This represents the search results for the sections (Albums, artists, songs, etc)
	//  that are NON-EMPTY (i.e. something actually found)
	NSArray *searchResults = MSHookIvar<NSArray*>(controller, "_nonEmptySearchDataSources");

	if (!searchResults) {
		NSLog(@"Did not get searchResults:MusicSearchTableViewCell.");
		return nil;
	}

	// This contains the search query data
	MPUSearchDataSource *resultWeWant;

	for (MPUSearchDataSource *element in searchResults) {
		if ([[element query] groupingType] == 0) {//MPMediaGroupingTitle = 0
			resultWeWant = element;
			break;
		}
	}

	if (!resultWeWant) {
		NSLog(@"Did not get resultWeWant:MusicSearchTableViewCell.");
		return nil;
	}

	NSArray *songMediaItemList = resultWeWant.query.items;

	if (!songMediaItemList) {
		NSLog(@"Did not get songMediaItemList:MusicSongListTableViewCell.");
		return nil;
	}
	if (row >= [songMediaItemList count]){
		NSLog(@"Outofbounds songMediaItemList:MusicSearchTableViewCell:%d %lu",row,(unsigned long)[songMediaItemList count]);
		return nil;
	}

	MPConcreteMediaItem *songEntity = [songMediaItemList objectAtIndex: row];
	return songEntity;
}
%end

%hook MusicNowPlayingViewController

%new
- (BOOL)isLoaded {
	NSNumber * _isLoaded = objc_getAssociatedObject(self, @selector(isLoaded));
	return _isLoaded ? [_isLoaded boolValue] : NO;
}

%new
- (void)setLoaded:(BOOL)value {
	objc_setAssociatedObject(self, @selector(isLoaded), @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)viewDidAppear:(BOOL)animated {
	%orig;
	[self setLoaded:YES]; // So future addButtonToView calls are allowed

	UINavigationItem *navigationItem = [self navigationItem];
	UINavigationBar *bar = [navigationItem navigationBar];
	UIView *label = navigationItem.titleView;

	[label removeFromSuperview];

	UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,22)];
	navigationItem.titleView = newView;

	CGRect oldLabelFrame = label.frame;
	CGRect newLabelFrame = CGRectMake (oldLabelFrame.origin.x /*- oldLabelFrame.size.width/2*/ -(bar.frame.size.width)/2, oldLabelFrame.origin.y-(bar.frame.size.height/2), oldLabelFrame.size.width, oldLabelFrame.size.height);
	 newLabelFrame = CGRectMake (160, 0, oldLabelFrame.size.width, oldLabelFrame.size.height);

	label.frame = newLabelFrame;

	UIButton *button = [UIButton buttonWithType:2];
	button.frame = CGRectMake  (button.frame.origin.x /*-(button.frame.size.width)/2*/ -(bar.frame.size.width)/2 + oldLabelFrame.origin.x + oldLabelFrame.size.width + bar.frame.size.width/32, button.frame.origin.y-(button.frame.size.height/2), button.frame.size.width, button.frame.size.height);
	button.frame = CGRectMake  (0,0, button.frame.size.width, button.frame.size.height);

	[navigationItem.titleView addSubview:label];
	[navigationItem.titleView addSubview:button];

	button.tag = 22096;

	[button addTarget:self
	action:@selector(displayPopup:)
	forControlEvents:UIControlEventTouchDown];
}

%new
-(void) addButtonToView {
	UINavigationItem *navigationItem = [self navigationItem];
	UINavigationBar *bar = [navigationItem navigationBar];

	UIView *label = navigationItem.titleView;

	if (![self isLoaded] || ![label isKindOfClass:[UILabel class]]) {
		return;
	}

	[label removeFromSuperview];

	UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0,0,160,22)];
	navigationItem.titleView = newView;

	CGRect oldLabelFrame = label.frame;
	CGRect newLabelFrame = CGRectMake (oldLabelFrame.origin.x /*- oldLabelFrame.size.width/2*/ -(bar.frame.size.width)/2, oldLabelFrame.origin.y-(bar.frame.size.height/2), oldLabelFrame.size.width, oldLabelFrame.size.height);
	label.frame = newLabelFrame;

	UIButton *button = [UIButton buttonWithType:2];
	button.frame = CGRectMake (button.frame.origin.x /*-(button.frame.size.width)/2*/ -(bar.frame.size.width)/2 + oldLabelFrame.origin.x + oldLabelFrame.size.width + bar.frame.size.width/32, button.frame.origin.y-(button.frame.size.height/2), button.frame.size.width, button.frame.size.height);

	[navigationItem.titleView addSubview:label];
	[navigationItem.titleView addSubview:button];

	button.tag = 22096;

	[button addTarget:self
	action:@selector(displayPopup:)
	forControlEvents:UIControlEventTouchDown];
}

%new
- (id) getMediaItem:(UIViewController*)view {
	MPAVItem *item = MSHookIvar<MPAVItem*>(self, "_item");
	MPConcreteMediaItem *mediaItem = [item mediaItem];
	return mediaItem;
}

%new
- (AudioFileID) getAudioFileID:(ExtAudioFileRef)fileRef {
	OSStatus status;
	AudioFileID result = NULL;

	UInt32 size = sizeof(result);
	status = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_AudioFile, &size, &result);
	assert(status == noErr);

	return result;
}

%new
- (UInt32) getBitRate:(AudioFileID)audioFileId {
	OSStatus status;
	UInt32 result = 0;

	UInt32 size = sizeof(result);
	status = AudioFileGetProperty(audioFileId, kAudioFilePropertyBitRate, &size, &result);
	assert(status == noErr);

	return result;
}

%new
-(void) displayPopup: (UIButton*) sender {
	if ([[sender class] isSubclassOfClass:[UIButton class]]){

		MPConcreteMediaItem *songEntity = [self getMediaItem:self];
		if (!songEntity) {
			NSLog(@"Did not get songEntity.");
			return;
		}

		//NSLog(@"%@\n",[songEntity title]);

		NSURL *assetURL = [songEntity assetURL];
		AVAssetTrack *audioTrack;
		UInt32 bitRate;
		if (assetURL){
			AVURLAsset *asset = [AVAsset assetWithURL:assetURL];

			NSArray *audioTracks = [asset tracksWithMediaType:@"soun"]; // AVMediaTypeAudio=@"soun"

			audioTrack = [audioTracks objectAtIndex:0];

			//float bitRate = [audioTrack estimatedDataRate];
			//int sampleRate = [audioTrack naturalTimeScale];


			// Found here:
			//https://stackoverflow.com/questions/23241957/how-to-get-the-bit-rate-of-existing-mp3-or-aac-in-ios
			ExtAudioFileRef extAudioFileRef;
			OSStatus result = noErr;
			result = ExtAudioFileOpenURL((__bridge CFURLRef) assetURL, &extAudioFileRef);

			AudioFileID audioFileId = [self getAudioFileID:extAudioFileRef];;
			bitRate = [self getBitRate:audioFileId];
		} else {
			audioTrack = nil;
			bitRate = 0;
		}


		// Entire string:
		NSString *info = [NSString stringWithFormat:@"Title: %@\nArtist: %@\nAlbum Artist: %@\nComposer: %@\nGenre: %@\nYear: %llu\nRelease Date: %@\nComments: %@\nPlay Count: %llu\nSkip Count: %llu\nPlays Since Sync: %llu\nSkips Since Sync: %llu\nLast Played: %@\nBitrate: %dkbps\nSample Rate: %dHz",
		[songEntity title],
		[songEntity artist],
		[songEntity albumArtist],
		[songEntity composer],
		[songEntity genre],
		[songEntity year],
		[[songEntity releaseDate] dateWithCalendarFormat:@"%Y-%m-%d" timeZone:nil],
		[songEntity comments],
		[songEntity playCount],
		[songEntity skipCount],
		[songEntity playCountSinceSync],
		[songEntity skipCountSinceSync],
		[[songEntity lastPlayedDate] dateWithCalendarFormat:@"%Y-%m-%d" timeZone:nil],
		//(int)[audioTrack estimatedDataRate]/1000 ,// bitrate, but only works for AAC files (i.e. .m4a extension)
		(int)bitRate/1000,
		[audioTrack naturalTimeScale]]; //sampleRate

		UIAlertView *alertView = [[UIAlertView alloc]
		initWithTitle:@"Song Metadata"
		message:info
		delegate:self
		cancelButtonTitle:@"Done"
		otherButtonTitles:nil];

		[alertView show];
	} else {
		NSLog(@"Sender is not a UITableViewCell??");
	}
}


%end


%hook MusicNowPlayingPlaybackControlsView

-(void)reloadView {

	%orig;

	[self.delegate addButtonToView];

	bool hasInfoButton = false;
	for (UIView *subview in self.subviews)
	{
		if (subview.tag == 22096) {
			hasInfoButton = true;
		}
	}
	if (hasInfoButton){ //Don't add duplicate buttons
		return;
	}



	MPUNowPlayingTitlesView * titlesView = MSHookIvar<MPUNowPlayingTitlesView*>(self, "_titlesView");
	if (!titlesView) {
		return;
	}

	CGRect titleFrame = [titlesView frame];

	UIButton *infoButton = [UIButton buttonWithType:2]; //UIButtonTypeDetailDisclosure=2
	CGFloat buttonSize = [infoButton frame].size.width;

	CGFloat x = (int)([self frame].size.width * 7 / 8);
	CGFloat y = (int)(titleFrame.origin.y + ((titleFrame.size.height - buttonSize)/2));
	CGRect buttonFrame = CGRectMake(x,y,buttonSize,buttonSize);

	infoButton.frame=buttonFrame;

	infoButton.tag = 22096;

	[self addSubview:infoButton];

	[infoButton addTarget:self.delegate
	action:@selector(displayPopup:)
	forControlEvents:UIControlEventTouchDown];
}


%end
