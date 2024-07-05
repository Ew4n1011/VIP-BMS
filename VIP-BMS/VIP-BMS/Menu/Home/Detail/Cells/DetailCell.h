//
//  DetailCell.h
//  VIP-BMS
//
//  Created by goorume on 2020/4/27.
//  Copyright © 2020 goorume. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailCell : UITableViewCell

// header
@property (weak, nonatomic) IBOutlet UILabel *titLabel;

// cell0
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@property (weak, nonatomic) IBOutlet UIView *line;


@property (weak, nonatomic) IBOutlet UILabel *lb0;
@property (weak, nonatomic) IBOutlet UILabel *lb1;
@property (weak, nonatomic) IBOutlet UILabel *lb2;
@property (weak, nonatomic) IBOutlet UILabel *lb3;
@property (weak, nonatomic) IBOutlet UILabel *lb4;
@property (weak, nonatomic) IBOutlet UILabel *lb5;
@property (weak, nonatomic) IBOutlet UILabel *lb6;
@property (weak, nonatomic) IBOutlet UILabel *lb7;
@property (weak, nonatomic) IBOutlet UILabel *lb8;


@property (nonatomic, strong) NSArray<UILabel *> *labelArrayCell1;
@property (nonatomic, strong) NSArray<UILabel *> *labelArrayCell2;
@property (nonatomic, strong) NSArray<UILabel *> *labelArrayCell3;
@property (nonatomic, strong) NSArray<UILabel *> *labelArrayCell4;

@end

NS_ASSUME_NONNULL_END
