//
//  AppSettings.h
//  KXOJ
//
//  Created by admin_user on 8/9/16.
//  Copyright © 2016 RadioServersLLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject

@property (nonatomic, strong) NSNumber *channelId;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic, strong) NSString *streamLink;
@property (nonatomic, strong) NSString *feedLink;
@property (nonatomic, strong) NSString *eventsLink;

+ (AppSettings *)shared;

- (void)updateWith:(NSDictionary *)channelInfo;

@end