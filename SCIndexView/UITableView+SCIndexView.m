
#import "UITableView+SCIndexView.h"
#import <objc/runtime.h>
#import "SCIndexView.h"

@interface SCWeakProxy : NSObject

@property (nonatomic, weak) SCIndexView *indexView;

@end
@implementation SCWeakProxy
@end

@interface UITableView () <SCIndexViewDelegate>

@property (nonatomic, strong) SCIndexView *sc_indexView;

@end

@implementation UITableView (SCIndexView)

#pragma mark - Swizzle Method

+ (void)load
{
    [self swizzledSelector:@selector(SCIndexView_didMoveToSuperview) originalSelector:@selector(didMoveToSuperview)];
    [self swizzledSelector:@selector(SCIndexView_removeFromSuperview) originalSelector:@selector(removeFromSuperview)];
}

+ (void)swizzledSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector
{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma Add and Remove View

- (void)SCIndexView_didMoveToSuperview
{
    [self SCIndexView_didMoveToSuperview];
    if (self.sc_indexViewDataSource.count && !self.sc_indexView && self.superview) {
        SCIndexView *indexView = [[SCIndexView alloc] initWithTableView:self configuration:self.sc_indexViewConfiguration];
        indexView.translucentForTableViewInNavigationBar = self.sc_translucentForTableViewInNavigationBar;
        indexView.delegate = self;
        indexView.dataSource = self.sc_indexViewDataSource;
        [self.superview addSubview:indexView];
        
        self.sc_indexView = indexView;
    }
}

- (void)SCIndexView_removeFromSuperview
{
    if (self.sc_indexView) {
        [self.sc_indexView removeFromSuperview];
        self.sc_indexView = nil;
    }
    [self SCIndexView_removeFromSuperview];
}

#pragma mark - SCIndexViewDelegate

- (void)indexView:(SCIndexView *)indexView didSelectAtSection:(NSUInteger)section
{
    if (self.sc_indexViewDelegate && [self.delegate respondsToSelector:@selector(tableView:didSelectIndexViewAtSection:)]) {
        [self.sc_indexViewDelegate tableView:self didSelectIndexViewAtSection:section];
    }
}

- (NSUInteger)sectionOfIndexView:(SCIndexView *)indexView tableViewDidScroll:(UITableView *)tableView
{
    if (self.sc_indexViewDelegate && [self.delegate respondsToSelector:@selector(sectionOfTableViewDidScroll:)]) {
        return [self.sc_indexViewDelegate sectionOfTableViewDidScroll:self];
    } else {
        return SCIndexViewInvalidSection;
    }
}

#pragma mark - Getter and Setter

- (SCIndexView *)sc_indexView
{
    SCWeakProxy *weakProxy = objc_getAssociatedObject(self, @selector(sc_indexView));
    return weakProxy.indexView;
}

- (void)setSc_indexView:(SCIndexView *)sc_indexView
{
    if (self.sc_indexView == sc_indexView) return;
    
    SCWeakProxy *weakProxy = [SCWeakProxy new];
    weakProxy.indexView = sc_indexView;
    objc_setAssociatedObject(self, @selector(sc_indexView), weakProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SCIndexViewConfiguration *)sc_indexViewConfiguration
{
    SCIndexViewConfiguration *sc_indexViewConfiguration = objc_getAssociatedObject(self, @selector(sc_indexViewConfiguration));
    if (!sc_indexViewConfiguration) {
        sc_indexViewConfiguration = [SCIndexViewConfiguration configuration];
    }
    return sc_indexViewConfiguration;
}

- (void)setSc_indexViewConfiguration:(SCIndexViewConfiguration *)sc_indexViewConfiguration
{
    if (self.sc_indexViewConfiguration == sc_indexViewConfiguration) return;
    
    objc_setAssociatedObject(self, @selector(sc_indexViewConfiguration), sc_indexViewConfiguration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<SCTableViewSectionIndexDelegate>)sc_indexViewDelegate
{
    return objc_getAssociatedObject(self, @selector(sc_indexViewDelegate));
}

- (void)setSc_indexViewDelegate:(id<SCTableViewSectionIndexDelegate>)sc_indexViewDelegate
{
    if (self.sc_indexViewDelegate == sc_indexViewDelegate) return;
    
    objc_setAssociatedObject(self, @selector(sc_indexViewDelegate), sc_indexViewDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)sc_translucentForTableViewInNavigationBar
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(sc_translucentForTableViewInNavigationBar));
    return number.boolValue;
}

- (void)setSc_translucentForTableViewInNavigationBar:(BOOL)sc_translucentForTableViewInNavigationBar
{
    if (self.sc_translucentForTableViewInNavigationBar == sc_translucentForTableViewInNavigationBar) return;
    
    objc_setAssociatedObject(self, @selector(sc_translucentForTableViewInNavigationBar), @(sc_translucentForTableViewInNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.sc_indexView.translucentForTableViewInNavigationBar = sc_translucentForTableViewInNavigationBar;
}

- (NSArray<NSString *> *)sc_indexViewDataSource
{
    return objc_getAssociatedObject(self, @selector(sc_indexViewDataSource));
}

- (void)setSc_indexViewDataSource:(NSArray<NSString *> *)sc_indexViewDataSource
{
    if (self.sc_indexViewDataSource == sc_indexViewDataSource) return;
    objc_setAssociatedObject(self, @selector(sc_indexViewDataSource), sc_indexViewDataSource, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!sc_indexViewDataSource || sc_indexViewDataSource.count == 0) {
        [self.sc_indexView removeFromSuperview];
        self.sc_indexView = nil;
        return;
    }
    
    if (!self.sc_indexView && self.superview) {
        SCIndexView *indexView = [[SCIndexView alloc] initWithTableView:self configuration:self.sc_indexViewConfiguration];
        indexView.translucentForTableViewInNavigationBar = self.sc_translucentForTableViewInNavigationBar;
        indexView.delegate = self;
        [self.superview addSubview:indexView];

        self.sc_indexView = indexView;
    }
    
    self.sc_indexView.dataSource = sc_indexViewDataSource.copy;
}

@end
