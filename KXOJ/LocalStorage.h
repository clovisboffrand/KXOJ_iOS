//
//  LocalStorage.h
//  I Know Nashville
//
//  Created by Markswoman on 10/14/15.
//
//

#import <Foundation/Foundation.h>

/*!
 @class LocalStorage
 @abstract A helper for read/write user defaults.
 */
@interface LocalStorage : NSObject

@property (nonatomic, strong) NSUserDefaults *userDefaults;

/*!
 @abstract Convenience method to build a shared LocalStorage object.
 
 @return LocalStorage singleton object.
 */
+ (instancetype)shared;

/*!
 @abstract Convenience method to set default.
 
 @param value   Default value to be saved.
 @param key     Key string for default.
 */
- (void)setDefault:(id)value forKey:(NSString *)key;

/*!
 @abstract Convenience method to get saved default.
 
 @param key Key string to fetch saved default.
 @return    Default value for key.
 */
- (id)defaultForKey:(NSString *)key;

/*!
 @abstract Convenience method to remove default.
 
 @param key     Key string for default.
 */
- (void)removeDefaultForKey:(NSString *)key;

/*!
 @abstract Convenience method to set integer default.
 
 @param value   Integer value to be saved.
 @param key     Key string for default.
 */
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;

/*!
 @abstract Convenience method to get saved integer default.
 
 @param key Key string to fetch saved integer default.
 @return    Integer value for key.
 */
- (NSInteger)integerForKey:(NSString *)key;

/*!
 @abstract Convenience method to set boolean default.
 
 @param value   Boolean value to be saved.
 @param key     Key string for default.
 */
- (void)setBool:(BOOL)value forKey:(NSString *)key;

/*!
 @abstract Convenience method to get saved boolean default.
 
 @param key Key string to fetch saved boolean default.
 @return    Boolean value for key.
 */
- (BOOL)boolForKey:(NSString *)key;

/*!
 @abstract Convenience method to save APNS token data.
 
 @param tokenData APNS token data.
 */
- (void)savePushToken:(NSData *)tokenData;

/*!
 @abstract Convenience method to get saved APNS token data.
 
 @return APNS token data.
 */
- (NSData *)getPushToken;

/*!
 @abstract Convenience method to get saved APNS token data as string.
 
 @return APNS token data in string type.
 */
- (NSString *)getPushTokenAsString;

@end
