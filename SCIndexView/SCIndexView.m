
#import "SCIndexView.h"

static NSTimeInterval kAnimationDuration = 0.25;

static void * SCIndexViewContext = &SCIndexViewContext;
static NSString *kSCFrameStringFromSelector = @"frame";
static NSString *kSCContentOffsetStringFromSelector = @"contentOffset";

// 根据section值获取CATextLayer的中心点y值
static inline CGFloat SCGetTextLayerCenterY(NSUInteger section, CGFloat margin, CGFloat space)
{
    return margin + section * space;
}

// 根据y值获取CATextLayer的section值
static inline NSInteger SCSectionOfTextLayerInY(CGFloat y, CGFloat margin, CGFloat space)
{
    NSUInteger bigger = (NSUInteger)ceil((y - margin) / space);
    NSUInteger smaller = bigger - 1;
    CGFloat biggerCenterY = bigger * space + margin;
    CGFloat smallerCenterY = smaller * space + margin;
    return biggerCenterY + smallerCenterY > 2 * y ? smaller : bigger;
}

@interface SCIndexView ()

@property (nonatomic, strong) NSMutableArray<CATextLayer *> *subTextLayers;
@property (nonatomic, strong) UILabel *indicator;
@property (nonatomic, strong) UITableView *tableView;

// tableView是否实现cellHeight的代理方法
@property (nonatomic, assign) BOOL tableViewHasCellHeightMethod;
// 触摸索引视图
@property (nonatomic, assign, getter=isTouchingIndexView) BOOL touchingIndexView;

/** 触感反馈 */
@property (nonatomic, strong) UIImpactFeedbackGenerator *generator NS_AVAILABLE_IOS(10_0);

@end

@implementation SCIndexView

#pragma mark - Life Cycle

- (instancetype)initWithTableView:(UITableView *)tableView configuration:(SCIndexViewConfiguration *)configuration
{
    if (self = [super initWithFrame:tableView.frame]) {
        _tableView = tableView;
        _currentSection = NSUIntegerMax;
        _configuration = configuration;
        _translucentForTableViewInNavigationBar = YES;
        _tableViewHasCellHeightMethod = self.tableView.delegate && [self.tableView.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
        
        [self addSubview:self.indicator];
        
        [tableView addObserver:self forKeyPath:kSCFrameStringFromSelector options:NSKeyValueObservingOptionNew context:SCIndexViewContext];
        [tableView addObserver:self forKeyPath:kSCContentOffsetStringFromSelector options:NSKeyValueObservingOptionNew context:SCIndexViewContext];
    }
    return self;
}

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:kSCFrameStringFromSelector];
    [self.tableView removeObserver:self forKeyPath:kSCContentOffsetStringFromSelector];
}

- (void)configSubLayersAndSubviews
{
    NSInteger countDifference = self.dataSource.count - self.subTextLayers.count;
    if (countDifference > 0) {
        for (int i = 0; i < countDifference; i++) {
            CATextLayer *textLayer = [CATextLayer layer];
            [self.layer addSublayer:textLayer];
            [self.subTextLayers addObject:textLayer];
        }
    } else {
        for (int i = 0; i < -countDifference; i++) {
            CATextLayer *textLayer = self.subTextLayers.lastObject;
            [textLayer removeFromSuperlayer];
            [self.subTextLayers removeObject:textLayer];
        }
    }
    
    CGFloat space = self.configuration.indexItemHeight + self.configuration.indexItemsSpace / 2;
    CGFloat margin = (self.bounds.size.height - space * self.dataSource.count) / 2;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    for (int i = 0; i < self.dataSource.count; i++) {
        CATextLayer *textLayer = self.subTextLayers[i];
        textLayer.frame = CGRectMake(self.bounds.size.width - self.configuration.indexItemRightMargin - self.configuration.indexItemHeight, SCGetTextLayerCenterY(i, margin, space), self.configuration.indexItemHeight, self.configuration.indexItemHeight);
        textLayer.string = self.dataSource[i];
        textLayer.fontSize = self.configuration.indexItemHeight * 0.8;
        textLayer.cornerRadius = self.configuration.indexItemHeight / 2;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        textLayer.backgroundColor = self.configuration.indexItemBackgroundColor.CGColor;
        textLayer.foregroundColor = self.configuration.indexItemTextColor.CGColor;
    }
    [CATransaction commit];
    
    if (self.subTextLayers.count == 0) {
        self.currentSection = NSUIntegerMax;
    } else if (self.currentSection == NSUIntegerMax) {
        self.currentSection = 0;
    } else {
        self.currentSection = self.subTextLayers.count - 1;
    }
}

