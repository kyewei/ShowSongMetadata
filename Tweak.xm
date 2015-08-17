/*
 * ShowSongMetadata
 * Tweak.xm
 *
 * 2015 Kye Wei
*/

#import "ShowSongMetadataHeader.h"
#define settingsPath @"/User/Library/Preferences/com.kyewei.showsongmetadata.plist"

static BOOL tweakEnabled = YES;
static BOOL songButtonEnabled = YES;
static BOOL nowPlayingEnabled = YES;

static BOOL hideNull = YES;

static BOOL showTitle = YES;
static BOOL showArtist = YES;
static BOOL showAlbumArtist = YES;
static BOOL showComposer = YES;
static BOOL showGenre = YES;
static BOOL showYear = YES;
static BOOL showReleaseDate = YES;
static BOOL showComments = YES;
static BOOL showPlayCount = YES;
static BOOL showSkipCount = YES;
static BOOL showPlaysSinceSync = YES;
static BOOL showSkipsSinceSync = YES;
static BOOL showLastPlayed = YES;
static BOOL showBitrate = YES;
static BOOL showSampleRate = YES;


static void updatePrefs() {
	NSDictionary *tweakSettings = [NSDictionary dictionaryWithContentsOfFile:settingsPath];

	if (!tweakSettings){
		return;
	}

	// Entire tweak enable/disable
	NSNumber *tweakEnabledNum = tweakSettings[@"tweakEnabled"];
	tweakEnabled = tweakEnabledNum ? [tweakEnabledNum boolValue] : 1;

	// Song list cell button enable/disable
	NSNumber *songButtonEnabledNum = tweakSettings[@"songButtonEnabled"];
	songButtonEnabled = songButtonEnabledNum ? [songButtonEnabledNum boolValue] : 1;

	// Now Playing button enable/disable
	NSNumber *nowPlayingEnabledNum = tweakSettings[@"nowPlayingEnabled"];
	nowPlayingEnabled = nowPlayingEnabledNum ? [nowPlayingEnabledNum boolValue] : 1;

	// Hide "nil"
	NSNumber *hideNullNum = tweakSettings[@"hideNull"];
	hideNull = hideNullNum ? [hideNullNum boolValue] : 1;


	//Metadata to show
	NSNumber *showTitleNum = tweakSettings[@"showTitle"];
	showTitle = showTitleNum ? [showTitleNum boolValue] : 1;
	NSNumber *showArtistNum = tweakSettings[@"showArtist"];
	showArtist = showArtistNum ? [showArtistNum boolValue] : 1;
	NSNumber *showAlbumArtistNum = tweakSettings[@"showAlbumArtist"];
	showAlbumArtist = showAlbumArtistNum ? [showAlbumArtistNum boolValue] : 1;
	NSNumber *showComposerNum = tweakSettings[@"showComposer"];
	showComposer = showComposerNum ? [showComposerNum boolValue] : 1;
	NSNumber *showGenreNum = tweakSettings[@"showGenre"];
	showGenre = showGenreNum ? [showGenreNum boolValue] : 1;
	NSNumber *showYearNum = tweakSettings[@"showYear"];
	showYear = showYearNum ? [showYearNum boolValue] : 1;
	NSNumber *showReleaseDateNum = tweakSettings[@"showReleaseDate"];
	showReleaseDate = showReleaseDateNum ? [showReleaseDateNum boolValue] : 1;
	NSNumber *showCommentsNum = tweakSettings[@"showComments"];
	showComments = showCommentsNum ? [showCommentsNum boolValue] : 1;
	NSNumber *showPlayCountNum = tweakSettings[@"showPlayCount"];
	showPlayCount = showPlayCountNum ? [showPlayCountNum boolValue] : 1;
	NSNumber *showSkipCountNum = tweakSettings[@"showSkipCount"];
	showSkipCount = showSkipCountNum ? [showSkipCountNum boolValue] : 1;
	NSNumber *showPlaysSinceSyncNum = tweakSettings[@"showPlaysSinceSync"];
	showPlaysSinceSync = showPlaysSinceSyncNum ? [showPlaysSinceSyncNum boolValue] : 1;
	NSNumber *showSkipsSinceSyncNum = tweakSettings[@"showSkipsSinceSync"];
	showSkipsSinceSync = showSkipsSinceSyncNum ? [showSkipsSinceSyncNum boolValue] : 1;
	NSNumber *showLastPlayedNum = tweakSettings[@"showLastPlayed"];
	showLastPlayed = showLastPlayedNum ? [showLastPlayedNum boolValue] : 1;
	NSNumber *showBitrateNum = tweakSettings[@"showBitrate"];
	showBitrate = showBitrateNum ? [showBitrateNum boolValue] : 1;
	NSNumber *showSampleRateNum = tweakSettings[@"showSampleRate"];
	showSampleRate = showSampleRateNum ? [showSampleRateNum boolValue] : 1;
}

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
									NULL,
									(CFNotificationCallback)updatePrefs,
									CFSTR("com.kyewei.showsongmetadata/settingschanged"),
									NULL, CFNotificationSuspensionBehaviorCoalesce);
	updatePrefs();
}


