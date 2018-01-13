
#import "SCIndexViewConfiguration.h"

static inline UIColor *SCGetColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha)
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

@implementation SCIndexViewConfiguration

+ (instancetype)configuration
{
    return [self configurationWithIndicatorBackgroundColor:SCGetColor(200, 200, 200, 1)
                                        indicatorTextColor:[UIColor whiteColor]
                                         indicatorTextFont:[UIFont systemFontOfSize:38]
                                           indicatorHeight:50
                                      indicatorRightMargin:40
                                  indexItemBackgroundColor:[UIColor clearColor]
                                        indexItemTextColor:[UIColor darkGrayColor]
                          indexItemSelectedBackgroundColor:SCGetColor(40, 170, 40, 1)
                                indexItemSelectedTextColor:[UIColor whiteColor]
                                           indexItemHeight:15
                                      indexItemRightMargin:5
                                           indexItemsSpace:5];
}

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
                                          indexItemsSpace:(CGFloat)indexItemsSpace
{
    SCIndexViewConfiguration *configuration = [self new];
    if (!configuration) return nil;
    
    configuration.indicatorBackgroundColor = indicatorBackgroundColor;
    configuration.indicatorTextColor = indicatorTextColor;
    configuration.indicatorTextFont = indicatorTextFont;
    configuration.indicatorHeight = indicatorHeight;
    configuration.indicatorRightMargin = indicatorRightMargin;
    
    configuration.indexItemBackgroundColor = indexItemBackgroundColor;
    configuration.indexItemTextColor = indexItemTextColor;
    configuration.indexItemSelectedBackgroundColor = indexItemSelectedBackgroundColor;
    configuration.indexItemSelectedTextColor = indexItemSelectedTextColor;
    configuration.indexItemHeight = indexItemHeight;
    configuration.indexItemRightMargin = indexItemRightMargin;
    configuration.indexItemsSpace = indexItemsSpace;
    
    return configuration;
}

@end
