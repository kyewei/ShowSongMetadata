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
