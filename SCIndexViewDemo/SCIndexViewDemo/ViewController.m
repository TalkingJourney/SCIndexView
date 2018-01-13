
#import "ViewController.h"
#import "YYModel.h"
#import "SectionItem.h"
#import "SCIndexView.h"

@interface ViewController () <UITableViewDataSource, SCIndexViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SCIndexView *indexView;

@property (nonatomic, copy) NSArray<SectionItem *> *tableViewDataSource;
@property (nonatomic, assign) BOOL translucent;

@end

@implementation ViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.translucent = YES;
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.indexView];
    
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
            
            self.indexView.dataSource = indexViewDataSource.copy;
        });
    });
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

#pragma mark - SCIndexViewDelegate

- (void)indexView:(SCIndexView *)indexView didSelectAtIndex:(NSUInteger)index
{
    
}

#pragma mark - Getter and Setter

- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat height = self.translucent ? 0 : 64;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, height, self.view.bounds.size.width, self.view.bounds.size.height - height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

- (SCIndexView *)indexView
{
    if (!_indexView) {
        _indexView = [[SCIndexView alloc] initWithTableView:self.tableView configuration:[SCIndexViewConfiguration configuration]];
        _indexView.translucentForTableViewInNavigationBar = self.translucent;
        _indexView.delegate = self;
    }
    return _indexView;
}
@end
