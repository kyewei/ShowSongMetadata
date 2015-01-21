@protocol MusicTableViewDelegate <UITableViewDelegate>
@end


@interface MusicTableView : UITableView {
    NSMutableDictionary *_cellClassDict;
}
@property (assign,nonatomic) id/*<MusicTableViewDelegate>*/ delegate;
@end

@interface MPUDataSourceViewController : UIViewController
@end
@interface MPUTableViewController : MPUDataSourceViewController
@end
@interface MusicTableViewController : MPUTableViewController
@property (weak) id /*<MusicTableViewControllerDelegate>*/ delegate;
@end
@interface MusicAlbumsDetailViewController : MusicTableViewController <MusicTableViewDelegate>
@property (weak) id /*<MusicTableViewControllerDelegate>*/ dataSource; //I know this exists so...
@end

@interface UITableViewCellDetailDisclosureView : UIControl {
    UIButton *_infoButton;
}
@property(retain) UIButton *infoButton;
@end

@interface MPUDataSource : NSObject
@end
@interface MPUQueryDataSource : MPUDataSource
@end
@interface MPUCompletionQueryDataSource : MPUQueryDataSource
@end
@interface MusicQueryDataSource : MPUCompletionQueryDataSource
@end
@interface MusicArtistAlbumsDataSource : MusicQueryDataSource {
    NSArray *_sectionEntities;
}
- (id)sectionEntities;
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

@end
@interface MPConcreteMediaItem : MPMediaItem
@end

@interface MPMediaItemCollection : MPMediaEntity
@end
@interface MPConcreteMediaItemCollection : MPMediaItemCollection
- (id)items;
@end

@interface MusicTableViewCell : UITableViewCell
@end

@interface MusicMediaTableViewCell : MusicTableViewCell
@end

@interface MusicCollectionTrackTableViewCell : MusicMediaTableViewCell {
    UIControl *_accessoryView;
}
@property(retain, nonatomic) UIView *accessoryView;
- (id) getDetailButton:(MusicCollectionTrackTableViewCell*)cell;
- (id) getTableView:(UITableViewCell*) cell;
@end


/*@interface MusicActionTableViewCell : MusicTableViewCell
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2;
@end;*/
@interface NSDate (KWExtensions)
// I know this exists too, I used it
- (id)dateWithCalendarFormat:(NSString *)formatString timeZone:(NSTimeZone *)timeZone;
@end
