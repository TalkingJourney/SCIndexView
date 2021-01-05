
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCIndexViewHeaderView : UITableViewHeaderFooterView

+ (CGFloat)headerViewHeight;
+ (NSString *)reuseID;

- (void)configWithTitle:(NSString *)title;
- (void)configWithProgress:(double)progress;

@end

NS_ASSUME_NONNULL_END
