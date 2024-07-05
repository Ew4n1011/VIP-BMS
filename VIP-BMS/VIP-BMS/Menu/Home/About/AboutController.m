//
//  AboutController.m
//  VIP-BMS
//
//  Created by _G.R.M. on 2021/11/13.
//  Copyright © 2021 goorume. All rights reserved.
//

#import "AboutController.h"
#import "WKWebViewController.h"

@interface AboutController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLb;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation AboutController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topView.backgroundColor = kMAINCOLOR_FRONT;
    
    self.backgroundView.layer.shadowColor = [UIColor colorWithRed:8/255.0 green:10/255.0 blue:11/255.0 alpha:0.05].CGColor;
    self.backgroundView.layer.shadowOffset = CGSizeMake(0,2);
    self.backgroundView.layer.shadowOpacity = 1;
    self.backgroundView.layer.shadowRadius = 5;
    self.backgroundView.layer.cornerRadius = 8;
    
    self.mainLabel.text = InternationaString(@"Me Energy,  soluciones   globales en  sistemas  de  energía.  Me Energy,  comprometidos con  la  sostenibilidad   del  pIaneta  Baterías AGM / GEL Baterías Litio  Paneles solares  www.me-energy.eu me@me-energy.eu");
    
    self.versionLb.text = InternationaString(@"Version");
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.versionLabel.text = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
}

- (IBAction)toPrivacyAction:(UIButton *)sender {
    WKWebViewController *vc = [[WKWebViewController alloc] init];
    vc.title = InternationaString(@"Política de privacidad");
    [vc loadWebURLSring:@"https://www.bornay.com/es/cms/politica-de-privacidad-app"];
    [self.navigationController pushViewController:vc animated:YES];
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
