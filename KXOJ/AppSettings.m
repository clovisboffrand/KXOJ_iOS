//
//  AppSettings.m
//  KXOJ
//
//  Created by admin_user on 8/9/16.
//  Copyright © 2016 RadioServersLLC. All rights reserved.
//

#import "AppSettings.h"
#import "LocalStorage.h"

@implementation AppSettings

#pragma mark - Static Methods

+ (AppSettings *)shared {
    static AppSettings *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance loadDefaultChannel];
    });
    
    return instance;
}

#pragma mark - Private Methods

- (void)loadDefaultChannel {
    NSArray *channels = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chanels" ofType:@"plist"]];
    [self updateWith:channels[0]];
}

- (void)updateWith:(NSDictionary *)channelInfo {
    self.channelId = channelInfo[@"id"];
    self.streamLink = channelInfo[@"stream"];
    self.feedLink = channelInfo[@"feed"];
    self.eventsLink = channelInfo[@"events_link"];
    self.logo = channelInfo[@"logo"];
    self.color = channelInfo[@"color"];
}

@end
