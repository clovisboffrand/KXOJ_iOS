//
//  LocalStorage.m
//  I Know Nashville
//
//  Created by admin_user on 10/14/15.
//
//

#import "LocalStorage.h"

@implementation LocalStorage

#define APNS_TOKEN_DATA @"APNS_TOKEN_DATA"

@synthesize userDefaults;

+ (instancetype)shared {
    static LocalStorage *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.userDefaults = [NSUserDefaults standardUserDefaults];
    });
    
    return instance;
}

#pragma mark - Read/write value with Defaults.
- (void)setDefault:(id)value forKey:(NSString *)key {
    [userDefaults setValue:value forKey:key];
    [userDefaults synchronize];
}

- (id)defaultForKey:(NSString *)key {
    return [userDefaults valueForKey:key];
}

- (void)removeDefaultForKey:(NSString *)key {
    [userDefaults removeObjectForKey:key];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)key {
    [userDefaults setInteger:value forKey:key];
    [userDefaults synchronize];
}

- (NSInteger)integerForKey:(NSString *)key {
    return [userDefaults integerForKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    [userDefaults setBool:value forKey:key];
    [userDefaults synchronize];
}

- (BOOL)boolForKey:(NSString *)key {
    return [userDefaults boolForKey:key];
}

#pragma mark - APNS Token Read/Write
- (void)savePushToken:(NSData *)tokenData {
    [userDefaults setValue:tokenData forKey:APNS_TOKEN_DATA];
    [userDefaults synchronize];
}

- (NSData *)getPushToken {
    return [userDefaults objectForKey:APNS_TOKEN_DATA];
}

- (NSString *)getPushTokenAsString {
    NSData *tokenData = [self getPushToken];
    NSString *pushToken;
    if (tokenData != nil) {
        pushToken = [[tokenData description] stringByTrimmingCharactersInSet:
                     [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    } else {
        pushToken = @"";
    }
    
    return pushToken;
}

@end
