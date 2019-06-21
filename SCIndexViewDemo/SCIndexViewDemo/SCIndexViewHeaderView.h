//
//  SCIndexViewHeaderView.h
//  SCIndexViewDemo
//
//  Created by JMS on 2019/6/21.
//  Copyright © 2019 SC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCIndexViewHeaderView : UITableViewHeaderFooterView

+ (CGFloat)headerViewHeight;
+ (NSString *)reuseID;

- (void)configWithTitle:(NSString *)title;
- (void)configWithProgress:(double)progress;

@end

NS_ASSUME_NONNULL_END
