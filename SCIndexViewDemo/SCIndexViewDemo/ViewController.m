
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
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCIndexViewController *indexViewController = [SCIndexViewController new];
    switch (indexPath.row) {
        case 0:
        {
            indexViewController.indexViewStyle = SCIndexViewStyleDefault;
        }
            break;
            
        case 1:
        {
            indexViewController.indexViewStyle = SCIndexViewStyleCenterToast;
        }
            break;
            
        default:
            break;
    }
    [self.navigationController pushViewController:indexViewController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"指向点类型";
        }
            break;
            
        case 1:
        {
            cell.textLabel.text = @"中心提示弹层";
        }
            break;
            
        default:
            break;
    }
    return cell;
}

@end
