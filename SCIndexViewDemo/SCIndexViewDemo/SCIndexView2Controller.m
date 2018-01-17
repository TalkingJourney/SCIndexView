
#import "SCIndexView2Controller.h"
#import "YYModel.h"
#import "SectionItem.h"
#import "UITableView+SCIndexView.h"

@interface SCIndexView2Controller () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray<SectionItem *> *tableViewDataSource;
@property (nonatomic, assign) BOOL translucent;

@end

@implementation SCIndexView2Controller

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    switch (self.indexViewStyle) {
        case SCIndexViewStyleDefault:
            self.title = @"指向点类型 V2.x";
            break;

        case SCIndexViewStyleCenterToast:
            self.title = @"中心提示弹层 V2.x";
            break;

        default:
            break;
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onActionWithRightBarButton)];
    
    self.translucent = YES;
    
    [self.view addSubview:self.tableView];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Indexes" ofType:@"plist"];
        NSArray<SectionItem *> *tableViewDataSource = [NSArray yy_modelArrayWithClass:SectionItem.class json:[NSArray arrayWithContentsOfFile:plistPath]];
        
        NSMutableArray *indexViewDataSource = [NSMutableArray array];
        for (SectionItem *item in tableViewDataSource) {
            [indexViewDataSource addObject:item.title];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.tableViewDataSource = tableViewDataSource.copy;
            [self.tableView reloadData];
            
            self.tableView.sc_indexViewDataSource = indexViewDataSource.copy;
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SectionItem *sectionItem = self.tableViewDataSource[section];
    return sectionItem.title;
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
        
        _tableView.sc_indexViewConfiguration = [SCIndexViewConfiguration configurationWithIndexViewStyle:self.indexViewStyle];
        _tableView.sc_translucentForTableViewInNavigationBar = self.translucent;
    }
    return _tableView;
}

@end
