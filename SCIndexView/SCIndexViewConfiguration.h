
#import <UIKit/UIKit.h>

@interface SCIndexViewConfiguration : NSObject

@property (nonatomic, strong) UIColor *indicatorBackgroundColor;            // 指示器背景颜色
@property (nonatomic, strong) UIColor *indicatorTextColor;                  // 指示器文字颜色
@property (nonatomic, strong) UIFont *indicatorTextFont;                    // 指示器文字字体
@property (nonatomic, assign) CGFloat indicatorHeight;                      // 指示器高度
@property (nonatomic, assign) CGFloat indicatorRightMargin;                 // 指示器距离右边屏幕距离

@property (nonatomic, strong) UIColor *indexItemBackgroundColor;            // 索引元素背景颜色
@property (nonatomic, strong) UIColor *indexItemTextColor;                  // 索引元素文字颜色
@property (nonatomic, strong) UIColor *indexItemSelectedBackgroundColor;    // 索引元素选中时背景颜色
@property (nonatomic, strong) UIColor *indexItemSelectedTextColor;          // 索引元素选中时文字颜色
@property (nonatomic, assign) CGFloat indexItemHeight;                      // 索引元素高度
@property (nonatomic, assign) CGFloat indexItemRightMargin;                 // 索引元素距离右边屏幕距离
@property (nonatomic, assign) CGFloat indexItemsSpace;                      // 索引元素之间间隔距离

+ (instancetype)configuration;
+ (instancetype)configurationWithIndicatorBackgroundColor:(UIColor *)indicatorBackgroundColor
                                       indicatorTextColor:(UIColor *)indicatorTextColor
                                        indicatorTextFont:(UIFont *)indicatorTextFont
                                          indicatorHeight:(CGFloat)indicatorHeight
                                     indicatorRightMargin:(CGFloat)indicatorRightMargin
                                 indexItemBackgroundColor:(UIColor *)indexItemBackgroundColor
                                       indexItemTextColor:(UIColor *)indexItemTextColor
                         indexItemSelectedBackgroundColor:(UIColor *)indexItemSelectedBackgroundColor
                               indexItemSelectedTextColor:(UIColor *)indexItemSelectedTextColor
                                          indexItemHeight:(CGFloat)indexItemHeight
                                     indexItemRightMargin:(CGFloat)indexItemRightMargin
                                          indexItemsSpace:(CGFloat)indexItemsSpace;

@end
