
#import "ViewController.h"
#import "SCIndexViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"选择索引类型";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController;
    switch (indexPath.row) {
        case 0:
        {
            SCIndexViewController *indexViewController = [SCIndexViewController new];
            indexViewController.ignoreSections = NO;
            indexViewController.hasSearch = YES;
            viewController = indexViewController;
        }
            break;
            
        case 1:
        {
            SCIndexViewController *indexViewController = [SCIndexViewController new];
            indexViewController.ignoreSections = YES;
            indexViewController.hasSearch = YES;
            viewController = indexViewController;
        }
            break;
            
        case 2:
        {
            SCIndexViewController *indexViewController = [SCIndexViewController new];
            indexViewController.ignoreSections = NO;
            viewController = indexViewController;
        }
            break;
            
        case 3:
        {
            SCIndexViewController *indexViewController = [SCIndexViewController new];
            indexViewController.ignoreSections = YES;
            viewController = indexViewController;
        }
            break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"不忽略sections";
            cell.detailTextLabel.text = @"有搜索";
        }
            break;
            
        case 1:
        {
            cell.textLabel.text = @"忽略三个sections";
            cell.detailTextLabel.text = @"有搜索";
        }
            break;
            
        case 2:
        {
            cell.textLabel.text = @"不忽略sections";
            cell.detailTextLabel.text = @"无搜索";
        }
            break;
            
        case 3:
        {
            cell.textLabel.text = @"忽略三个sections";
            cell.detailTextLabel.text = @"无搜索";
        }
            break;
            
        default:
            break;
    }
    return cell;
}

@end