- (void)configCurrentSection
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sectionOfIndexView:tableViewDidScroll:)]) {
        NSUInteger currentSection = [self.delegate sectionOfIndexView:self tableViewDidScroll:self.tableView];
        if (currentSection != SCIndexViewInvalidSection) {
            self.currentSection = currentSection;
            return;
        }
    }
    
    NSIndexPath *needIndexPath;
    if (!self.translucentForTableViewInNavigationBar) {
        needIndexPath = self.tableView.indexPathsForVisibleRows.firstObject;
    } else {
        CGFloat insetHeight = UIApplication.sharedApplication.statusBarFrame.size.height + 44;
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            CGRect frame = [cell.superview convertRect:cell.frame toView:UIApplication.sharedApplication.delegate.window];
            if (frame.origin.y + frame.size.height >= insetHeight) {
                needIndexPath = [self.tableView indexPathForCell:cell];
                break;
            }
        }
    }
    
    if (!needIndexPath) return;
    self.currentSection = needIndexPath.section;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context != SCIndexViewContext) return;
    
    if ([keyPath isEqualToString:kSCFrameStringFromSelector]) {
        CGRect frame = [change[NSKeyValueChangeNewKey] CGRectValue];
        self.frame = frame;
        
        CGFloat space = self.configuration.indexItemHeight + self.configuration.indexItemsSpace / 2;
        CGFloat margin = (self.bounds.size.height - space * self.dataSource.count) / 2;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        for (int i = 0; i < self.dataSource.count; i++) {
            CATextLayer *textLayer = self.subTextLayers[i];
            textLayer.frame = CGRectMake(self.bounds.size.width - self.configuration.indexItemRightMargin - self.configuration.indexItemHeight, SCGetTextLayerCenterY(i, margin, space), self.configuration.indexItemHeight, self.configuration.indexItemHeight);
        }
        [CATransaction commit];
    } else if ([keyPath isEqualToString:kSCContentOffsetStringFromSelector]) {
        [self onActionWithScroll];
    }
}

#pragma mark - Event Response

- (void)onActionWithDidSelect
{
    if (self.currentSection < 0 || self.currentSection >= self.dataSource.count) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.currentSection];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    
    if (self.isTouchingIndexView) {
        if (@available(iOS 10.0, *)) {
            [self.generator prepare];
            [self.generator impactOccurred];
        }
    }
}

- (void)onActionWithScroll
{
    if (self.isTouchingIndexView) {
        // 当滑动tableView视图时，另一手指滑动索引视图，让tableView滑动失效
        self.tableView.panGestureRecognizer.enabled = NO;
        self.tableView.panGestureRecognizer.enabled = YES;
        
        return; // 当滑动索引视图时，tableView滚动不能影响索引位置
    }
    
    // 可能tableView的contentOffset变化，却没有scroll，此时不应该影响索引位置
    BOOL isScrolling = self.tableView.isDragging || self.tableView.isDecelerating;
    if (!isScrolling) return;
    
    [self configCurrentSection];
}

#pragma mark - Display

