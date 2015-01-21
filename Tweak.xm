
#import "ShowSongMetadataHeader.h"


%hook MusicCollectionTrackTableViewCell

%new
-(void) displayPopup: (UIButton*) sender {
	if ([[sender class] isSubclassOfClass:[UIButton class]]){

		// Table View
		MusicTableView *tableView = [self getTableView:self];
		// Table's View Controller
		MusicAlbumsDetailViewController *controller =  [tableView delegate];  // or [tableView dataSource];

		// Want to get cell's position in Table View, which can then be used as an index
		NSIndexPath *cellPosition = [tableView indexPathForCell:self];
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

		NSArray *mediaEntities = [dataSource sectionEntities];
		//NSLog(@"%mediaEntities: length %d\n",[mediaEntities count]);

		MPConcreteMediaItemCollection *sectionCollection = [mediaEntities objectAtIndex: section];
		NSArray *songCollection = [sectionCollection items];
		MPConcreteMediaItem *songEntity = [songCollection objectAtIndex: row];

		NSLog(@"%@\n",[songEntity title]);

		//sample info for now

		UIAlertView *alertView = [[UIAlertView alloc]
		initWithTitle:@"Song Metadata"
		message:@"Title: Feeling Good\nArtist: Michael Buble\nYear: 2005\nCopyright: 2005 Reprise Records\n"
		delegate:self
		cancelButtonTitle:@"Done"
		otherButtonTitles:nil];

		[alertView show];
	} else {
		NSLog(@"Sender is not a UITableViewCell??");
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

%new
- (id)getTableView:(UITableViewCell*) cell {
	id view = [cell superview];
	while (view && [view isKindOfClass:[UITableView class]] == NO) {
		view = [view superview];
	}
	UITableView *tableView = (UITableView *)view;
	return tableView;
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