static AudioFileID getAudioFileID(ExtAudioFileRef fileRef) {
	OSStatus status;
	AudioFileID result = NULL;

	UInt32 size = sizeof(result);
	status = ExtAudioFileGetProperty(fileRef, kExtAudioFileProperty_AudioFile, &size, &result);
	assert(status == noErr);

	return result;
}

static UInt32 getBitRate(AudioFileID audioFileId) {
	OSStatus status;
	UInt32 result = 0;

	UInt32 size = sizeof(result);
	status = AudioFileGetProperty(audioFileId, kAudioFilePropertyBitRate, &size, &result);
	assert(status == noErr);

	return result;
}

void showPopup (MPConcreteMediaItem *songEntity) {

	NSURL *assetURL = [songEntity assetURL];
	AVAssetTrack *audioTrack;
	UInt32 bitRate;
	if (assetURL){
		AVURLAsset *asset = [AVAsset assetWithURL:assetURL];

		NSArray *audioTracks = [asset tracksWithMediaType:@"soun"]; // AVMediaTypeAudio=@"soun"

		if (!audioTracks || 1 > [audioTracks count]){
			NSLog(@"showPopup audioTracks:MPConcreteMediaItem:%d %lu",0,(unsigned long)[audioTracks count]);
			return;
		}

		audioTrack = [audioTracks objectAtIndex:0];

		//float bitRate = [audioTrack estimatedDataRate];
		//int sampleRate = [audioTrack naturalTimeScale];


		// Found here:
		//https://stackoverflow.com/questions/23241957/how-to-get-the-bit-rate-of-existing-mp3-or-aac-in-ios
		ExtAudioFileRef extAudioFileRef;
		OSStatus result = noErr;
		result = ExtAudioFileOpenURL((__bridge CFURLRef) assetURL, &extAudioFileRef);

		AudioFileID audioFileId = getAudioFileID(extAudioFileRef);
		bitRate = getBitRate(audioFileId);
	} else {
		audioTrack = nil;
		bitRate = 0;
	}

	// Entire string:
	NSString *info = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@%@%@",
	showTitle && (!hideNull || [songEntity title]) ? [NSString stringWithFormat:@"Title: %@\n", [songEntity title]] : @"",
	showArtist && (!hideNull || [songEntity artist]) ? [NSString stringWithFormat:@"Artist: %@\n", [songEntity artist]] : @"",
	showAlbumArtist && (!hideNull || [songEntity albumArtist]) ? [NSString stringWithFormat:@"Album Artist: %@\n", [songEntity albumArtist]] : @"",
	showComposer && (!hideNull || [songEntity composer]) ? [NSString stringWithFormat:@"Composer: %@\n", [songEntity composer]] : @"",
	showGenre && (!hideNull || [songEntity genre]) ? [NSString stringWithFormat:@"Genre: %@\n", [songEntity genre]] : @"",
	showYear && (!hideNull || [songEntity year]) ? [NSString stringWithFormat:@"Year: %llu\n", [songEntity year]] : @"",
	showReleaseDate && (!hideNull || [songEntity releaseDate]) ? [NSString stringWithFormat:@"Release Date: %@\n", [[songEntity releaseDate] dateWithCalendarFormat:@"%Y-%m-%d" timeZone:nil]] : @"",
	showComments && (!hideNull || [songEntity comments]) ? [NSString stringWithFormat:@"Comments: %@\n", [songEntity comments]] : @"",
	showPlayCount && (!hideNull || [songEntity playCount]) ? [NSString stringWithFormat:@"Play Count: %llu\n", [songEntity playCount]] : @"",
	showSkipCount && (!hideNull || [songEntity skipCount]) ? [NSString stringWithFormat:@"Skip Count: %llu\n", [songEntity skipCount]] : @"",
	showPlaysSinceSync && (!hideNull || [songEntity playCountSinceSync]) ? [NSString stringWithFormat:@"Plays Since Sync: %llu\n", [songEntity playCountSinceSync]] : @"",
	showSkipsSinceSync && (!hideNull || [songEntity skipCountSinceSync]) ? [NSString stringWithFormat:@"Skips Since Sync: %llu\n", [songEntity skipCountSinceSync]] : @"",
	showLastPlayed && (!hideNull || [songEntity lastPlayedDate]) ? [NSString stringWithFormat:@"Last Played: %@\n", [[songEntity lastPlayedDate] dateWithCalendarFormat:@"%Y-%m-%d" timeZone:nil]] : @"",
	//(int)[audioTrack estimatedDataRate]/1000 ,// bitrate, but only works for AAC files (i.e. .m4a extension)
	showBitrate ? [NSString stringWithFormat:@"Bitrate: %dkbps\n", (int)bitRate/1000] : @"",
	showSampleRate ? [NSString stringWithFormat:@"Sample Rate: %dHz\n", [audioTrack naturalTimeScale]] : @""]; //sampleRate

	UIAlertView *alertView = [[UIAlertView alloc]
	initWithTitle:@"Song Metadata"
	message:[info stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
	delegate:nil
	cancelButtonTitle:@"Done"
	otherButtonTitles:nil];

	[alertView show];
	[alertView release];
}