- (UIBezierPath *)drawIndicatorPath
{
    CGFloat indicatorRadius = self.configuration.indicatorHeight / 2;
    CGFloat sinPI_4_Radius = sin(M_PI_4) * indicatorRadius;
    CGFloat margin = (sinPI_4_Radius * 2 - indicatorRadius);
    
    CGPoint startPoint = CGPointMake(margin + indicatorRadius + sinPI_4_Radius, indicatorRadius - sinPI_4_Radius);
    CGPoint trianglePoint = CGPointMake(4 * sinPI_4_Radius, indicatorRadius);
    CGPoint centerPoint = CGPointMake(margin + indicatorRadius, indicatorRadius);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:startPoint];
    [bezierPath addArcWithCenter:centerPoint radius:indicatorRadius startAngle:-M_PI_4 endAngle:M_PI_4 clockwise:NO];
    [bezierPath addLineToPoint:trianglePoint];
    [bezierPath addLineToPoint:startPoint];
    [bezierPath closePath];
    return bezierPath;
}

- (void)showIndicator:(BOOL)animated
{
    if (!self.indicator.hidden || self.currentSection < 0 || self.currentSection >= self.subTextLayers.count) return;
    
    CATextLayer *textLayer = self.subTextLayers[self.currentSection];
    if (self.configuration.indexViewStyle == SCIndexViewStyleDefault) {
        self.indicator.center = CGPointMake(self.bounds.size.width - self.indicator.bounds.size.width / 2 - self.configuration.indicatorRightMargin, textLayer.position.y);
    }
    self.indicator.text = textLayer.string;
    
    if (animated) {
        self.indicator.alpha = 0;
        self.indicator.hidden = NO;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.indicator.alpha = 1;
        }];
    } else {
        self.indicator.alpha = 1;
        self.indicator.hidden = NO;
    }
}

- (void)hideIndicator:(BOOL)animated
{
    if (self.indicator.hidden) return;
    
    if (animated) {
        self.indicator.alpha = 1;
        self.indicator.hidden = NO;
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.indicator.alpha = 0;
        } completion:^(BOOL finished) {
            self.indicator.alpha = 1;
            self.indicator.hidden = YES;
        }];
    } else {
        self.indicator.alpha = 1;
        self.indicator.hidden = YES;
    }
}

- (void)refreshTextLayer:(BOOL)selected
{
    if (self.currentSection < 0 || self.currentSection >= self.subTextLayers.count) return;
    
    CATextLayer *textLayer = self.subTextLayers[self.currentSection];
    UIColor *backgroundColor, *foregroundColor;
    if (selected) {
        backgroundColor = self.configuration.indexItemSelectedBackgroundColor;
        foregroundColor = self.configuration.indexItemSelectedTextColor;
    } else {
        backgroundColor = self.configuration.indexItemBackgroundColor;
        foregroundColor = self.configuration.indexItemTextColor;
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    textLayer.backgroundColor = backgroundColor.CGColor;
    textLayer.foregroundColor = foregroundColor.CGColor;
    [CATransaction commit];
}

#pragma mark - UITouch and UIEvent

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // 当滑动索引视图时，防止其他手指去触发事件
    if (self.touchingIndexView) return YES;
    
    CATextLayer *firstTextLayer = self.subTextLayers.firstObject;
    if (!firstTextLayer) return NO;
    CATextLayer *lastTextLayer = self.subTextLayers.lastObject;
    if (!lastTextLayer) return NO;
    
    CGFloat space = self.configuration.indexItemRightMargin * 2;
    if (point.x > self.bounds.size.width - space - self.configuration.indexItemHeight
        && point.y > firstTextLayer.frame.origin.y - space
        && point.y < lastTextLayer.frame.origin.y + space) {
        return YES;
    }
    return NO;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touchingIndexView = YES;
    CGFloat space = self.configuration.indexItemHeight + self.configuration.indexItemsSpace / 2;
    CGFloat margin = (self.bounds.size.height - space * self.dataSource.count) / 2;
    CGPoint location = [touch locationInView:self];
    NSInteger currentSection = SCSectionOfTextLayerInY(location.y, margin, space);
    if (currentSection < 0 || currentSection >= self.subTextLayers.count) return YES;
    
    [self hideIndicator:NO];
    self.currentSection = currentSection;
    [self showIndicator:YES];
    [self onActionWithDidSelect];
    if (self.delegate && [self.delegate respondsToSelector:@selector(indexView:didSelectAtSection:)]) {
        [self.delegate indexView:self didSelectAtSection:self.currentSection];
    }
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touchingIndexView = YES;
    CGFloat space = self.configuration.indexItemHeight + self.configuration.indexItemsSpace / 2;
    CGFloat margin = (self.bounds.size.height - space * self.dataSource.count) / 2;
    CGPoint location = [touch locationInView:self];
    NSInteger currentSection = SCSectionOfTextLayerInY(location.y, margin, space);
    
    NSUInteger subTextLayersCount = self.subTextLayers.count;
    if (currentSection < 0) {
        currentSection = 0;
    } else if (currentSection >= subTextLayersCount) {
        currentSection = subTextLayersCount - 1;
    }
    if (currentSection == self.currentSection) return YES;
    
    [self hideIndicator:NO];
    self.currentSection = currentSection;
    [self showIndicator:NO];
    [self onActionWithDidSelect];
    if (self.delegate && [self.delegate respondsToSelector:@selector(indexView:didSelectAtSection:)]) {
        [self.delegate indexView:self didSelectAtSection:self.currentSection];
    }
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.touchingIndexView = NO;
    [self hideIndicator:YES];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    self.touchingIndexView = NO;
    [self hideIndicator:YES];
}

