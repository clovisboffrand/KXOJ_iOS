//
//  WebViewController.m
//  WJRS
//
//  Created by admin_user on 3/7/16.
//
//

#import "WebViewController.h"
#import "Header.h"

@interface WebViewController () <UIWebViewDelegate>
{
    IBOutlet UIWebView *adWebView;
    IBOutlet UIWebView *mainWebView;
    IBOutlet UIActivityIndicatorView *progress;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBanner];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Load web page from url.
    [mainWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[AppSettings shared].eventsLink]]];
}

#pragma mark - Setup Banner View

- (void)addBanner {
    [adWebView loadHTMLString:[CommonHelpers HTMLBodyOfBannerView] baseURL:nil];
}

#pragma mark - WebView Delegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView == mainWebView) {
        [progress startAnimating];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView == mainWebView) {
        [progress stopAnimating];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView == mainWebView) {
        [progress stopAnimating];
    }
}

#pragma mark - WebView Delegate Methods

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if (inWeb == adWebView) {
        if (inType == UIWebViewNavigationTypeLinkClicked) {
            [[UIApplication sharedApplication] openURL:[inRequest URL]];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Button Action Methods

- (IBAction)didTapGoBack:(id)sender {
    [mainWebView goBack];
}

- (IBAction)didTapGoForward:(id)sender {
    [mainWebView goForward];
}

- (IBAction)didTapReload:(id)sender {
    if (!progress.isAnimating) {
        [mainWebView reload];
    }
}

@end