/*%hook UITapGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	BOOL a = touch.view.tag==22096;
	if (a) {
		return NO;
	}
	//return %orig;
	return NO;
}
%end

%hook UIGestureRecognizer
-(id)initWithTarget:(id)arg1 action:(SEL)arg2 {
	id result = %orig;

	[self setCancelsTouchesInView:NO];
	return result;
}
- (BOOL)cancelsTouchesInView
{
	return NO;
}
%end*/

UIButton *getDetailButton(UITableViewCell *cell) {
	UITableViewCellDetailDisclosureView * disclosureView = MSHookIvar<UITableViewCellDetailDisclosureView*>(cell, "_accessoryView");
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

UITableView *getTableView(UITableViewCell *cell) {
	id view = [cell superview];
	while (view && [view isKindOfClass:[UITableView class]] == NO) {
		view = [view superview];
	}
	UITableView *tableView = (UITableView *)view;
	return tableView;
}

%hook MusicTableViewCell

%new
-(void) displayPopup: (UIButton*) sender {
	if ([[sender class] isSubclassOfClass:[UIButton class]]){

		MPConcreteMediaItem *songEntity = [self getMediaItem:self];
		if (!songEntity) {
			NSLog(@"Did not get songEntity.");
			return;
		}
		showPopup(songEntity);
	} else {
		NSLog(@"Sender is not a UIButton??");
	}
}
%end

%hook MusicCollectionTrackTableViewCell

%new
- (id) getMediaItem:(UITableViewCell*)cell {
	// Table View
	MusicTableView *tableView = (MusicTableView *)getTableView(self);
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
	/*NSString *type = MSHookIvar<NSString*>(checkCell, "_reuseIdentifier");
	if ([type isEqualToString:@"MusicShuffleActionCellConfiguration"]) {
		section--;
	}*/

	if (/*checkCell && */[checkCell isKindOfClass:[self class]] == YES
		|| [NSStringFromClass([self class]) isEqualToString:@"MusicFlipsideAlbumTrackTableViewCell"]) {
			// For some reason MusicFlipsideAlbumTrackTableViewCell's tableView's cellForRowAtIndexPath produces null..

		// It is not a shuffle cell, don't do anything
	} else {
		// Then the shuffle section exists, and we have an off-by-one error;
		//Fix:
		section--;
	}
	if (section<0)
		section=0;

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

	if (!(tweakEnabled && songButtonEnabled)) {
		return result;
	}

	/*NSString *cellType = [self reuseIdentifier];
	if (!([cellType isEqualToString:@"MusicAlbumTracksCellConfiguration"])) {
		return result;
	}*/

	[self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
	// UITableViewCellAccessoryDetailDisclosureButton is 2
	// UITableViewCellAccessoryDetailButton is 4


	UIButton * infoButton = getDetailButton(self);

	if (! infoButton) {
		NSLog(@"MusicCollectionTrackTableViewCell accessory button not made!");
	}
	infoButton.tag = 22096;

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
	MusicTableView *tableView = (MusicTableView *)getTableView(self);
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

	if (!(tweakEnabled && songButtonEnabled)) {
		return result;
	}

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


	UIButton * infoButton = getDetailButton(self);
	if (! infoButton) {
		NSLog(@"MusicSongListTableViewCell accessory button not made!");
	}
	infoButton.tag = 22096;

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

	if (!(tweakEnabled && songButtonEnabled)) {
		return result;
	}

	NSString *cellType = [self reuseIdentifier];

	if (!([cellType isEqualToString:@"MusicSearchSongCellConfiguration"])) {
		return result;
	}

	[self setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];

	UIButton * infoButton = getDetailButton(self);
	if (! infoButton) {
		NSLog(@"MusicSearchTableViewCell accessory button not made!");
	}
	infoButton.tag = 22096;

	[infoButton addTarget:self
	action:@selector(displayPopup:)
	forControlEvents:UIControlEventTouchDown];

	return result;
}

%new
- (id) getMediaItem:(UITableViewCell*)cell {
	// Table View
	MusicSearchTableView *tableView = (MusicSearchTableView *)getTableView(self);
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



%hook MusicProfileAlbumsViewController

-(void)viewDidAppear:(BOOL)animated {
	%orig;
	if (!(tweakEnabled && songButtonEnabled)) {
		return;
	}
	[self addButtonsToTableCells];
}

%end

%hook MusicProductTracklistTableViewController

-(void)viewDidAppear:(BOOL)animated {
	%orig;
	if (!(tweakEnabled && songButtonEnabled)) {
		return;
	}
	[self addButtonsToTableCells];
}

%end

%hook MusicLibraryBrowseTableViewController

-(void)viewDidAppear:(BOOL)animated {
	%orig;
	if (!(tweakEnabled && songButtonEnabled)) {
		return;
	}
	[self addButtonsToTableCells];
}

%new
-(void)addButtonsToTableCells {
	MusicTableView *tableView = [self tableView];
	for (MusicEntityTracklistItemTableViewCell *cell in tableView.visibleCells) {
    	MusicCoalescingEntityValueProvider *cp = [cell entityValueProvider];
		if ([NSStringFromClass([[cp baseEntityValueProvider] class]) isEqualToString:@"MPConcreteMediaItem"] &&
			cell.accessoryType !=UITableViewCellAccessoryDetailDisclosureButton) {

			[cell setAccessoryType:UITableViewCellAccessoryDetailDisclosureButton];
			UIButton * infoButton = getDetailButton(cell);
			if (!infoButton) {
				NSLog(@"MusicEntityTracklistItemTableViewCell accessory button not made!");
			}
			infoButton.tag = 22096;

			[infoButton addTarget:cell
			action:@selector(displayPopup:)
			forControlEvents:UIControlEventTouchDown];
		}
    }
}

%end



%hook MusicEntityTracklistItemTableViewCell
%new
-(void) displayPopup: (UIButton*) sender {
	if ([[sender class] isSubclassOfClass:[UIButton class]]){

		MPConcreteMediaItem *songEntity = [self getMediaItem:self];
		if (!songEntity) {
			NSLog(@"Did not get songEntity.");
			return;
		}
		showPopup(songEntity);
	} else {
		NSLog(@"Sender is not a UIButton??");
	}
}
// did not override -initWithStyle, I found a better way by overriding the ViewControllers
%new
- (id) getMediaItem:(UITableViewCell*)cell {
	// New iOS 8.4? SDK content, makes everything easier
	// Too bad it (probably?) doesn't work on earlier iOS

	MusicCoalescingEntityValueProvider *cp = [self entityValueProvider];
	if (![NSStringFromClass([[cp baseEntityValueProvider] class]) isEqualToString:@"MPConcreteMediaItem"] ) // make sure not shuffle tableviewcell
		return nil;
	MPConcreteMediaItem *songEntity = [cp baseEntityValueProvider];
	return songEntity;
}
%end
%hook MusicEntityHorizontalLockupTableViewCell
%new
-(void) displayPopup: (UIButton*) sender {
	if ([[sender class] isSubclassOfClass:[UIButton class]]){

		MPConcreteMediaItem *songEntity = [self getMediaItem:self];
		if (!songEntity) {
			NSLog(@"Did not get songEntity.");
			return;
		}
		showPopup(songEntity);
	} else {
		NSLog(@"Sender is not a UIButton??");
	}
}
%new
- (id) getMediaItem:(UITableViewCell*)cell {
	MusicCoalescingEntityValueProvider *cp = [self entityValueProvider];
	if (![NSStringFromClass([[cp baseEntityValueProvider] class]) isEqualToString:@"MPConcreteMediaItem"] )
		return nil;
	MPConcreteMediaItem *songEntity = [cp baseEntityValueProvider];
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

%new
- (float)titleWidthGap {
	NSNumber * _isLoaded = objc_getAssociatedObject(self, @selector(titleWidthGap));
	return [_isLoaded floatValue];
}

%new
- (void)setTitleWidthGap:(float)value {
	objc_setAssociatedObject(self, @selector(titleWidthGap), @(value), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)viewDidAppear:(BOOL)animated {
	%orig;
	[self setLoaded:YES]; // So future addButtonToView calls are allowed
	//NSLog(@"DISAPPLEAR");
	[self addButtonToView];
}

-(void)viewDidDisappear:(BOOL)animated {
	%orig;
	[self setLoaded:NO];
}


//float titleWidthGap=0;

%new
-(void) addButtonToView {

	if (!(tweakEnabled && nowPlayingEnabled)) {
		return;
	}

	UINavigationItem *navigationItem = [self navigationItem];
	UINavigationBar *bar = [navigationItem navigationBar];

	UIView *potentialLabel = navigationItem.titleView;
	UILabel *label;

	if (![self isLoaded] || ![potentialLabel isKindOfClass:[UILabel class]]) {
		return;
	} else {
		if (![potentialLabel isKindOfClass:[UILabel class]]){ // Is an UIView
			for (UIView * element in potentialLabel.subviews) {
				if ([element isKindOfClass:[UILabel class]]) {
					label = (UILabel*) element;
				} else if ([element isKindOfClass:[UIButton class]]) {
					[element removeFromSuperview];
				}
			}
			[potentialLabel removeFromSuperview];
		} else { // original label
			label = (UILabel*) potentialLabel;
		}
	}

	[label removeFromSuperview];

	UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0,0,bar.frame.size.width/2,22)];
	navigationItem.titleView = newView;

	CGRect oldLabelFrame = label.frame;
	CGRect newLabelFrame;

	if (oldLabelFrame.origin.x !=0)
		[self setTitleWidthGap: oldLabelFrame.origin.x];

	CGFloat xStart = [self titleWidthGap] - bar.frame.size.width/4; // centers title: half width of halved width view - 1/2 label width
	newLabelFrame = CGRectMake (xStart, 11- oldLabelFrame.size.height/2, oldLabelFrame.size.width, oldLabelFrame.size.height);
	label.frame = newLabelFrame;

	UIButton *button = [UIButton buttonWithType:2]; //UIButtonTypeDetailDisclosure=2
	button.frame = CGRectMake  ((int)(xStart + oldLabelFrame.size.width + 16),0 , button.frame.size.width, button.frame.size.height);

	[navigationItem.titleView addSubview:label];
	[navigationItem.titleView addSubview:button];
	button.tag = 22096;

	[button addTarget:self
	action:@selector(displayPopup:)
	forControlEvents:UIControlEventTouchUpInside];
}

%new
- (id) getMediaItem:(UIViewController*)view {
	MPAVItem *item = MSHookIvar<MPAVItem*>(self, "_item");
	MPConcreteMediaItem *mediaItem = [item mediaItem];
	return mediaItem;
}

%new
-(void) displayPopup: (UIButton*) sender {
	if ([[sender class] isSubclassOfClass:[UIButton class]]){

		MPConcreteMediaItem *songEntity = [self getMediaItem:self];
		if (!songEntity) {
			NSLog(@"Did not get songEntity.");
			return;
		}
		showPopup(songEntity);
	} else {
		NSLog(@"Sender is not a UIButton??");
	}
}
%end


%hook MusicNowPlayingPlaybackControlsView
-(void)reloadView {
	%orig;

	[self.delegate addButtonToView];
}
%end
