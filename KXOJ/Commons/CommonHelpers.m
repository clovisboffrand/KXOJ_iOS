//
//  CommonHelpers.m
//  iRadio
//
//  Created by Phuc Tran on 2/9/14.
//
//

#import "CommonHelpers.h"
#import "Header.h"

@implementation CommonHelpers

+ (NSString *)HTMLBodyOfBannerView {
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"iframe" ofType:@"html"];
    NSString *string = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    string  = [string stringByReplacingOccurrencesOfString:@"#width#" withString:[NSString stringWithFormat:@"%f", window.frame.size.width]];
    return string;
}

+ (UIBarButtonItem *)backBarButtonItemWithTarget:(id)tagert action:(SEL)seletor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 34, 25);
    button.backgroundColor  = [UIColor clearColor];
    [button setBackgroundImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [button setBackgroundImageTintColor:[UIColor whiteColor]];
    [button addTarget:tagert action:seletor forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

@end
