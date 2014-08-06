//
//  GBKApi.h
//  AlarmWeatherApp
//
//  Created by Администратор on 1/17/13.
//  Copyright (c) 2013 gbksoft.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSString (URLEncoding)
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end

@interface GBKApi : NSObject

+ (id)valueForKey:(NSString*)key;
+ (void)setValue:(id)value forKey:(NSString*)key;

+ (BOOL)hasConnectivity;
+ (BOOL)available;

+ (NSTimeInterval)getServerTimeDiff;
+ (NSString*)getServerAppVersion;

+ (BOOL)setDefaultHost:(NSString*)host withPath:(NSString*)path withScheme:(NSString*)scheme;
+ (BOOL)setDefaultScheme:(NSString*)scheme;
+ (NSString*)defaultScheme;
+ (NSString*)scheme;
+ (BOOL)setDefaultHost:(NSString*)host;
+ (NSString*)defaultHost;
+ (NSString*)host;
+ (BOOL)setDefaultPath:(NSString*)path;
+ (NSString*)defaultPath;
+ (NSString*)path;
+ (BOOL)setDebugMode:(BOOL)mode;
+ (BOOL)debugMode;
+ (BOOL)setDefaultUrl:(NSString*)url;
+ (NSString*)url;
+ (NSString*)url:(NSString*)url __attribute__((deprecated("Use + (BOOL)setDefaultUrl:(NSString*)url")));

+ (id)JSONFromData:(NSData*)data;

+ (id)postFile:(NSURL*)url withName:(NSString*)name withData:(NSData*)fileData;
+ (id)postFile:(NSURL*)url withName:(NSString*) name withData:(NSData*)fileData withCallback:(void (^)(id data))callback;


+ (id)request :(NSString*)method withCallback :(void (^)(id data))callback;
+ (id)request :(NSString*)method :(NSArray*)params withCallback :(void (^)(id data))callback;
+ (id)request :(NSString*)method :(NSArray*)params withFileData :(NSData*)fileData withCallback:(void (^)(id data))callback;
+ (id)request :(NSString*)method :(NSArray*)params withFileName:(NSString*)fileName withFileData:(NSData*)fileData withCallback:(void (^)(id data))callback;
+ (id)get:(NSURL*)url withCallback:(void (^)(id data))callback;

+ (id)request :(NSString*)method;
+ (id)request :(NSString*)method :(NSArray*)params;
+ (id)request :(NSString*)method :(NSArray*)params withFileData :(NSData*)fileData;
+ (id)request :(NSString*)method :(NSArray*)params withFileName:(NSString*)fileName withFileData:(NSData*)fileData;
+ (id)get:(NSURL*)url;

+ (NSString *)getMD5FromString :(NSString *)source;

+ (id)geocodeAddress:(NSString*)address withComponents:(NSDictionary*)components withCallback:(void (^)(id data))callback;
+ (id)geocodeAddress:(NSString*)address withCallback:(void (^)(id data))callback;
+ (id)geocodeAddress:(NSString*)address withComponents:(NSDictionary*)components;
+ (id)geocodeAddress:(NSString*)address;

+ (id)autocompleteCity:(NSString*)city withComponents:(NSDictionary*)components withCallback:(void (^)(id data))callback;
+ (id)autocompleteCity:(NSString*)city withCallback:(void (^)(id data))callback;
+ (id)autocompleteCity:(NSString*)city withComponents:(NSDictionary*)components;
+ (id)autocompleteCity:(NSString*)city;

/*
 * @method uniqueDeviceIdentifier
 * @description use this method when you need a unique identifier in one app.
 * It generates a hash from the MAC-address in combination with the bundle identifier
 * of your app.
 */

+ (NSString *) uniqueDeviceIdentifier;

/*
 * @method uniqueGlobalDeviceIdentifier
 * @description use this method when you need a unique global identifier to track a device
 * with multiple apps. as example a advertising network will use this method to track the device
 * from different apps.
 * It generates a hash from the MAC-address only.
 */

+ (NSString *) uniqueGlobalDeviceIdentifier;

+ (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types;
+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken withCallback:(void (^)(id data))callback;
+ (id)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken;
+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;
+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

+ (NSMutableDictionary*)mutableApnsUserInfo:(NSDictionary*)userInfo;
+ (void)onUpdate:(NSString*)name observer:(id)observer selector:(SEL)selector;
+ (void)onUpdate:(NSString*)name usingBlock:(void (^)(NSNotification *note))block;
+ (void)onUpdateDealloc:(id)observer;

@end
