//
//  WKWebViewController.m
//  WKWebViewOC
//
//  Created by XiaoFeng on 2016/11/24.
//  Copyright © 2016年 XiaoFeng. All rights reserved.
//  QQ群: 384089763 欢迎加入
//  github链接: https://github.com/XFIOSXiaoFeng/WKWebView


#import "WKWebViewController.h"

#define WKNavBarHeight 44.0
#define WKStatusBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define WKTopHeight (WKStatusBarHeight + WKNavBarHeight)
#define WKSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define WKSCREENH_HEIGHT [UIScreen mainScreen].bounds.size.height

typedef enum{
    loadWebURLString = 0,
    loadWebHTMLString,
    POSTWebURLString,
}wkWebLoadType;

static void *WkwebBrowserContext = &WkwebBrowserContext;

@interface WKWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,UINavigationControllerDelegate,UINavigationBarDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;
//设置加载进度条
@property (nonatomic,strong) UIProgressView *progressView;
//仅当第一次的时候加载本地JS
@property(nonatomic,assign) BOOL needLoadJSPOST;
//网页加载的类型
@property(nonatomic,assign) wkWebLoadType loadType;
//保存的网址链接
@property (nonatomic, copy) NSString *URLString;
//保存POST请求体
@property (nonatomic, copy) NSString *postData;
//保存请求链接
@property (nonatomic)NSMutableArray* snapShotsArray;
//返回按钮
@property (nonatomic)UIBarButtonItem* customBackBarItem;
//关闭按钮
@property (nonatomic)UIBarButtonItem* closeButtonItem;

// _G.R.M.  重定向到下级目录
@property (nonatomic, copy) NSString *redirectURLString;

@end

@implementation WKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //加载web页面
    [self webViewloadURLType];
    
    //添加到主控制器上
    [self.view addSubview:self.wkWebView];
    
    //添加进度条
    [self.view addSubview:self.progressView];
    
    
    if (!self.isFirstPage) {
        //添加右边刷新按钮
        UIBarButtonItem *roadLoad = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(roadLoadClicked)];
        self.navigationItem.rightBarButtonItem = roadLoad;
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.isFirstPage) {
//        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    _wkWebView.scrollView.delegate = self;
    
    if (_isNavHidden == YES) {
        self.navigationController.navigationBarHidden = YES;
        //创建一个假状态栏
        UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, WKStatusBarHeight)];
        //设置成绿色
        statusBarView.backgroundColor=[UIColor whiteColor];
        // 添加到 navigationBar 上
        [self.view addSubview:statusBarView];
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)roadLoadClicked{
    [self.wkWebView reload];
}

