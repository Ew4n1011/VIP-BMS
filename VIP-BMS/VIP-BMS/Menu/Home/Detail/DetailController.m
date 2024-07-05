//
//  DetailController.m
//  VIP-BMS
//
//  Created by goorume on 2020/4/26.
//  Copyright © 2020 goorume. All rights reserved.
//

#import "DetailController.h"

#import "DetailCell.h"

@interface DetailController ()

@end

@implementation DetailController {
    NSArray *_configArray;
    
    BOOL _isZzfd; // 保存放电状态中“终止放电”状态，在放电预警中使用
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = InternationaString(@"电池基本信息");
    
    [self loadDataSource];
    
    [self setUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDevice) name:NotificationUpdateDevice object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateDevice {
    [self loadDataSource];
    [self.tableView reloadData];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _configArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        NSDictionary *dict = [_configArray objectAtIndex:section];
        NSArray *rows = [dict objectForKey:@"rows"];
        return rows.count;
    }
    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44.0f;
    }
    
    if (indexPath.section == 1) {
        return 100.0f;
    }
    
    if (indexPath.section == 2) {
        return 100.0f;
    }
    
    if (indexPath.section == 3) {
        return 140.0f;
    }
    
    return 180.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.f;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *idfHeader = @"idfHeader";
    DetailCell *header = (DetailCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:idfHeader];
    if (!header) {
        header = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:0];
    }
    
    NSDictionary *dict = [_configArray objectAtIndex:section];
    header.titLabel.text = [dict stringForKey:@"title"];
    
    return header;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *idfCell0 = @"idfCell0";
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:idfCell0];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:1];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        NSDictionary *sectionDict = [_configArray objectAtIndex:indexPath.section];
        NSArray *rows = [sectionDict arrayForKey:@"rows"];
        
        NSDictionary *rowDict = [rows objectAtIndex:indexPath.row];
        cell.titLabel.text = [rowDict stringForKey:@"title"];
        cell.rightLabel.text = [rowDict stringForKey:@"value"];
        
        cell.line.hidden = indexPath.row == rows.count-1;
        
        return cell;
    }
    
    if (indexPath.section == 1) {
        NSDictionary *sectionDict = [_configArray objectAtIndex:indexPath.section];
        
        static NSString *idfCell1 = @"idfCell1";
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:idfCell1];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:2];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSArray *rows = [sectionDict arrayForKey:@"rows"];
            
            for (int i = 0; i < rows.count && i < cell.labelArrayCell1.count; i++) {
                UILabel *lb = [cell.labelArrayCell1 objectAtIndex:i];
                
                NSDictionary *rowDict = [rows objectAtIndex:i];
                lb.text = [rowDict stringForKey:@"title"];
            }
        }
        
        NSArray *rows = [sectionDict arrayForKey:@"rows"];
        
        int index = [[sectionDict stringForKey:@"value"] intValue];
        for (int i = 0; i < cell.labelArrayCell1.count; i++) {
            UILabel *lb = [cell.labelArrayCell1 objectAtIndex:i];
            
            NSDictionary *rowDict = [rows objectAtIndex:i];
            int value = [[rowDict stringForKey:@"value"] intValue];
            
            if (value < 8) {
                if ((index & (1<<value)) == (1<<value)) {
                    lb.textColor = UIColor.whiteColor;
                    lb.backgroundColor = kMAINCOLOR_GREEN;
                } else {
                    lb.textColor = UIColor.darkGrayColor;
                    lb.backgroundColor = UIColor.groupTableViewBackgroundColor;
                }
            }
        }

        return cell;
    }
    
    if (indexPath.section == 2) {
        NSDictionary *sectionDict = [_configArray objectAtIndex:indexPath.section];
        
        static NSString *idfCell2 = @"idfCell2";
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:idfCell2];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:3];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            NSArray *rows = [sectionDict arrayForKey:@"rows"];
            
            for (int i = 0; i < rows.count && i < cell.labelArrayCell2.count; i++) {
                UILabel *lb = [cell.labelArrayCell2 objectAtIndex:i];
                
                NSDictionary *rowDict = [rows objectAtIndex:i];
                lb.text = [rowDict stringForKey:@"title"];
            }
        }
        
        NSArray *rows = [sectionDict arrayForKey:@"rows"];
        
        int index = [[sectionDict stringForKey:@"value"] intValue];
        for (int i = 0; i < cell.labelArrayCell2.count; i++) {
            UILabel *lb = [cell.labelArrayCell2 objectAtIndex:i];
            
            NSDictionary *rowDict = [rows objectAtIndex:i];
            int value = [[rowDict stringForKey:@"value"] intValue];
            
            if (value < 8) {
                if ((index & (1<<value)) == (1<<value)) {
                    lb.textColor = UIColor.whiteColor;
                    lb.backgroundColor = kMAINCOLOR_GREEN;
                } else {
                    lb.textColor = UIColor.darkGrayColor;
                    lb.backgroundColor = UIColor.groupTableViewBackgroundColor;
                }
            }
        }
        
        return cell;
    }
    
    if (indexPath.section == 3) {
        NSDictionary *sectionDict = [_configArray objectAtIndex:indexPath.section];
        
        static NSString *idfCell3 = @"idfCell3";
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:idfCell3];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:4];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSArray *rows = [sectionDict arrayForKey:@"rows"];
            
            for (int i = 0; i < rows.count && i < cell.labelArrayCell3.count; i++) {
                UILabel *lb = [cell.labelArrayCell3 objectAtIndex:i];
                
                NSDictionary *rowDict = [rows objectAtIndex:i];
                lb.text = [rowDict stringForKey:@"title"];
            }
        }
        
        NSArray *rows = [sectionDict arrayForKey:@"rows"];
        
        int index = [[sectionDict stringForKey:@"value"] intValue];
        for (int i = 0; i < cell.labelArrayCell3.count; i++) {
            UILabel *lb = [cell.labelArrayCell3 objectAtIndex:i];
            
            NSDictionary *rowDict = [rows objectAtIndex:i];
            int value = [[rowDict stringForKey:@"value"] intValue];
            
            if (value < 8) {
                if ((index & (1<<value)) == (1<<value)) {
                    lb.textColor = UIColor.whiteColor;
                    lb.backgroundColor = kMAINCOLOR_GREEN;
                } else {
                    lb.textColor = UIColor.darkGrayColor;
                    lb.backgroundColor = UIColor.groupTableViewBackgroundColor;
                }
            }
            
            if ([[rowDict stringForKey:@"title"] isEqualToString:InternationaString(@"终止放电")]) {
                _isZzfd = (index & (1<<value)) == (1<<value);
            }
        }
        
        return cell;
    }
    
    if (indexPath.section == 4) {
        NSDictionary *sectionDict = [_configArray objectAtIndex:indexPath.section];
        
        static NSString *idfCell4 = @"idfCell4";
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:idfCell4];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:5];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            NSArray *rows = [sectionDict arrayForKey:@"rows"];
            
            for (int i = 0; i < rows.count && i < cell.labelArrayCell4.count; i++) {
                UILabel *lb = [cell.labelArrayCell4 objectAtIndex:i];
                
                NSDictionary *rowDict = [rows objectAtIndex:i];
                lb.text = [rowDict stringForKey:@"title"];
            }
        }
        
        NSArray *rows = [sectionDict arrayForKey:@"rows"];
        
        int index = [[sectionDict stringForKey:@"value"] intValue];
        for (int i = 0; i < cell.labelArrayCell4.count; i++) {
            UILabel *lb = [cell.labelArrayCell4 objectAtIndex:i];
            
            NSDictionary *rowDict = [rows objectAtIndex:i];
            int value = [[rowDict stringForKey:@"value"] intValue];
            
            if (value < 8) {
                if ((index & (1<<value)) == (1<<value)) {
                    lb.textColor = UIColor.whiteColor;
                    lb.backgroundColor = kMAINCOLOR_GREEN;
                } else {
                    lb.textColor = UIColor.darkGrayColor;
                    lb.backgroundColor = UIColor.groupTableViewBackgroundColor;
                }
            }
            
            if ([[rowDict stringForKey:@"title"] isEqualToString:InternationaString(@"终止放电")]) {
                // 取放电状态的数据
                NSDictionary *sDict = [_configArray objectAtIndex:3];
                int sIndex = [[sDict stringForKey:@"value"] intValue];
                NSArray *rs = [sDict arrayForKey:@"rows"];
                for (int j = 0; j < rs.count; j++) {
                    NSDictionary *rDict = [rs objectAtIndex:j];
                    if ([[rDict stringForKey:@"title"] isEqualToString:InternationaString(@"终止放电")]) {
                        int v = [[rDict stringForKey:@"value"] intValue];
                        if (v < 8) {
                            if ((sIndex & (1<<v)) == (1<<v)) {
                                lb.textColor = UIColor.whiteColor;
                                lb.backgroundColor = kMAINCOLOR_GREEN;
                            } else {
                                lb.textColor = UIColor.darkGrayColor;
                                lb.backgroundColor = UIColor.groupTableViewBackgroundColor;
                            }
                        }
                        break;
                    }
                }
            }
        }
        
        return cell;
    }
    
    return [UITableViewCell new];
}

