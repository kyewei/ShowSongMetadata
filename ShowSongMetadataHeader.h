/*
 * ShowSongMetadata
 * ShowSongMetadataHeader.h
 *
 * 2015 Kye Wei
*/

#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetTrack.h>
#import <AudioToolbox/AudioToolbox.h>

@protocol MusicTableViewDelegate <UITableViewDelegate>
@end


@interface MusicTableView : UITableView {
    NSMutableDictionary *_cellClassDict;
}
@property (assign,nonatomic) id/*<MusicTableViewDelegate>*/ delegate;
@end

@interface UISearchResultsTableView : UITableView
@property (assign,nonatomic) id/*<MusicSearchTableViewDelegate>*/ delegate;
@end

@interface MusicSearchTableView : UISearchResultsTableView
@end



@interface MPUDataSourceViewController : UIViewController
@end
@interface MPUTableViewController : MPUDataSourceViewController
@end
@interface MusicTableViewController : MPUTableViewController
@property (weak) id /*<MusicTableViewControllerDelegate>*/ delegate;
@property (weak) id /*<MusicTableViewControllerDelegate>*/ dataSource; //I know this exists so...
@end
@interface MusicAlbumsDetailViewController : MusicTableViewController <MusicTableViewDelegate>
@end

@interface MusicSongsViewController : MusicTableViewController <MusicTableViewDelegate>
@end

@interface UITableViewCellDetailDisclosureView : UIControl {
    UIButton *_infoButton;
}
@property(retain) UIButton *infoButton;
@end

@interface MusicSearchViewController : UIViewController
@property (weak) id /*<MusicSearchViewControllerDelegate>*/ delegate;
@property (weak) id /*<MusicSearchViewControllerDelegate>*/ dataSource; //I know this exists so...
@end

@interface MPMediaQuery : NSObject
@property (nonatomic,readonly) NSArray * items;
@property (nonatomic,readonly) NSArray * collections;
@property (nonatomic,readonly) NSArray * itemSections;
@property (nonatomic,readonly) NSArray * collectionSections;
-(int)groupingType;
@end

@interface MPUDataSource : NSObject
@end
@interface MPUQueryDataSource : MPUDataSource
@end
@interface MPUCompletionQueryDataSource : MPUQueryDataSource
@end
@interface MusicQueryDataSource : MPUCompletionQueryDataSource {
    MPMediaQuery* _query;
}
- (id)entities;
@end
@interface MusicArtistAlbumsDataSource : MusicQueryDataSource {
    NSArray *_sectionEntities;
}
- (id)sectionEntities;
@end
@interface MusicSongsDataSource : MusicQueryDataSource
@end

@interface MPUSearchDataSource : MPUQueryDataSource
@property (nonatomic,readonly) MPMediaQuery * query;
-(MPMediaQuery *)query;
@end

@interface MPMediaEntity : NSObject
@end
@interface MPMediaItem : MPMediaEntity
@property (nonatomic,readonly) NSString * title;
@property (nonatomic,readonly) NSString * albumTitle;
@property (nonatomic,readonly) NSString * artist;
@property (nonatomic,readonly) NSString * albumArtist;
@property (nonatomic,readonly) NSString * genre;
@property (nonatomic,readonly) NSString * composer;
@property (nonatomic,readonly) NSString * comments;
@property (nonatomic,readonly) NSDate * releaseDate;
@property (nonatomic,readonly) double playbackDuration;
@property (nonatomic,readonly) unsigned long long albumTrackNumber;
@property (nonatomic,readonly) unsigned long long albumTrackCount;
@property (nonatomic,readonly) unsigned long long discNumber;
@property (nonatomic,readonly) unsigned long long discCount;
@property (nonatomic,readonly) unsigned long long playCount;
@property (nonatomic,readonly) unsigned long long skipCount;
@property (nonatomic,readonly) unsigned long long year;
@property (nonatomic,readonly) unsigned long long rating;
@property (nonatomic,copy) NSDate * lastPlayedDate;
@property (nonatomic,copy) NSDate * lastSkippedDate;
@property (assign,nonatomic) unsigned long long playCountSinceSync;
@property (assign,nonatomic) unsigned long long skipCountSinceSync;
@property (nonatomic,readonly) NSURL * assetURL;
@end

