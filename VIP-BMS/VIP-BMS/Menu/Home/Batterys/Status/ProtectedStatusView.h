//
//  ProtectedStatusView.h
//  VIP-BMS
//
//  Created by _G.R.M. on 2021/3/4.
//  Copyright © 2021 goorume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VIP-BMS-pch.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProtectedStatusView : UIView<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

NS_ASSUME_NONNULL_END
