//
//  BaseTableViewController.m
//  DoorLock
//
//  Created by G.R.M. on 2017/7/26.
//  Copyright © 2017年 lokfu. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configUI];
    
//    if (@available(iOS 11.0, *)) {
//        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    } else {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)configUI {
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
//        make.top.equalTo(self.view).with.offset(kTopHeight);
//        make.left.right.bottom.equalTo(self.view);
    }];

}

- (UIView *)configFooterViewAppenHeight:(CGFloat)addHeight {

    UIView *footerView = [[UIView alloc] init];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    [footerView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT-kTopHeight+addHeight)];
    self.tableView.tableFooterView = footerView;
    if (IS_IPHONE_X) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -49, 0);
    }
    
    return footerView;
}
- (UIView *)configFooterViewWithHeight:(CGFloat)height {

    UIView *footerView = [[UIView alloc] init];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    [footerView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    self.tableView.tableFooterView = footerView;
    
    return footerView;
}

#pragma mark - tabel view delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *idfCell = @"idfCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idfCell];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idfCell];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return cell;
}

- (UITableView *)tableView {
    if (!_tableView) {
        if (_plainStyle) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        }
        else {
            _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        }
        
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setBackgroundColor:[UIColor clearColor]];
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _tableView.sectionFooterHeight = 0.0;
        _tableView.sectionHeaderHeight = 0.0;
    }
    return _tableView;
}

- (void)setLayerTableView:(LayerTableView)layerTableView {
    _layerTableView = layerTableView;
    
    if (_tableView) {
         _layerTableView(_tableView, self.view);
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
