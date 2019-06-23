//
//  SCIndexViewHeaderView.m
//  SCIndexViewDemo
//
//  Created by JMS on 2019/6/21.
//  Copyright © 2019 SC. All rights reserved.
//

#import "SCIndexViewHeaderView.h"

static inline UIColor *SCGetColor(CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha)
{
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

@interface SCIndexViewHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SCIndexViewHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.frame = CGRectMake(15, 0, UIScreen.mainScreen.bounds.size.width - 15 * 2, 30);
    }
    return self;
}

+ (CGFloat)headerViewHeight {
    return 30;
}

+ (NSString *)reuseID {
    return NSStringFromClass(self);
}

- (void)configWithTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)configWithProgress:(double)progress {
    static NSMutableArray<NSNumber *> *textColorDiffArray;
    static NSMutableArray<NSNumber *> *bgColorDiffArray;
    static NSArray<NSNumber *> *selectTextColorArray;
    static NSArray<NSNumber *> *selectBgColorArray;
    
    if (textColorDiffArray.count == 0) {
        UIColor *selectTextColor = SCGetColor(40, 170, 40, 1);
        UIColor *textColor = SCGetColor(59, 60, 60, 1);
        UIColor *selectBgColor = [UIColor whiteColor];
        UIColor *bgColor = SCGetColor(231, 233, 234, 1);
        
        selectTextColorArray = [self getRGBArrayByColor:selectTextColor];
        NSArray<NSNumber *> *textColorArray = [self getRGBArrayByColor:textColor];
        selectBgColorArray = [self getRGBArrayByColor:selectBgColor];
        NSArray<NSNumber *> *bgColorArray = [self getRGBArrayByColor:bgColor];
        
        textColorDiffArray = @[].mutableCopy;
        bgColorDiffArray = @[].mutableCopy;
        for (int i = 0; i < 3; i++) {
            double textDiff = selectTextColorArray[i].doubleValue - textColorArray[i].doubleValue;
            [textColorDiffArray addObject:@(textDiff)];
            double bgDiff = selectBgColorArray[i].doubleValue - bgColorArray[i].doubleValue;
            [bgColorDiffArray addObject:@(bgDiff)];
        }
    }
    
    NSMutableArray<NSNumber *> *textColorNowArray = @[].mutableCopy;
    NSMutableArray<NSNumber *> *bgColorNowArray = @[].mutableCopy;
    for (int i = 0; i < 3; i++) {
        double textNow = selectTextColorArray[i].doubleValue - progress * textColorDiffArray[i].doubleValue;
        [textColorNowArray addObject:@(textNow)];
        
        double bgNow = selectBgColorArray[i].doubleValue - progress * bgColorDiffArray[i].doubleValue;
        [bgColorNowArray addObject:@(bgNow)];
    }
    
    UIColor *textColor = [self getColorWithRGBArray:textColorNowArray];
    self.titleLabel.textColor = textColor;
    UIColor *bgColor = [self getColorWithRGBArray:bgColorNowArray];
    self.contentView.backgroundColor = bgColor;
}

- (NSArray<NSNumber *> *)getRGBArrayByColor:(UIColor *)color
{
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    double components[3];
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component] / 255.0f;
    }
    double r = components[0];
    double g = components[1];
    double b = components[2];
    return @[@(r),@(g),@(b)];
}

- (UIColor *)getColorWithRGBArray:(NSArray<NSNumber *> *)array {
    return [UIColor colorWithRed:array[0].doubleValue green:array[1].doubleValue blue:array[2].doubleValue alpha:1];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textColor = [UIColor greenColor];
    }
    return _titleLabel;
}

@end
