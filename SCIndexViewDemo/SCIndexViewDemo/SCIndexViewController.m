
#import "SCIndexViewController.h"
#import "YYModel.h"
#import "SectionItem.h"
#import "UITableView+SCIndexView.h"
#import "SCIndexViewHeaderView.h"

@interface SCIndexViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray<SectionItem *> *tableViewDataSource;
@property (nonatomic, assign) BOOL translucent;

@end

@implementation SCIndexViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.ignoreSections ? @"忽略三个sections" : @"不忽略sections";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onActionWithRightBarButton)];
    
    self.translucent = YES;
    
    [self.view addSubview:self.tableView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *plistName = self.ignoreSections ? @"IgnoreSectionsIndexes" : @"Indexes";
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
        NSArray<SectionItem *> *tableViewDataSource = [NSArray yy_modelArrayWithClass:SectionItem.class json:[NSArray arrayWithContentsOfFile:plistPath]];
        
        NSMutableArray *indexViewDataSource = [NSMutableArray array];
        NSUInteger startSection = 0;
        for (SectionItem *item in tableViewDataSource) {
            if ([item.title hasPrefix:@"Ignore"]) {
                startSection++;
                continue;
            }
            [indexViewDataSource addObject:item.title];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.tableViewDataSource = tableViewDataSource.copy;
            
            [self.tableView reloadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reloadColorForHeaderView];
            });
            
            if (self.hasSearch) {
                [indexViewDataSource insertObject:UITableViewIndexSearch atIndex:0];
            }
            self.tableView.sc_indexViewDataSource = indexViewDataSource.copy;
            self.tableView.sc_startSection = startSection;
        });
    });
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableViewDataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionItem *sectionItem = self.tableViewDataSource[section];
    return sectionItem.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    SectionItem *sectionItem = self.tableViewDataSource[indexPath.section];
    cell.textLabel.text = sectionItem.items[indexPath.row];;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SCIndexViewHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:SCIndexViewHeaderView.reuseID];
    SectionItem *sectionItem = self.tableViewDataSource[section];
    [headerView configWithTitle:sectionItem.title];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SCIndexViewHeaderView.headerViewHeight;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self reloadColorForHeaderView];
}

- (void)reloadColorForHeaderView {
    NSArray<NSIndexPath *> *indexPaths = self.tableView.indexPathsForVisibleRows;
    for (NSIndexPath *indexPath in indexPaths) {
        SCIndexViewHeaderView *headerView = (SCIndexViewHeaderView *)[self.tableView headerViewForSection:indexPath.section];
        [self configColorWithHeaderView:headerView];
    }
}

- (void)configColorWithHeaderView:(SCIndexViewHeaderView *)headerView {
    if (!headerView) {
        return;
    }
    
    CGFloat InsetTop = self.translucent ? UIApplication.sharedApplication.statusBarFrame.size.height + 44 : 0;
    double diff = fabs(headerView.frame.origin.y - self.tableView.contentOffset.y - InsetTop);
    CGFloat headerHeight = SCIndexViewHeaderView.headerViewHeight;
    double progress;
    if (diff >= headerHeight) {
        progress = 1;
    }
    else {
        progress = diff / headerHeight;
    }
    [headerView configWithProgress:progress];
}

#pragma mark - Event Response

- (void)onActionWithRightBarButton
{
    UIViewController *viewController = [UIViewController new];
    viewController.view.backgroundColor = [UIColor whiteColor];
    viewController.title = @"分享";
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Getter and Setter

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat height = self.translucent ? 0 : 64;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, height, self.view.bounds.size.width, self.view.bounds.size.height - height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
        [_tableView registerClass:SCIndexViewHeaderView.class forHeaderFooterViewReuseIdentifier:SCIndexViewHeaderView.reuseID];
        
        if (self.hasSearch) {
            self.tableView.tableHeaderView = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
        }
        
        SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configuration];
        _tableView.sc_indexViewConfiguration = configuration;
        _tableView.sc_translucentForTableViewInNavigationBar = self.translucent;
    }
    return _tableView;
}

@end
