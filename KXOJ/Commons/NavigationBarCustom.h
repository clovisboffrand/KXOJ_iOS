//
//  UINavigationBar+NavigationBarCustom.h
//  AppyEverAfter
//
//  Created by Harry Tran on 4/29/15.
//  Copyright (c) 2015 iChiTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Custom)

- (void)custom;

@end

@interface NavigationBarCustom : UINavigationBar

+ (void)customNavigationBar:(UINavigationBar *)naviBar;

@end
