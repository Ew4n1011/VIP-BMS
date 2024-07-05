//
//  BaseTableViewController.h
//  DoorLock
//
//  Created by G.R.M. on 2017/7/26.
//  Copyright © 2017年 lokfu. All rights reserved.
//

#import "BaseViewController.h"

// info 返回数据         needUpdata 是否需要更新数据、UI
typedef void(^TCCallBack)(NSDictionary *info, BOOL needUpdata);
typedef void(^LayerTableView)(UITableView *tableView, UIView *superView);

@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) BOOL plainStyle;


/** 更新回调 */
@property (nonatomic, copy) TCCallBack callBack;

/** 重置 tableView 布局 */
@property (nonatomic, copy) LayerTableView layerTableView;



// 使用 FooterView 配置页面
- (UIView *)configFooterViewAppenHeight:(CGFloat)addHeight;     // FooterView高度为 SCREEN_HEIGHT-navH + addHeight
- (UIView *)configFooterViewWithHeight:(CGFloat)height;         // FooterView高度为 height


@end