-(void)customBackItemClicked {
    
    if (self.wkWebView.canGoBack &&
        !self.redirectURLString.length) {
        
        [self.wkWebView goBack];
        
        if (self.wkWebView.backForwardList.backList.count == 1) {
            self.navigationItem.leftBarButtonItems = nil;
            self.navigationItem.rightBarButtonItems = nil;
            
        }
        else {
            [self updateNavigationItems];
        }
        
    } else {
        
        if (self.isFirstPage) {
            [self updateNavigationItems];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}
-(void)closeItemClicked {
    
    if (self.isFirstPage) {
        
        WKBackForwardListItem *fItem = [self.wkWebView.backForwardList.backList firstObject];
        if (fItem) {
            [self.wkWebView goToBackForwardListItem:fItem];
        }
        
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = nil;
        
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark ================ 加载方式 ================

- (void)webViewloadURLType{
    switch (self.loadType) {
        case loadWebURLString:{
            //创建一个NSURLRequest 的对象
            NSMutableURLRequest *Request_zsj = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.URLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
            if (self.appendHTTPHeader) {
                
                NSArray *arr = [self.appendHTTPHeader allKeys];
                for (NSString *key in arr) {
                    [Request_zsj addValue:[self.appendHTTPHeader stringForKey:key] forHTTPHeaderField:key];
                }
            }
            
            if (self.appendHTTPBody) {
                Request_zsj.HTTPBody = [self.appendHTTPBody dataUsingEncoding:NSUTF8StringEncoding];
            }
//            NSURLRequest * Request_zsj = [NSURLRequest requestWithURL:[NSURL URLWithString:self.URLString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
//             [Request_zsj addValue:[GlobalDatatoken] forHTTPHeaderField:@"token"];
            
            //加载网页
            [self.wkWebView loadRequest:Request_zsj];
            break;
        }
        case loadWebHTMLString:{
            [self loadHostPathURL:self.URLString];
            break;
        }
        case POSTWebURLString:{
            // JS发送POST的Flag，为真的时候会调用JS的POST方法
            self.needLoadJSPOST = YES;
            //POST使用预先加载本地JS方法的html实现，请确认WKJSPOST存在
            [self loadHostPathURL:@"WKJSPOST"];
            break;
        }
    }
}

- (void)loadHostPathURL:(NSString *)url{
    //获取JS所在的路径
    NSString *path = [[NSBundle mainBundle] pathForResource:url ofType:@"html"];
    //获得html内容
    NSString *html = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    //加载js
    [self.wkWebView loadHTMLString:html baseURL:[[NSBundle mainBundle] bundleURL]];
}

// 调用JS发送POST请求
- (void)postRequestWithJS {
    // 拼装成调用JavaScript的字符串
    NSString *jscript = [NSString stringWithFormat:@"post('%@',{%@});", self.URLString, self.postData];
    // 调用JS代码
    [self.wkWebView evaluateJavaScript:jscript completionHandler:^(id object, NSError * _Nullable error) {
    }];
}


- (void)loadWebURLSring:(NSString *)string{
    self.URLString = string;
    self.loadType = loadWebURLString;
}
- (void)loadWebURLSring:(NSString *)string redirectURLString:(NSString *)redirectString {
    self.URLString = string;
    self.redirectURLString = redirectString;
    self.loadType = loadWebURLString;
}

- (void)loadWebHTMLSring:(NSString *)string{
    self.URLString = string;
    self.loadType = loadWebHTMLString;
}

- (void)POSTWebURLSring:(NSString *)string postData:(NSString *)postData{
    self.URLString = string;
    self.postData = postData;
    self.loadType = POSTWebURLString;
}

//#pragma mark   ============== URL pay 开始支付 ==============
//
//- (void)payWithUrlOrder:(NSString*)urlOrder
//{
//    if (urlOrder.length > 0) {
//        __weak XFWkwebView* wself = self;
//        [[AlipaySDK defaultService] payUrlOrder:urlOrder fromScheme:@"giftcardios" callback:^(NSDictionary* result) {
//            // 处理支付结果
//            NSLog(@"===============%@", result);
//            // isProcessUrlPay 代表 支付宝已经处理该URL
//            if ([result[@"isProcessUrlPay"] boolValue]) {
//                // returnUrl 代表 第三方App需要跳转的成功页URL
//                NSString* urlStr = result[@"returnUrl"];
//                [wself loadWithUrlStr:urlStr];
//            }
//        }];
//    }
//}
//
//- (void)WXPayWithParam:(NSDictionary *)WXparam{
//
//}
////url支付成功回调地址
//- (void)loadWithUrlStr:(NSString*)urlStr
//{
//    if (urlStr.length > 0) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSURLRequest *webRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestReturnCacheDataElseLoad
//                                                    timeoutInterval:15];
//            [self.wkWebView loadRequest:webRequest];
//        });
//    }
//}

#pragma mark ================ 自定义返回/关闭按钮 ================

-(void)updateNavigationItems {
    
    if (self.wkWebView.canGoBack) {
        
        if (self.isFirstPage) {
            self.navigationItem.leftBarButtonItems = nil;
            self.navigationItem.rightBarButtonItems = nil;
        }
        
        
//        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//        spaceButtonItem.width = -6.5;
        [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem,self.closeButtonItem] animated:NO];
        
        
        //添加右边刷新按钮
        UIBarButtonItem *roadLoad = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(roadLoadClicked)];
        self.navigationItem.rightBarButtonItem = roadLoad;
    }
    else {
        
        if (self.isFirstPage) {
            self.navigationItem.leftBarButtonItems = nil;
            self.navigationItem.rightBarButtonItems = nil;
        }
        else {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
            [self.navigationItem setLeftBarButtonItems:@[self.customBackBarItem]];
        }
        
    }
    
}
//请求链接处理
-(void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request{
    //    NSLog(@"push with request %@",request);
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    
    //如果url是很奇怪的就不push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        //        NSLog(@"about blank!! return");
        return;
    }
    //如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    UIView* currentSnapShotView = [self.wkWebView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:
     @{@"request":request,@"snapShotView":currentSnapShotView}];
}

#pragma mark self.isFirstPage = YES  Navigation Recognizer --> self
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (self.wkWebView.backForwardList.backList.count == 1) {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItems = nil;
    }
    else {
        [self updateNavigationItems];
    }
    
    return YES;
}

