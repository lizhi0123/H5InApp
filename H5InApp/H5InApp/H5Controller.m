//
//  H5Controller.m
//  H5InApp
//
//  Created by Sunny on 12/4/19.
//  Copyright © 2019年 Sunny. All rights reserved.
//

#import "H5Controller.h"
#import <WebKit/WebKit.h>

@interface H5Controller ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (strong, nonatomic) WKWebView *wkWebView;
@property (weak, nonatomic) IBOutlet UIView *topTitleView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UILabel *topTitleLbl;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, strong) WKWebViewConfiguration *wkConfig;

@end

#define kBackToLastPage @"BackToLastPage"

@implementation H5Controller

-(void)setTitle:(NSString *)title{
    [super setTitle:title];
    self.topTitleLbl.text = title;
}

-(instancetype)initWithUrl:(NSString *)url{
    self = [self init];
    if (self) {
        self.url  = url;
        //        self.isReloadWhenViewWillAppear  = YES;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"";
    self.navigationController.navigationBarHidden  = YES;
    // Do any additional setup after loading the view.
    [self setupWebView];
    
    
    [self startLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self addScriptMessageHandler];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeScriptMessageHandler];
    
    [super viewDidDisappear:animated];
    
}


-(void)addScriptMessageHandler{
     [[self.wkWebView configuration].userContentController addScriptMessageHandler:self name:kBackToLastPage];
}

-(void)removeScriptMessageHandler {
     [[self.wkWebView configuration].userContentController removeScriptMessageHandlerForName:kBackToLastPage];
}
    
-(void)setupWebView{
   
    if (!_wkConfig) {
        _wkConfig = [[WKWebViewConfiguration alloc] init];
        _wkConfig.allowsInlineMediaPlayback = YES;
        _wkConfig.allowsPictureInPictureMediaPlayback = YES;
    }
    
    if (!_wkWebView) {
        
        float topHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, topHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - topHeight) configuration:self.wkConfig];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        
//        [self.view addSubview:_wkWebView];
        [self.view insertSubview:_wkWebView belowSubview:self.topTitleView];
        
    }
    //3.添加KVO，WKWebView有一个属性estimatedProgress，就是当前网页加载的进度，所以监听这个属性。
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}


#pragma mark - start load web
/** 加载 */
- (void)startLoad {
    if (self.wkWebView.isLoading) {
        [self.wkWebView stopLoading ];
    }
    if (self.fileUrl) {
        NSURL *fileURL = [NSURL fileURLWithPath:self.fileUrl];
        [self.wkWebView loadFileURL:fileURL allowingReadAccessToURL:fileURL];
        return ;
    }
    
    NSString *urlString = self.url;
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    request.timeoutInterval = 15.0f;
    
    self.wkWebView.hidden = NO;
    [self.wkWebView loadRequest:request];
}

#pragma mark --------- 点击事件 ↓
- (IBAction)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)refreshBtnClick:(id)sender {
    
}
#pragma mark --------- 点击事件  end ↑ ---

/*
 *4.在监听方法中获取网页加载的进度，并将进度赋给progressView.progress
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.wkWebView.estimatedProgress;
        if (self.progressView.progress == 1) {
            /*
             *添加一个简单的动画，将progressView的Height变为1.4倍
             *动画时长0.25s，延时0.3s后开始动画
             *动画结束后将progressView隐藏
             */
           
            [UIView animateWithDuration:0.25 animations:^{
//                self.progressView.hidden = YES;
                self.topTitleView.alpha = 0;

            } completion:^(BOOL finished) {
                self.topTitleView.hidden = YES;
            }];
            

//            __weak typeof (self)weakSelf = self;
//            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
//                __strong typeof (weakSelf)self = weakSelf;
//                self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
//            } completion:^(BOOL finished) {
//                self.progressView.hidden = YES;
//                self.topTitleView.hidden = YES;
//            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name  isEqualToString:kBackToLastPage]) {
//        [self loadUrlNewTab:message.body];
        [self backBtnClick:nil];
    }
}


#pragma mark - WKWKNavigationDelegate Methods

/*
 *5.在WKWebViewd的代理中展示进度条，加载完成后隐藏进度条
 */

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
//    self.progressView.hidden = NO;
//    //开始加载网页的时候将progressView的Height恢复为1.5倍
//    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    //防止progressView被网页挡住

//    [self hideErrorView];
    
    NSURL *url =   webView.URL;
    NSString *urlStr =  url.absoluteString;

    
}

//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

//    [self hideErrorView];
    NSLog(@"加载完成");

}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"加载失败");
    //加载失败同样需要隐藏progressView
    
}

//页面跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //允许页面跳转
    NSLog(@"%@",navigationAction.request.URL);
    decisionHandler(WKNavigationActionPolicyAllow);
}


#pragma mark - wkwebview alert ↓ -
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    //    DLOG(@"msg = %@ frmae = %@",message,frame);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - WKWKNavigationDelegate end ↑ -

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
