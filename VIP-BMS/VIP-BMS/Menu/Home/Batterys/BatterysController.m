//
//  BatterysController.m
//  VIP-BMS
//
//  Created by goorume on 2020/4/26.
//  Copyright © 2020 goorume. All rights reserved.
//

#import "BatterysController.h"

#import "BatteryView.h"
#import "BatteryInfoView.h"
#import "ProtectedStatusView.h"

@interface BatterysController ()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *dtzxdyLb;
@property (weak, nonatomic) IBOutlet UILabel *dtzddyLb;
@property (weak, nonatomic) IBOutlet UILabel *ycLb;
@property (weak, nonatomic) IBOutlet UILabel *dtzxdyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dtzddyLabel;
@property (weak, nonatomic) IBOutlet UILabel *ycLabel;


@end

@implementation BatterysController {
    NSMutableArray *_dataSource;
    NSMutableArray *_batteryViews;
    
    NSMutableArray *_minIndexArray;
    NSMutableArray *_maxIndexArray;
    
    UIView *_headerView;
    
    UIView *_infoBgView;
    NSMutableArray *_infoArray;
    NSMutableArray *_infoViews;
    
    CGFloat _contentHeight;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:InternationaString(@"Información") style:UIBarButtonItemStylePlain target:nil action:nil];
    
    UIButton *rightButton = [[UIButton alloc] init];
    rightButton.titleLabel.font = [UIFont systemFontOfSize:13.0f];
    [rightButton setTitle:InternationaString(@"Alertas") forState:UIControlStateNormal];
    [rightButton setImage:ImageNamed(@"alertas_normal") forState:UIControlStateNormal];
    [rightButton setImage:ImageNamed(@"alertas_highlighted") forState:UIControlStateHighlighted];
    [rightButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [rightButton setTitleColor:UIColor.whiteColor forState:UIControlStateHighlighted];
    [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [rightButton addTarget:self action:@selector(protectedStatus:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    [self loadDataSource];
    
    [self setUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDevice) name:NotificationUpdateDevice object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 保护状态
- (void)protectedStatus:(UIButton *)sender {
    ProtectedStatusView *view = [[[NSBundle mainBundle] loadNibNamed:@"ProtectedStatusView" owner:nil options:nil] firstObject];
    CGFloat h = 612; // 582
    if (SCREENH_HEIGHT-40*2 < h) {
        h = SCREENH_HEIGHT-40*2;
    }
    view.bounds = CGRectMake(0, 0, SCREEN_WIDTH-20*2, h);
    view.layer.cornerRadius = 8.0f;
    view.layer.masksToBounds = YES;
    view.titleLabel.text = InternationaString(@"Alertas");
    [GRMAlertManager showAlertView:view configClickEvent:^NSArray *(UIView *alert) {
        return @[view.closeButton];
    } didSelectedBlock:^(NSInteger index, UIView *alert) {
        
    }];
}

- (void)updateDevice {
    [self loadDataSource];
    [self setUI];
}

- (void)loadDataSource {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    
    NSUInteger allCount = [BTM.device.dccs integerValue] + [BTM.device.dccs2 integerValue]; // 总串数
    // 章节电压
    _dataSource = [NSMutableArray array];
    [_dataSource addObjectsFromArray:device.voltage12Array];
    [_dataSource addObjectsFromArray:device.voltage24Array];
    if (device.deviceType == Device_20) {
        // 2.0版本协议
        [_dataSource addObjectsFromArray:device.voltage32Array];
    }
    
    // 从末尾开始移除大于总串数的电压值
    if (_dataSource.count > allCount) {
        NSInteger removeCount = _dataSource.count - allCount;
        for (int i = 0; i < removeCount; i++) {
            [_dataSource removeLastObject];
        }
    }
    
    _minIndexArray = [NSMutableArray array];
    _maxIndexArray = [NSMutableArray array];
    NSUInteger minVoltage = ULONG_MAX;
    NSUInteger maxVoltage = 0;
    for (NSInteger i = 0; i < _dataSource.count; i++) {
        NSNumber *num = [_dataSource objectAtIndex:i];
        if ([num unsignedIntegerValue] < minVoltage) {
            minVoltage = [num unsignedIntegerValue];
            [_minIndexArray removeAllObjects];
            [_minIndexArray addObject:@(i)];
        } else if ([num unsignedIntegerValue] == minVoltage) {
            [_minIndexArray addObject:@(i)];
        }

        if ([num unsignedIntegerValue] > maxVoltage) {
            maxVoltage = [num unsignedIntegerValue];
            [_maxIndexArray removeAllObjects];
            [_maxIndexArray addObject:@(i)];
        } else if ([num unsignedIntegerValue] == maxVoltage) {
            [_maxIndexArray addObject:@(i)];
        }
    }
    
    // 详细参数
    NSString *csString = [NSString stringWithFormat:@"%@", device.fdcs ?: @"0"];
    NSString *tmp = @"0";
    tmp = [NSString stringWithFormat:@"%.3f", maxVoltage/1000.0];
    NSString *maxString = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
    tmp = [NSString stringWithFormat:@"%.3f", minVoltage/1000.0];
    NSString *minString = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
    tmp = [NSString stringWithFormat:@"%.3f", (maxVoltage-minVoltage)/1000.0];
    NSString *subString = [NSString stringWithFormat:@"%@V", @([tmp floatValue])];
    _infoArray = @[@{@"title":InternationaString(@"Fecha de\nfabricación"), @"image":@"scrq", @"value":device.scrq ?: @"1970.01.01"},
                   @{@"title":InternationaString(@"Voltaje de\ndiseño"), @"image":@"sjdy", @"value":device.sjdy ?: @"0mV"},
                   @{@"title":InternationaString(@"Capacidad\nreal"), @"image":@"sjrl", @"value":device.mcrl ?: @"0mAh"},
                   @{@"title":InternationaString(@"Ciclos de\nvida"), @"image":@"xh", @"value":csString},
                   @{@"title":InternationaString(@"Voltaje max."), @"image":@"djzddy", @"value":maxString},
                   @{@"title":InternationaString(@"Voltaje mín."), @"image":@"djzxdy", @"value":minString},
                   @{@"title":InternationaString(@"Diferencia"), @"image":@"yacha", @"value":subString}].mutableCopy;
}

- (void)setUI {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    
    if (_infoViews.count == _infoArray.count) {
        for (int i = 0; i < _infoViews.count; i++) {
            BatteryInfoView *bi = [_infoViews objectAtIndex:i];
            NSDictionary *info = [_infoArray objectAtIndex:i];
            
            bi.valueLabel.text = info[@"value"];
        }
    } else {
        if (_infoBgView) {
            [_infoBgView removeFromSuperview];
        }
        
        for (UIView *v in _infoViews) {
            [v removeFromSuperview];
        }
        
        _contentHeight = 0.0f;
        [self initInfoViews];
    }
    
    if (!_headerView) {
        CGFloat gap = 15;
        
        UIView *lastView = nil;
        if (_infoViews.count) {
            lastView = _infoViews.lastObject;
        }
        
        BatteryInfoView *header = [[[NSBundle mainBundle] loadNibNamed:@"BatteryInfoView" owner:nil options:nil] lastObject];
        header.titLabel.text = InternationaString(@"Voltaje de celdas (mV)");
        [self.bgView addSubview:header];
        [header mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.top.equalTo(lastView.mas_bottom).with.offset(15 + gap);
            } else {
                make.top.with.offset(15);
            }
            make.leading.trailing.with.offset(0);
            make.height.mas_equalTo(25);
        }];
        
        _headerView = header;
        
        _contentHeight += 25;
    }
    
    if (_batteryViews.count == _dataSource.count) {
        for (int i = 0; i < _batteryViews.count; i++) {
            BatteryView *b  = [_batteryViews objectAtIndex:i];
            NSNumber *value = [_dataSource objectAtIndex:i];
            
            b.valueLabel.text = [NSString stringWithFormat:@"%umV", [value unsignedIntegerValue]];
            
            if ([_minIndexArray containsObject:@(i)]) {
                b.imageView.image = ImageNamed(@"dcdy2");
            } else if ([_maxIndexArray containsObject:@(i)]) {
                b.imageView.image = ImageNamed(@"dcdy3");
            } else {
                b.imageView.image = ImageNamed(@"dcdy1");
            }
            
            if (device.deviceType == Device_20 && i < 32) {
                // 2.0版本协议, 支持显示均衡状态, 最大支持 32 串电池
                if ([device.jhzt integerValue] & (1<<i)) {
                    b.jhztImageView.hidden = NO;
                } else {
                    b.jhztImageView.hidden = YES;
                }
            }
        }
    } else {
        for (UIView *v in _batteryViews) {
            [v removeFromSuperview];
        }
        
        [self initBatteryViews];
    }
}

- (void)initInfoViews {
    CGFloat gap = 15;
    CGFloat offset_x = 0;
    CGFloat offset_y = 0;
    CGFloat ww = (SCREEN_WIDTH - gap*2)/4.0;
    CGFloat hh = 82.0;
    
    if (!_infoBgView) {
        _infoBgView = [[UIView alloc] init];
        _infoBgView.backgroundColor = UIColor.whiteColor;
        _infoBgView.layer.shadowColor = [UIColor colorWithRed:8/255.0 green:10/255.0 blue:11/255.0 alpha:0.1].CGColor;
        _infoBgView.layer.shadowOffset = CGSizeMake(0,2);
        _infoBgView.layer.shadowOpacity = 1;
        _infoBgView.layer.shadowRadius = 5;
        _infoBgView.layer.cornerRadius = 4;
        [self.bgView addSubview:_infoBgView];
    }
    
    _infoViews = [NSMutableArray array];
    for (NSInteger i = 0; i < _infoArray.count; i++) {
        offset_x = gap + (i%4)*ww;
        offset_y = gap + (i/4)*hh;
        
        BatteryInfoView *b = [[[NSBundle mainBundle] loadNibNamed:@"BatteryInfoView" owner:nil options:nil] firstObject];
        [self.bgView addSubview:b];
        [b mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(offset_y);
            make.left.offset(offset_x);
            make.width.mas_equalTo(ww);
//            make.size.mas_equalTo(CGSizeMake(ww, hh));
        }];
        
        NSDictionary *info = [_infoArray objectAtIndex:i];
        b.imageView.image = ImageNamed(info[@"image"]);
        b.titleLabel.text = info[@"title"];
        b.valueLabel.text = info[@"value"];
        [b.titleLabel setPreferredMaxLayoutWidth:SCREEN_WIDTH/4.0-6*2];
        
        [_infoViews addObject:b];
    }
    
    CGFloat resetOffset_y = gap;
    CGFloat maxHeight = 0.0f;
    for (int i = 0; i < _infoViews.count; i++) {
        BatteryInfoView *b = [_infoViews objectAtIndex:i];
        CGFloat height = [b systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
        if (height > maxHeight) {
            maxHeight = height;
        }
        if ((i+1)%4 == 0) {
            for (int j = i; i-j < 4; j--) {
                BatteryInfoView *sub = [_infoViews objectAtIndex:j];
                [sub mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.offset(resetOffset_y);
                    make.height.mas_equalTo(maxHeight);
                }];
            }
            resetOffset_y += maxHeight;
            maxHeight = 0.0f;
        } else {
            if (i == _infoViews.count-1) {
                for (int j = i; i-j < _infoViews.count%4; j--) {
                    BatteryInfoView *sub = [_infoViews objectAtIndex:j];
                    [sub mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.top.offset(resetOffset_y);
                        make.height.mas_equalTo(maxHeight);
                    }];
                }
                resetOffset_y += maxHeight;
                maxHeight = 0.0f;
            }
        }
    }
    
    _contentHeight += resetOffset_y;
    
    [_infoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.with.offset(15);
        make.leading.with.offset(15);
        make.trailing.with.offset(-15);
        make.height.mas_equalTo(_contentHeight);
    }];
}