- (void)loadDataSource {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    
    NSString *csString = [NSString stringWithFormat:@"%@", device.fdcs ?: @"0", InternationaString(@"次")];
    _configArray = @[@{@"title":InternationaString(@"基本信息"), @"rows":@[@{@"title":InternationaString(@"序列号"), @"value":device.scxlh ?: @"00000001"},
                                                                         @{@"title":InternationaString(@"生产日期"), @"value":device.scrq ?: @"1970.01.01"},
                                                                         @{@"title":InternationaString(@"设计容量"), @"value":device.sjrl ?: @"0mAh"},
                                                                         @{@"title":InternationaString(@"设计电压"), @"value":device.sjdy ?: @"0mV"},
                                                                         @{@"title":InternationaString(@"充满容量"), @"value":device.mcrl ?: @"0mAh"},
                                                                         @{@"title":InternationaString(@"循环次数"), @"value":csString}]},
                     
                     @{@"title":InternationaString(@"充电状态"), @"rows":@[@{@"title":InternationaString(@"充电状态_过流保护"), @"value":@"0"},
                                                                         @{@"title":InternationaString(@"充电状态_过温"), @"value":@"1"},
                                                                         @{@"title":InternationaString(@"充电状态_低温"), @"value":@"2"},
                                                                         @{@"title":InternationaString(@"充电状态_电芯过充"), @"value":@"3"},
                                                                         @{@"title":InternationaString(@"充电状态_电池过充"), @"value":@"4"},
                                                                         @{@"title":InternationaString(@"充电状态_充电MOS"), @"value":@"7"}], @"value":device.cdzt ?: @"99"},
                       
                     @{@"title":InternationaString(@"充电预警"), @"rows":@[@{@"title":InternationaString(@"充电预警_过流"), @"value":@"0"},
                                                                         @{@"title":InternationaString(@"充电预警_过温"), @"value":@"1"},
                                                                         @{@"title":InternationaString(@"充电预警_低温"), @"value":@"2"},
                                                                         @{@"title":InternationaString(@"充电预警_压差"), @"value":@"3"},
                                                                         @{@"title":InternationaString(@"充电预警_充电充满"), @"value":@"7"}], @"value":device.cdyj ?: @"99"},
                       
                     @{@"title":InternationaString(@"放电状态"), @"rows":@[@{@"title":InternationaString(@"放电状态_过流保护"), @"value":@"0"},
                                                                         @{@"title":InternationaString(@"放电状态_过温"), @"value":@"1"},
                                                                         @{@"title":InternationaString(@"放电状态_低温"), @"value":@"2"},
                                                                         @{@"title":InternationaString(@"放电状态_电芯过放"), @"value":@"3"},
                                                                         @{@"title":InternationaString(@"放电状态_电池过放"), @"value":@"4"},
                                                                         @{@"title":InternationaString(@"放电状态_短路保护"), @"value":@"5"},
                                                                         /*@{@"title":InternationaString(@"放电状态_终止放电"), @"value":@"6"},*/
                                                                         @{@"title":InternationaString(@"放电状态_放电MOS"), @"value":@"7"}], @"value":device.fdzt ?: @"99"},
                       
                     @{@"title":InternationaString(@"放电预警"), @"rows":@[@{@"title":InternationaString(@"放电预警_过流"), @"value":@"0"},
                                                                         @{@"title":InternationaString(@"放电预警_过温"), @"value":@"1"},
                                                                         @{@"title":InternationaString(@"放电预警_低温"), @"value":@"2"},
                                                                         @{@"title":InternationaString(@"放电预警_压差"), @"value":@"3"},
                                                                         @{@"title":InternationaString(@"放电预警_剩余时间不足"), @"value":@"4"},
                                                                         /*@{@"title":InternationaString(@"放电预警_终止放电"), @"value":@"99"},*/
                                                                         @{@"title":InternationaString(@"放电预警_电芯过放"), @"value":@"6"},
                                                                         @{@"title":InternationaString(@"放电预警_剩余容量不足"), @"value":@"5"},
                                                                         @{@"title":InternationaString(@"放电预警_电池过放"), @"value":@"7"}], @"value":device.fdyj ?: @"99"}];
}

- (void)setUI {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
