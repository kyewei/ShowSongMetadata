@interface UITableViewCellDetailDisclosureView : UIControl {
    UIButton *_infoButton;
}
@property(retain) UIButton * infoButton;
@end

@interface MusicTableViewCell : UITableViewCell
@end

@interface MusicMediaTableViewCell : MusicTableViewCell
@end

@interface MusicCollectionTrackTableViewCell : MusicMediaTableViewCell {
    UIView * _accessoryView;
}
@property(retain) UIView * accessoryView;
- (id) getDetailButton:(MusicCollectionTrackTableViewCell*)cell;
@end