@interface MPConcreteMediaItem : MPMediaItem
@end

@interface MPMediaItemCollection : MPMediaEntity
@end
@interface MPConcreteMediaItemCollection : MPMediaItemCollection
- (id)items;
@end

@interface MusicTableViewCell : UITableViewCell
- (id) getDetailButton:(UITableViewCell*)cell;
- (id) getTableView:(UITableViewCell*) cell;
- (void) displayPopup: (UIButton*) sender;
- (id) getMediaItem:(UITableViewCell*)cell; // To get rid of compiler warnings
- (AudioFileID) getAudioFileID:(ExtAudioFileRef)fileRef;
- (UInt32) getBitRate:(AudioFileID)audioFileId;
@end

@interface MusicMediaTableViewCell : MusicTableViewCell
@end

@interface MusicCollectionTrackTableViewCell : MusicMediaTableViewCell {
    //UIControl *_accessoryView;
}
@property(retain, nonatomic) UIView *accessoryView;
- (id) getMediaItem:(UITableViewCell*)cell;
@end
@interface MusicStandardMediaTableViewCell : MusicMediaTableViewCell
@end
@interface MusicSongListTableViewCell : MusicStandardMediaTableViewCell
- (int) rowsBeforeSection:(int)section inTable:(UITableView*)tableView;
@end

@interface MusicSearchTableViewCell : MusicSongListTableViewCell
- (id) getMediaItem:(UITableViewCell*)cell;
@end


/*@interface MusicActionTableViewCell : MusicTableViewCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2;
@end;*/
@interface NSDate (KWExtensions)
// I know this exists too, I used it
- (id)dateWithCalendarFormat:(NSString *)formatString timeZone:(NSTimeZone *)timeZone;
@end



@interface MPAVItem : NSObject {
    MPMediaItem* _mediaItem;
}
@property (nonatomic,retain,readonly) MPMediaItem * mediaItem;
- (id) mediaItem;
@end

@interface MusicNowPlayingViewController : UIViewController {
    MPAVItem* _item;
    //UINavigationItem* _navigationItem;
}
@property (nonatomic,retain,readonly) UINavigationItem * navigationItem;
- (BOOL)isLoaded;
- (void)setLoaded:(BOOL)value;
-(UINavigationItem *)navigationItem;
-(void)viewDidLoad;
-(void)viewDidAppear:(BOOL)animated;
-(void)viewDidDisappear:(BOOL)animated;
-(void)didMoveToWindow;
-(void) addButtonToView;

- (AudioFileID) getAudioFileID:(ExtAudioFileRef)fileRef;
- (UInt32) getBitRate:(AudioFileID)audioFileId;
- (id) getMediaItem:(UIViewController*)view;
-(void) displayPopup: (UIButton*) sender;


@end


@interface MPUNowPlayingTitlesView : UIView
@property(nonatomic) CGRect frame;
-(id)initWithFrame:(CGRect)arg1 ;
@end

@interface MusicNowPlayingPlaybackControlsView : UIView {
    UIView* _titlesView;
}

//- (AudioFileID) getAudioFileID:(ExtAudioFileRef)fileRef;
//- (UInt32) getBitRate:(AudioFileID)audioFileId;
//- (id) getMediaItem:(UIView*)view;
//-(void) displayPopup: (UIButton*) sender;
@property(nonatomic) CGRect frame;
@property (assign,nonatomic) id delegate;
-(void)reloadView;
-(id)initWithFrame:(CGRect)arg1 ;
@end

@interface UINavigationItem (KWExtensions)
-(id)navigationBar;
@end
