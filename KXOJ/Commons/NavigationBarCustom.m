//
//  UINavigationBar+NavigationBarCustom.m
//  AppyEverAfter
//
//  Created by Harry Tran on 4/29/15.
//  Copyright (c) 2015 iChiTech. All rights reserved.
//

#import "NavigationBarCustom.h"
#import "Header.h"

@implementation UINavigationBar (Custom)

- (void)custom {
    [NavigationBarCustom customNavigationBar:self];
}

@end

@implementation NavigationBarCustom

- (void)awakeFromNib {
    [self custom];
}

+ (void)customNavigationBar:(UINavigationBar *)naviBar {
    [naviBar setBarTintColor:UIColorWithHexCode([AppSettings shared].color, 1)];
    [naviBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],
                                      NSForegroundColorAttributeName:UIColorFromString(@"ffffff", 1)}];
    naviBar.translucent = NO;
    naviBar.opaque = YES;
}

@end