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
		AVURLAsset *asset = [AVAsset assetWithURL:assetURL];

		NSArray *audioTracks = [asset tracksWithMediaType:@"soun"]; // AVMediaTypeAudio=@"soun"

		AVAssetTrack *audioTrack = [audioTracks objectAtIndex:0];

		//float bitRate = [audioTrack estimatedDataRate];
		//int sampleRate = [audioTrack naturalTimeScale];


		// Found here:
		//https://stackoverflow.com/questions/23241957/how-to-get-the-bit-rate-of-existing-mp3-or-aac-in-ios
		ExtAudioFileRef extAudioFileRef;
		OSStatus result = noErr;
		result = ExtAudioFileOpenURL((__bridge CFURLRef) assetURL, &extAudioFileRef);

		AudioFileID audioFileId = [self getAudioFileID:extAudioFileRef];;
		UInt32 bitRate = [self getBitRate:audioFileId];


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
	if (checkCell && [checkCell isKindOfClass:[self class]] == YES) {
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
