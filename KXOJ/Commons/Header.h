//
//  Header.h
//  OG23
//
//  Created by HarryTran on 10/29/13.
//  Copyright (c) 2013 BPT Softs. All rights reserved.
//

#import "CommonHelpers.h"

#import <objc/objc.h>
#import <objc/runtime.h>
#import <netdb.h>

#import <AFNetworking/AFNetworking.h>
#import <HTProgressHUD/HTProgressHUD.h>
#import <ICTKit/Kit.h>

#import "NavigationBarCustom.h"

#import "XMLConverter.h"
#import "XMLDictionary.h"

#import "LocalStorage.h"
#import "AppSettings.h"

#define GET_INDICATOR               (HTProgressHUD *)objc_getAssociatedObject(self, (__bridge const void *)([self class]))

#define INIT_INDICATOR              objc_setAssociatedObject(self, (__bridge const void *)([self class]), [[HTProgressHUD alloc] init], OBJC_ASSOCIATION_RETAIN_NONATOMIC)

#define SHOW_INDICATOR(sview)       [GET_INDICATOR showInView:sview animated:YES]

#define HIDE_INDICATOR(animated)    [GET_INDICATOR hideWithAnimation:animated]
