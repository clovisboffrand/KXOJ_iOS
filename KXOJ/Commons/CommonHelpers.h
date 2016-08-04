//
//  CommonHelpers.h
//  iRadio
//
//  Created by Phuc Tran on 2/9/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AFHTTPRequestOperationManager;

@interface CommonHelpers : NSObject

+ (NSString *)HTMLBodyOfBannerView;

+ (UIBarButtonItem *)backBarButtonItemWithTarget:(id)tagert action:(SEL)seletor;

@end
