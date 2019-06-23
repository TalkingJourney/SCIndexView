
#import "SCTableViewsController.h"
#import "YYModel.h"
#import "SectionItem.h"
#import "UITableView+SCIndexView.h"
#import "SCIndexViewHeaderView.h"

@interface SCTableViewsController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *indexTableView;
@property (nonatomic, strong) UITableView *otherTableView;
@property (nonatomic, copy) NSArray<SectionItem *> *indexDataSource;
@property (nonatomic, copy) NSArray<SectionItem *> *otherDataSource;

@end

@implementation SCTableViewsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"ScrollView嵌套多个TableView";
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.indexTableView];
    [self.scrollView addSubview:self.otherTableView];
    
    CGSize size = self.view.bounds.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    self.indexTableView.frame = CGRectMake(0, 0, width, height - 64);
    self.otherTableView.frame = CGRectMake(width, 0, width, height - 64);
    self.scrollView.contentSize = CGSizeMake(2 * width, height - 64);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *indexDataSource = [self getDataSourceWithPlistName:@"Indexes"];
        NSArray *otherDataSource = [self getDataSourceWithPlistName:@"IgnoreSectionsIndexes"];
        
        NSMutableArray *indexViewDataSource = [NSMutableArray array];
        NSUInteger startSection = 0;
        for (SectionItem *item in indexDataSource) {
            if ([item.title hasPrefix:@"Ignore"]) {
                startSection++;
                continue;
            }
            [indexViewDataSource addObject:item.title];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.indexDataSource = indexDataSource.copy;
            self.otherDataSource = otherDataSource.copy;
            
            [self.indexTableView reloadData];
            [self.otherTableView reloadData];
            
            self.indexTableView.sc_indexViewDataSource = indexViewDataSource.copy;
            self.indexTableView.sc_startSection = startSection;
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
    if (tableView == self.indexTableView) {
        return self.indexDataSource.count;
    }
    else {
        return self.otherDataSource.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SectionItem *sectionItem;
    if (tableView == self.indexTableView) {
        sectionItem = self.indexDataSource[section];
    }
    else {
        sectionItem = self.otherDataSource[section];
    }
    return sectionItem.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    SectionItem *sectionItem;
    if (tableView == self.indexTableView) {
        sectionItem = self.indexDataSource[indexPath.section];
    }
    else {
        sectionItem = self.otherDataSource[indexPath.section];
    }
    cell.textLabel.text = sectionItem.items[indexPath.row];;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    SectionItem *sectionItem;
    if (tableView == self.indexTableView) {
        sectionItem = self.indexDataSource[section];
    }
    else {
        sectionItem = self.otherDataSource[section];
    }
    return sectionItem.title;
}

#pragma mark - Private Methods

- (NSArray<SectionItem *> *)getDataSourceWithPlistName:(NSString *)plistName {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    return [NSArray yy_modelArrayWithClass:SectionItem.class json:[NSArray arrayWithContentsOfFile:plistPath]];
}

#pragma mark - Getter and Setter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.pagingEnabled = YES;
    }
    return _scrollView;
}

- (UITableView *)indexTableView {
    if (!_indexTableView) {
        _indexTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _indexTableView.dataSource = self;
        _indexTableView.delegate = self;
        [_indexTableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
        
        SCIndexViewConfiguration *configuration = [SCIndexViewConfiguration configuration];
        _indexTableView.sc_indexViewConfiguration = configuration;
        _indexTableView.sc_translucentForTableViewInNavigationBar = NO;
    }
    return _indexTableView;
}

- (UITableView *)otherTableView {
    if (!_otherTableView) {
        _otherTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _otherTableView.dataSource = self;
        _otherTableView.delegate = self;
        [_otherTableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    }
    return _otherTableView;
}

@end