- (void)initBatteryViews {
    GRMDevice *device = [GRMBluetoothManager sharedGRMBluetoothManager].device;
    
    NSInteger countPerRow = 2;
    CGFloat offset_x = 0;
    CGFloat offset_y = 0;
    CGFloat ww = SCREEN_WIDTH/(CGFloat)countPerRow;
    CGFloat hh = 34.0f;
    
//    NSInteger flag = -1;
    
    _batteryViews = [NSMutableArray array];
    for (NSInteger i = 0; i < _dataSource.count; i++) {
        offset_x = (i%countPerRow)*ww;
        offset_y = (i/countPerRow)*hh;
        
//        if (i%4 == 0) {
//            UIView *v = [[UIView alloc] init];
//            [self.bgView addSubview:v];
//            [v mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(_headerView.mas_bottom).with.offset(offset_y);
//                make.left.offset(0);
//                make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, hh));
//            }];
//
//            v.backgroundColor = flag < 0 ? kMAINCOLOR_BG : UIColor.whiteColor;
//            flag = -1 * flag;
//        }
        
        
        BatteryView *b = [[[NSBundle mainBundle] loadNibNamed:@"BatteryView" owner:nil options:nil] firstObject];
        b.numberLabel.text = [NSString stringWithFormat:@"Celda %ld", i+1];
        [self.bgView addSubview:b];
        [b mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_headerView.mas_bottom).with.offset(offset_y);
            make.left.offset(offset_x);
            make.size.mas_equalTo(CGSizeMake(ww, hh));
        }];
        
        NSNumber *value = [_dataSource objectAtIndex:i];
        b.valueLabel.text = [NSString stringWithFormat:@"%umV", [value unsignedIntegerValue]];
        
        [_batteryViews addObject:b];
        
        
        if ([_minIndexArray containsObject:@(i)]) {
            b.imageView.image = ImageNamed(@"dcdy2");
        } else if ([_maxIndexArray containsObject:@(i)]) {
            b.imageView.image = ImageNamed(@"dcdy3");
        } else {
            b.imageView.image = ImageNamed(@"dcdy1");
        }
        
        if (device.deviceType == Device_20 && i < 32) {
            // 2.0版本协议, 支持显示均衡状态, 最大支持 32 串电池
            if ([device.jhzt integerValue] & (1<<i)) {
                b.jhztImageView.hidden = NO;
            } else {
                b.jhztImageView.hidden = YES;
            }
        }
    }
    
    _contentHeight += ((_batteryViews.count+countPerRow-1)/countPerRow)*hh;
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(_contentHeight);
    }];
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
