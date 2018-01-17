
#import "ViewController.h"
#import "SCIndexViewController.h"
#import "SCIndexView2Controller.h"

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
            indexViewController.indexViewStyle = SCIndexViewStyleDefault;
            viewController = indexViewController;
        }
            break;
            
        case 1:
        {
            SCIndexViewController *indexViewController = [SCIndexViewController new];
            indexViewController.indexViewStyle = SCIndexViewStyleCenterToast;
            viewController = indexViewController;
        }
            break;
            
        case 2:
        {
            SCIndexView2Controller *indexViewController = [SCIndexView2Controller new];
            indexViewController.indexViewStyle = SCIndexViewStyleDefault;
            viewController = indexViewController;
        }
            break;
            
        case 3:
        {
            SCIndexView2Controller *indexViewController = [SCIndexView2Controller new];
            indexViewController.indexViewStyle = SCIndexViewStyleCenterToast;
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
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"指向点类型";
            cell.detailTextLabel.text = @"V1.x";
        }
            break;
            
        case 1:
        {
            cell.textLabel.text = @"中心提示弹层";
            cell.detailTextLabel.text = @"V1.x";
        }
            break;
            
        case 2:
        {
            cell.textLabel.text = @"指向点类型";
            cell.detailTextLabel.text = @"V2.x";
        }
            break;
            
        case 3:
        {
            cell.textLabel.text = @"中心提示弹层";
            cell.detailTextLabel.text = @"V2.x";
        }
            break;
            
        default:
            break;
    }
    return cell;
}

@end
