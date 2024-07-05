//
//  ProtectedStatusView.m
//  VIP-BMS
//
//  Created by _G.R.M. on 2021/3/4.
//  Copyright © 2021 goorume. All rights reserved.
//

#import "ProtectedStatusView.h"

#import "DetailCell.h"

@implementation ProtectedStatusView {
    NSArray *_configArray;
    
    BOOL _isZzfd; // 保存放电状态中“终止放电”状态，在放电预警中使用
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
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
//    if (section == 0) {
//        NSDictionary *dict = [_configArray objectAtIndex:section];
//        NSArray *rows = [dict objectForKey:@"rows"];
//        return rows.count;
//    }
    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 33.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        return 44.0f;
//    }
    
    if (indexPath.section == 0) {
        return 78.0f;
    }
    
    if (indexPath.section == 1) {
        return 78.0f;
    }
    
    if (indexPath.section == 2) {
        return 116.0f;
    }
    
    return 154.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
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
//    if (indexPath.section == 0) {
//        static NSString *idfCell0 = @"idfCell0";
//        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:idfCell0];
//        if (!cell) {
//            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:1];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        }
//
//        NSDictionary *sectionDict = [_configArray objectAtIndex:indexPath.section];
//        NSArray *rows = [sectionDict arrayForKey:@"rows"];
//
//        NSDictionary *rowDict = [rows objectAtIndex:indexPath.row];
//        cell.titLabel.text = [rowDict stringForKey:@"title"];
//        cell.rightLabel.text = [rowDict stringForKey:@"value"];
//
//        cell.line.hidden = indexPath.row == rows.count-1;
//
//        return cell;
//    }
    
    if (indexPath.section == 0) {
        NSDictionary *sectionDict = [_configArray objectAtIndex:indexPath.section];
        
        static NSString *idfCell1 = @"idfCell1";
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:idfCell1];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:2];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = UIColor.clearColor;
            
            NSArray *rows = [sectionDict arrayForKey:@"rows"];
            
            for (int i = 0; i < rows.count && i < cell.labelArrayCell1.count; i++) {
                UILabel *lb = [cell.labelArrayCell1 objectAtIndex:i];
                
                NSDictionary *rowDict = [rows objectAtIndex:i];
//                lb.text = [rowDict stringForKey:@"title"];
                lb.attributedText = [self attStringWithString:[rowDict stringForKey:@"title"]];
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
                    lb.backgroundColor = kMAINCOLOR_BUTTON_BG;
                }
            }
        }

        return cell;
    }
    
    if (indexPath.section == 1) {
        NSDictionary *sectionDict = [_configArray objectAtIndex:indexPath.section];
        
        static NSString *idfCell2 = @"idfCell2";
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:idfCell2];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:3];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = UIColor.clearColor;
            NSArray *rows = [sectionDict arrayForKey:@"rows"];
            
            for (int i = 0; i < rows.count && i < cell.labelArrayCell2.count; i++) {
                UILabel *lb = [cell.labelArrayCell2 objectAtIndex:i];
                
                NSDictionary *rowDict = [rows objectAtIndex:i];
//                lb.text = [rowDict stringForKey:@"title"];
                lb.attributedText = [self attStringWithString:[rowDict stringForKey:@"title"]];
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
                    lb.backgroundColor = kMAINCOLOR_BUTTON_BG;
                }
            }
        }
        
        return cell;
    }
    
    if (indexPath.section == 2) {
        NSDictionary *sectionDict = [_configArray objectAtIndex:indexPath.section];
        
        static NSString *idfCell3 = @"idfCell3";
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:idfCell3];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:4];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = UIColor.clearColor;
            
            NSArray *rows = [sectionDict arrayForKey:@"rows"];
            
            for (int i = 0; i < rows.count && i < cell.labelArrayCell3.count; i++) {
                UILabel *lb = [cell.labelArrayCell3 objectAtIndex:i];
                
                NSDictionary *rowDict = [rows objectAtIndex:i];
//                lb.text = [rowDict stringForKey:@"title"];
                lb.attributedText = [self attStringWithString:[rowDict stringForKey:@"title"]];
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
                    lb.backgroundColor = kMAINCOLOR_BUTTON_BG;
                }
            }
            
            if ([[rowDict stringForKey:@"title"] isEqualToString:InternationaString(@"Descarga finalizada")]) {
                _isZzfd = (index & (1<<value)) == (1<<value);
            }
        }
        
        return cell;
    }
    
    if (indexPath.section == 3) {
        NSDictionary *sectionDict = [_configArray objectAtIndex:indexPath.section];
        
        static NSString *idfCell4 = @"idfCell4";
        DetailCell *cell = (DetailCell *)[tableView dequeueReusableCellWithIdentifier:idfCell4];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:nil options:nil] objectAtIndex:5];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = UIColor.clearColor;
            
            NSArray *rows = [sectionDict arrayForKey:@"rows"];
            
            for (int i = 0; i < rows.count && i < cell.labelArrayCell4.count; i++) {
                UILabel *lb = [cell.labelArrayCell4 objectAtIndex:i];
                
                NSDictionary *rowDict = [rows objectAtIndex:i];
//                lb.text = [rowDict stringForKey:@"title"];
                lb.attributedText = [self attStringWithString:[rowDict stringForKey:@"title"]];
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
                    lb.backgroundColor = kMAINCOLOR_BUTTON_BG;
                }
            }
            
            if ([[rowDict stringForKey:@"title"] isEqualToString:InternationaString(@"Descarga finalizada")]) {
                // 取放电状态的数据
                NSDictionary *sDict = [_configArray objectAtIndex:3];
                int sIndex = [[sDict stringForKey:@"value"] intValue];
                NSArray *rs = [sDict arrayForKey:@"rows"];
                for (int j = 0; j < rs.count; j++) {
                    NSDictionary *rDict = [rs objectAtIndex:j];
                    if ([[rDict stringForKey:@"title"] isEqualToString:InternationaString(@"Descarga finalizada")]) {
                        int v = [[rDict stringForKey:@"value"] intValue];
                        if (v < 8) {
                            if ((sIndex & (1<<v)) == (1<<v)) {
                                lb.textColor = UIColor.whiteColor;
                                lb.backgroundColor = kMAINCOLOR_GREEN;
                            } else {
                                lb.textColor = UIColor.darkGrayColor;
                                lb.backgroundColor = kMAINCOLOR_BUTTON_BG;
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

- (NSAttributedString *)attStringWithString:(NSString *)string {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineSpacing = 0.0;
//    paragraphStyle.paragraphSpacing = 2.0f;
//    paragraphStyle.paragraphSpacingBefore = 0.0f;
    paragraphStyle.maximumLineHeight = 12.0f;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:string attributes:@{NSParagraphStyleAttributeName:paragraphStyle}];
    return attString;
}

- (void)loadDataSource {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    
    _configArray = @[@{@"title":InternationaString(@"Estado De Carga"), @"rows":@[@{@"title":InternationaString(@"Protección\nSobrecarga"), @"value":@"0"},
                                                                         @{@"title":InternationaString(@"Alta\nTemperatura"), @"value":@"1"},
                                                                         @{@"title":InternationaString(@"Baja\nTemperatura"), @"value":@"2"},
                                                                         @{@"title":InternationaString(@"Sobrecarga\nDe Celda"), @"value":@"3"},
                                                                         @{@"title":InternationaString(@"Sobrecarga\nBatería"), @"value":@"4"},
                                                                         @{@"title":InternationaString(@"MOS\nCargando"), @"value":@"7"}], @"value":device.cdzt ?: @"99"},
                       
                     @{@"title":InternationaString(@"Alertas De Carga"), @"rows":@[@{@"title":InternationaString(@"Corriente\nExcesiva"), @"value":@"0"},
                                                                         @{@"title":InternationaString(@"Alta\nTemperatura"), @"value":@"1"},
                                                                         @{@"title":InternationaString(@"Baja\nTemperatura"), @"value":@"2"},
                                                                         @{@"title":InternationaString(@"Balance\nDe Celdas"), @"value":@"3"},
                                                                         @{@"title":InternationaString(@"Totalmente\nCargada"), @"value":@"7"}], @"value":device.cdyj ?: @"99"},
                       
                     @{@"title":InternationaString(@"Estado De Descarga"), @"rows":@[@{@"title":InternationaString(@"Protección\nSobrecarga"), @"value":@"0"},
                                                                         @{@"title":InternationaString(@"Alta\nTemperatura"), @"value":@"1"},
                                                                         @{@"title":InternationaString(@"Baja\nTemperatura"), @"value":@"2"},
                                                                         @{@"title":InternationaString(@"Celda\nDescargada"), @"value":@"3"},
                                                                         @{@"title":InternationaString(@"Batería\nDescargada"), @"value":@"4"},
                                                                         @{@"title":InternationaString(@"Protección\nCortocircuito"), @"value":@"5"},
                                                                         /*@{@"title":InternationaString(@"Descarga finalizada"), @"value":@"6"},*/
                                                                         @{@"title":InternationaString(@"MOS\nDescargando"), @"value":@"7"}], @"value":device.fdzt ?: @"99"},
                       
                     @{@"title":InternationaString(@"Discharge Warning"), @"rows":@[@{@"title":InternationaString(@"Corriente\nExcesiva"), @"value":@"0"},
                                                                         @{@"title":InternationaString(@"Alta\nTemperatura"), @"value":@"1"},
                                                                         @{@"title":InternationaString(@"Baja\nTemperatura"), @"value":@"2"},
                                                                         @{@"title":InternationaString(@"Balance\nDe Celdas"), @"value":@"3"},
                                                                         @{@"title":InternationaString(@"Tiempo Restante\nInsuficiente"), @"value":@"4"},
                                                                         /*@{@"title":InternationaString(@"Descarga finalizada"), @"value":@"99"},*/
                                                                         @{@"title":InternationaString(@"Celda\nDescargada"), @"value":@"6"},
                                                                         @{@"title":InternationaString(@"Capacidad Restante\nInsuficiwente"), @"value":@"5"},
                                                                         @{@"title":InternationaString(@"Batería\nDescargada"), @"value":@"7"}], @"value":device.fdyj ?: @"99"}];
}

- (void)setUI {
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.sectionFooterHeight = 0.0;
    self.tableView.sectionHeaderHeight = 0.0;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