#pragma mark ================ WKNavigationDelegate ================

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler {
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential, card);
    }
    else {
        NSURLCredential *card = [[NSURLCredential alloc] initWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
        completionHandler(NSURLSessionAuthChallengeUseCredential, card);
    }

}

//这个是网页加载完成，导航的变化
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    /*
     主意：这个方法是当网页的内容全部显示（网页内的所有图片必须都正常显示）的时候调用（不是出现的时候就调用），，否则不显示，或则部分显示时这个方法就不调用。
     */
    // 判断是否需要加载（仅在第一次加载）
    if (self.needLoadJSPOST) {
        // 调用使用JS发送POST请求的方法
        [self postRequestWithJS];
        // 将Flag置为NO（后面就不需要加载了）
        self.needLoadJSPOST = NO;
    }
    // 获取加载网页的标题
    if (self.isFirstPage) {
        if (self.wkWebView.backForwardList.backList.count == 0) {
            self.navigationItem.title = self.wkWebView.title;
        }
    }
    else {
        if (!self.title.length) {
            self.navigationItem.title = self.wkWebView.title;
        }
    }
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
    
    
//    // 禁止放大缩小
//    NSString *injectionJSString = @"var script = document.createElement('meta');"
//    "script.name = 'viewport';"
//    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
//    "document.getElementsByTagName('head')[0].appendChild(script);";
//    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
}

//开始加载
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载的时候，让加载进度条显示
    self.progressView.hidden = NO;
    
//    // 禁止放大缩小
//    NSString *injectionJSString = @"var script = document.createElement('meta');"
//    "script.name = 'viewport';"
//    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
//    "document.getElementsByTagName('head')[0].appendChild(script);";
//    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
}

//内容返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
    if (self.didCommitBlock) {
        self.didCommitBlock(webView);
    }
    
    if (self.appendHTTPHeader &&
        self.redirectURLString.length) {
        self.appendHTTPHeader = nil;
        self.appendHTTPBody = nil;
        
        // 加载重定向地址
        [self loadWebURLSring:self.redirectURLString];
        [self webViewloadURLType];
    }
    
    // 禁止放大缩小
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
}

//服务器请求跳转的时候调用
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{}

//服务器开始请求的时候调用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    NSString* orderInfo = [[AlipaySDK defaultService]fetchOrderInfoFromH5PayUrl:[navigationAction.request.URL absoluteString]];
//    if (orderInfo.length > 0) {
//        [self payWithUrlOrder:orderInfo];
//    }
//    //拨打电话
//    //兼容安卓的服务器写法:<a class = "mobile" href = "tel://电话号码"></a>
//    NSString *mobileUrl = [[navigationAction.request URL] absoluteString];
//    mobileUrl = [mobileUrl stringByRemovingPercentEncoding];
//    NSArray *urlComps = [mobileUrl componentsSeparatedByString:@"://"];
//    if ([urlComps count]){
//        
//        if ([[urlComps objectAtIndex:0] isEqualToString:@"tel"]) {
//            
//            UIAlertController *mobileAlert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"拨号给 %@ ？",urlComps.lastObject] preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *suerAction = [UIAlertAction actionWithTitle:@"拨号" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mobileUrl]];
//            }];
//            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//                return ;
//            }];
//            
//            [mobileAlert addAction:suerAction];
//            [mobileAlert addAction:cancelAction];
//            
//            [self presentViewController:mobileAlert animated:YES completion:nil];
//        }
//    }
    
    
    switch (navigationAction.navigationType) {
        case WKNavigationTypeLinkActivated: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        case WKNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        case WKNavigationTypeBackForward: {
            break;
        }
        case WKNavigationTypeReload: {
            break;
        }
        case WKNavigationTypeFormResubmitted: {
            break;
        }
        case WKNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:navigationAction.request];
            break;
        }
        default: {
            break;
        }
    }
    [self updateNavigationItems];
    
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

// 内容加载失败时候调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"页面加载超时");
}

//跳转失败的时候调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{}

//进度条
-(void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{}

#pragma mark ================ WKUIDelegate ================

// 获取js 里面的提示
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

// js 信息的交流
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

// 交互。可输入的文本。
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"JS调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    
}