#pragma mark - Getters and Setters

- (void)setDataSource:(NSArray<NSString *> *)dataSource
{
    if (_dataSource == dataSource) return;
    
    _dataSource = dataSource.copy;
    
    [self configSubLayersAndSubviews];
    [self configCurrentSection];
}

- (void)setCurrentSection:(NSInteger)currentSection
{
    if (currentSection < 0 || currentSection >= self.dataSource.count || currentSection == _currentSection) return;
    
    [self refreshTextLayer:NO];
    _currentSection = currentSection;
    [self refreshTextLayer:YES];
}

- (NSMutableArray *)subTextLayers
{
    if (!_subTextLayers) {
        _subTextLayers = [NSMutableArray array];
    }
    return _subTextLayers;
}

- (UILabel *)indicator
{
    if (!_indicator) {
        _indicator = [UILabel new];
        _indicator.layer.backgroundColor = self.configuration.indicatorBackgroundColor.CGColor;
        _indicator.textColor = self.configuration.indicatorTextColor;
        _indicator.font = self.configuration.indicatorTextFont;
        _indicator.textAlignment = NSTextAlignmentCenter;
        _indicator.hidden = YES;
        
        switch (self.configuration.indexViewStyle) {
            case SCIndexViewStyleDefault:
            {
                CGFloat indicatorRadius = self.configuration.indicatorHeight / 2;
                CGFloat sinPI_4_Radius = sin(M_PI_4) * indicatorRadius;
                _indicator.bounds = CGRectMake(0, 0, (4 * sinPI_4_Radius), 2 * indicatorRadius);
                
                CAShapeLayer *maskLayer = [CAShapeLayer layer];
                maskLayer.path = [self drawIndicatorPath].CGPath;
                _indicator.layer.mask = maskLayer;
            }
                break;
                
            case SCIndexViewStyleCenterToast:
            {
                _indicator.bounds = CGRectMake(0, 0, self.configuration.indicatorHeight, self.configuration.indicatorHeight);
                _indicator.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
                _indicator.layer.cornerRadius = self.configuration.indicatorCornerRadius;
            }
                break;
                
            default:
                break;
        }
    }
    return _indicator;
}

- (UIImpactFeedbackGenerator *)generator {
    if (!_generator) {
        _generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    }
    return _generator;
}
    
@end