//KVO监听进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        
        // Once complete, fade out UIProgressView
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark ================ WKScriptMessageHandler ================

//拦截执行网页中的JS方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{

    //服务器固定格式写法 window.webkit.messageHandlers.名字.postMessage(内容);
    //客户端写法 message.name isEqualToString:@"名字"]
    if ([message.name isEqualToString:@"WXPay"]) {
        NSLog(@"%@", message.body);
        //调用微信支付方法
//        [self WXPayWithParam:message.body];
    }
}

#pragma mark ================ 懒加载 ================

- (WKWebView *)wkWebView{
    if (!_wkWebView) {
        //设置网页的配置文件
        WKWebViewConfiguration * Configuration = [[WKWebViewConfiguration alloc]init];
        //允许视频播放
        Configuration.allowsAirPlayForMediaPlayback = YES;
        // 允许在线播放
        Configuration.allowsInlineMediaPlayback = YES;
        // 允许可以与网页交互，选择视图
        Configuration.selectionGranularity = YES;
        // web内容处理池
        Configuration.processPool = [[WKProcessPool alloc] init];
        //自定义配置,一般用于 js调用oc方法(OC拦截URL中的数据做自定义操作)
        WKUserContentController * UserContentController = [[WKUserContentController alloc]init];
        // 添加消息处理，注意：self指代的对象需要遵守WKScriptMessageHandler协议，结束时需要移除
        [UserContentController addScriptMessageHandler:self name:@"WXPay"];
        // 是否支持记忆读取
        Configuration.suppressesIncrementalRendering = YES;
        
        // 禁止缩放
        NSString *injectionJSString = @"var script = document.createElement('meta');"
        "script.name = 'viewport';"
        "script.content=\"width=device-width, user-scalable=no\";"
        "document.getElementsByTagName('head')[0].appendChild(script);";
        WKUserScript *script = [[WKUserScript alloc] initWithSource:injectionJSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [UserContentController addUserScript:script];
        
        
        // 允许用户更改网页的设置
        Configuration.userContentController = UserContentController;
        
        
//        NSString *injectionJSString = @"var script = document.createElement('meta');"
//            "script.name = 'viewport';"
//            "script.content=\"width=device-width, user-scalable=no\";"
//            "document.getElementsByTagName('head')[0].appendChild(script);";
//        [webView evaluateJavaScript:injectionJSString completionHandler:nil];
        
        
        CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREENH_HEIGHT-kTopHeight);
        _wkWebView = [[WKWebView alloc] initWithFrame:rect configuration:Configuration];
        _wkWebView.backgroundColor = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
        _wkWebView.scrollView.bounces = NO;
        // 设置代理
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        _wkWebView.scrollView.delegate = self;
        //kvo 添加进度监控
        [_wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:WkwebBrowserContext];
        //开启手势触摸
        _wkWebView.allowsBackForwardNavigationGestures = YES;
        // 设置 可以前进 和 后退
        //适应你设定的尺寸
        [_wkWebView sizeToFit];
    }
    return _wkWebView;
}

-(UIBarButtonItem*)customBackBarItem{
    if (!_customBackBarItem) {
        UIImage* backItemImage = [[UIImage imageNamed:InternationaString(@"backItemImage")] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* backItemHlImage = [[UIImage imageNamed:InternationaString(@"backItemImage-hl")] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton* backButton = [[UIButton alloc] init];
        [backButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [backButton setTitle:InternationaString(@"Return") forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customBackBarItem;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        if (_isNavHidden == YES) {
            _progressView.frame = CGRectMake(0, kStatusBarHeight, self.view.bounds.size.width, 3);
        }else{
            _progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 3);
        }
        // 设置进度条的色彩
        [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0]];
        _progressView.progressTintColor = [UIColor greenColor];
    }
    return _progressView;
}

-(UIBarButtonItem*)closeButtonItem{
    if (!_closeButtonItem) {
        _closeButtonItem = [[UIBarButtonItem alloc] initWithTitle:InternationaString(@"Cerrar") style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked)];
    }
    return _closeButtonItem;
}

-(NSMutableArray*)snapShotsArray{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}

- (void)setIsFirstPageWithObject:(NSNumber *)object {
    self.isFirstPage = [object boolValue];
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"WXPay"];
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

//注意，观察的移除
-(void)dealloc{
    [_wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

@end
