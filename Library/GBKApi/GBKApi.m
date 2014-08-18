//
//  GBKApi.m
//  AlarmWeatherApp
//
//  Created by Администратор on 1/17/13.
//  Copyright (c) 2013 gbksoft.com. All rights reserved.
//

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#import "GBKApi.h"
#import <CommonCrypto/CommonDigest.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Reachability.h"

@implementation NSString (URLEncoding)
- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)self,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                 CFStringConvertNSStringEncodingToEncoding(encoding)));
}
@end

static SystemSoundID APNSSoundFileObject;

@implementation GBKApi

static Reachability * reachabilityHost = nil;

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
+ (NSString *) macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

// Checks if we have an internet connection or not
+ (void)internetConnection
{
    if(reachabilityHost){
        [reachabilityHost stopNotifier];
        reachabilityHost=nil;
    }
    reachabilityHost = [Reachability reachabilityWithHostname:[GBKApi host]];
    
    // Internet is reachable
    reachabilityHost.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"GBK_API_AVAILABLE:TRUE");
            [GBKApi setValue:@(TRUE) forKey:@"CONNECTION_AVAILABLE"];
        });
    };
    
    // Internet is not reachable
    reachabilityHost.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"GBK_API_AVAILABLE:FALSE");
            [GBKApi setValue:@(FALSE) forKey:@"CONNECTION_AVAILABLE"];
        });
    };
    [reachabilityHost startNotifier];
}

+ (BOOL)available{
    if(reachabilityHost){
        return [[GBKApi  valueForKey:@"CONNECTION_AVAILABLE"] boolValue];
    }else{
        [GBKApi internetConnection];
    }
    return FALSE;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

+ (id)valueForKey:(NSString*)key{
    return [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"GBKAPICP_%@",key]];
}

+ (void)setValue:(id)value forKey:(NSString*)key{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if(value!=nil){
        [defaults setValue:value forKey:[NSString stringWithFormat:@"GBKAPICP_%@",key]];
    }else{
        [defaults setNilValueForKey:[NSString stringWithFormat:@"GBKAPICP_%@",key]];
    }
    [defaults synchronize];
}

+ (NSString *) uniqueDeviceIdentifier{
    NSString *macaddress = [GBKApi macaddress];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
    NSString *uniqueIdentifier = [GBKApi getMD5FromString:stringToHash];
    
    return uniqueIdentifier;
}

+ (NSString *) uniqueGlobalDeviceIdentifier{
    NSString *macaddress = [GBKApi macaddress];
    NSString *uniqueIdentifier = [GBKApi getMD5FromString:macaddress];
    
    return uniqueIdentifier;
}



+ (BOOL)setDefaultHost:(NSString*)host withPath:(NSString*)path withScheme:(NSString*)scheme{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:host forKey:@"GBK_API_HOST"];
    [defaults setValue:path forKey:@"GBK_API_PATH"];
    [defaults setValue:scheme forKey:@"GBK_API_SCHEME"];
    [defaults synchronize];
    return TRUE;
}

+ (BOOL)setDefaultScheme:(NSString*)scheme{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:scheme forKey:@"GBK_API_SCHEME"];
    [defaults synchronize];
    return TRUE;
}

+ (NSString*)defaultScheme{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"GBK_API_SCHEME"];
}

+ (BOOL)setDebugMode:(BOOL)mode{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(mode) forKey:@"GBK_API_DEBUGMODE"];
    [defaults synchronize];
    return TRUE;
}

+ (BOOL)debugMode{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"GBK_API_DEBUGMODE"] boolValue];
}


+ (NSString*)scheme{
    return [GBKApi defaultScheme]!=nil ? [GBKApi defaultScheme] : @"http";
}

+ (BOOL)setDefaultHost:(NSString*)host{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:host forKey:@"GBK_API_HOST"];
    [defaults synchronize];
    return TRUE;
}

+ (NSString*)defaultHost{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"GBK_API_HOST"];
}

+ (NSString*)host{
    return [GBKApi defaultHost]!=nil ? [GBKApi defaultHost] : @"testapi.gbksoft.com";
}

+ (BOOL)setDefaultPath:(NSString*)path{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:path forKey:@"GBK_API_PATH"];
    [defaults synchronize];
    return TRUE;
}

+ (NSString*)defaultPath{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"GBK_API_PATH"];
}

+ (NSString*)path{
    return [GBKApi defaultPath]!=nil ? [GBKApi defaultPath] : @"";
}

+ (BOOL)setDefaultUrl:(NSString*)url{
    NSURL * _url = [NSURL URLWithString:url];
    NSString * path = [_url.path isEqualToString:@"/"] ? @"" : _url.path;
    [GBKApi setDefaultHost:_url.host withPath:path withScheme:_url.scheme];
    return TRUE;
}

+ (NSString*)url{
    return [NSString stringWithFormat:@"%@://%@%@",[GBKApi scheme],[GBKApi host],[GBKApi path]];
}

+ (NSString*)url:(NSString*)url{
    [GBKApi setDefaultUrl:url];
    return [GBKApi url];
}

+ (void)setServerInfo:(id)data{
    if(data && [data isKindOfClass:[NSDictionary class]]){
        if([data valueForKey:@"date"]){
            int diff = (int)[[NSDate date] timeIntervalSince1970] - [[data valueForKey:@"date"] intValue];
            [GBKApi setValue:@(diff) forKey:@"SERVER_TIME_DIFF"];
        }
        if([data valueForKey:@"version"]!=nil){
            [GBKApi setValue:[data valueForKey:@"version"] forKey:@"APP_SERVER_VERSION"];
        }
    }
}

+ (NSTimeInterval)getServerTimeDiff{
    return [[GBKApi valueForKey:@"SERVER_TIME_DIFF"] doubleValue];
}

+ (NSString*)getServerAppVersion{
    return [GBKApi valueForKey:@"APP_SERVER_VERSION"];
}

+ (NSString *)getMD5FromString:(NSString *)source{
	const char *src = [source UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(src, strlen(src), result);
    NSString *ret = [[NSString alloc] initWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15]
                     ];
    return [ret lowercaseString];
}

+ (NSString*)buildQuery:(NSDictionary*)params{
	NSString *myRequestString = @"";
	for(NSString *aKey in params){
		//DLog(@"KEY:%@",aKey);
		myRequestString = [myRequestString stringByAppendingString:[NSString stringWithFormat:([myRequestString isEqualToString:@""]?@"%@=%@":@"&%@=%@"), [aKey  urlEncodeUsingEncoding:NSUTF8StringEncoding],[[params valueForKey:aKey]urlEncodeUsingEncoding:NSUTF8StringEncoding]]];
        //NSLog(@"QUERY(%@):%@",aKey,myRequestString);
	}
	return myRequestString;
}

+ (id)get:(NSURL*)url{
    NSLog(@"GBKApiRequest:%@",url);
    return [NSData dataWithContentsOfURL:url];
}

+ (id)get:(NSURL*)url withCallback:(void (^)(id data))callback{
    NSLog(@"GBKApiRequest:%@",url);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        callback([NSData dataWithContentsOfURL:url]);
    });
    return nil;
}

+ (id)postFile:(NSURL*)url withName:(NSString*)name withData:(NSData*)fileData{
    // setting up the request object now
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    
    /*
     add some header info now
     we always need a boundary when we post a file
     also we need to set the content type
     
     You might want to generate a random boundary.. this is just the same
     as my output from wireshark on a valid html post
     */
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    /*
     now lets create the body of the post
     */
    NSMutableData *body = [NSMutableData data];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n",name] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:fileData]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // text parameter
    
    /*
     NSString * parameterValue1  = @"test";
     
     [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"parameter1\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[parameterValue1 dataUsingEncoding:NSUTF8StringEncoding]];
     [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
     */
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    // now lets make the connection to the web
    return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

+ (id)postFile:(NSURL*)url withName:(NSString*) name withData:(NSData*)fileData withCallback:(void (^)(id data))callback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        callback([GBKApi postFile:url withName:name withData:fileData]);
    });
    return nil;
}



+ (NSDictionary*)prepareMethod:(NSString*)method withParams:(NSArray*)params{
    params = params ? params : @[];
    NSString * secureKey = @"secure_key";
    NSString * sessionId = @"DEBUG_SESSION";
    //NSString * imei = [[UIDevice currentDevice] uniqueIdentifier];
    //NSString * imei = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString * imei = [GBKApi uniqueGlobalDeviceIdentifier];
    NSDictionary * request = [NSDictionary dictionaryWithObjectsAndKeys:
                              method, @"method",
                              params, @"params",
                              nil];
    NSString * _request = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:request options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    NSString * codeSign = [GBKApi getMD5FromString:[NSString stringWithFormat:@"%@%@%@%@",secureKey,sessionId,imei,_request]];
    //DLog(@"SIGN:%@",[NSString stringWithFormat:@"%@%@%@%@",secureKey,sessionId,imei,[json stringWithObject:request]]);
    
    if([GBKApi debugMode]){
        return @{
                 @"request":_request,
                 @"imei":imei,
                 @"session_id":sessionId,
                 @"sign_key":codeSign,
                 @"bundle_id":[[NSBundle mainBundle] bundleIdentifier],
                 @"debug":@"1"
                 };
    }else{
        return @{
                 @"request":_request,
                 @"imei":imei,
                 @"session_id":sessionId,
                 @"sign_key":codeSign,
                 @"bundle_id":[[NSBundle mainBundle] bundleIdentifier]
                 };
    }
}

+ (id)JSONFromData:(NSData*)data{
    id json = nil;
    if(data){
        @try {
            NSError * error;
            json = [NSJSONSerialization JSONObjectWithData:data //1
                                                   options:kNilOptions
                                                     error:&error];
            if(error){
                NSLog(@"RESPONSE_JSON_ERROR:%@",error);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"RESPONSE_JSON_ERROR");
        }
    }
    return json;
}

+ (NSURL*)URLWithMethod:(NSString*)method withParams:(NSArray*)params{
    NSLog(@"URL(%@):%@",[NSString stringWithFormat:@"%@/api?%@",[GBKApi url],[GBKApi buildQuery:[GBKApi prepareMethod:method withParams:params]]],[NSURL URLWithString:[NSString stringWithFormat:@"%@/api?%@",[GBKApi url],[GBKApi buildQuery:[GBKApi prepareMethod:method withParams:params]]]]);
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/api?%@",[GBKApi url],[GBKApi buildQuery:[GBKApi prepareMethod:method withParams:params]]]];
}

+ (id)request:(NSString*)method :(NSArray*)params withFileData:(NSData*)fileData{
    return [GBKApi request:method :params withFileName:@"UNDEFINED" withFileData:fileData];
}

+ (id)request:(NSString*)method :(NSArray*)params withFileData:(NSData*)fileData withCallback:(void (^)(id data))callback{
    return [GBKApi request:method :params withFileName:@"UNDEFINED" withFileData:fileData withCallback:callback];
}

+ (id)request:(NSString*)method :(NSArray*)params withFileName:(NSString*)fileName withFileData:(NSData*)fileData{
    id data = [GBKApi JSONFromData:[GBKApi postFile:[GBKApi URLWithMethod:method withParams:params] withName:fileName withData:fileData]];
    [GBKApi setServerInfo:data];
    return data;
}

+ (id)request:(NSString*)method :(NSArray*)params withFileName:(NSString*)fileName withFileData:(NSData*)fileData withCallback:(void (^)(id data))callback{
    return [GBKApi postFile:[GBKApi URLWithMethod:method withParams:params] withName:fileName withData:fileData withCallback:^(id data) {
        data = [GBKApi JSONFromData:data];
        [GBKApi setServerInfo:data];
        callback(data);
    }];
}

+ (id)request:(NSString*)method{
    return [GBKApi request:method :nil];
}

+ (id)request:(NSString*)method withCallback:(void (^)(id data))callback{
    return [GBKApi request:method :nil withCallback:callback];
}

+ (id)request:(NSString*)method :(NSArray*)params{
    id data = [GBKApi JSONFromData:[GBKApi get:[GBKApi URLWithMethod:method withParams:params]]];
    [GBKApi setServerInfo:data];
    return data;
}

+ (id)request:(NSString*)method :(NSArray*)params withCallback:(void (^)(id data))callback{
    return [GBKApi get:[GBKApi URLWithMethod:method withParams:params] withCallback:^(id data) {
        //NSLog(@"DATA:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        data = [GBKApi JSONFromData:data];
        [GBKApi setServerInfo:data];
        callback(data);
    }];
}

#pragma mark - APNS

/*
 * ------------------------------------------------------------------------------------------
 *  BEGIN APNS CODE
 * ------------------------------------------------------------------------------------------
 */

+ (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types{
    [[UIApplication sharedApplication]
     registerForRemoteNotificationTypes:types];
#if TARGET_IPHONE_SIMULATOR
    [[GBKApi class] performSelectorInBackground:@selector(registerSimultionForRemoteNotification) withObject:nil];
#endif
}

+ (void)registerSimultionForRemoteNotification{
#if TARGET_IPHONE_SIMULATOR
    [GBKApi application:[UIApplication sharedApplication] didRegisterForRemoteNotificationsWithDeviceToken:[[GBKApi uniqueDeviceIdentifier]dataUsingEncoding:NSUTF8StringEncoding]];
#endif
}


+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken withCallback:(void (^)(id data))callback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        callback([GBKApi application:[UIApplication sharedApplication] didRegisterForRemoteNotificationsWithDeviceToken:devToken]);
    });
}
/**
 * Fetch and Format Device Token and Register Important Information to Remote Server
 */
+ (id)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    
    //#if !TARGET_IPHONE_SIMULATOR
    
	// Get Bundle Info for Remote Registration (handy if you have more than one app)
	//NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appName = [[NSBundle mainBundle] bundleIdentifier];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
	// Check what Notifications the user has turned on.  We registered for all three, but they may have manually disabled some or all of them.
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
	// Set the defaults to disabled unless we find otherwise...
	NSString *pushBadge = @"disabled";
	NSString *pushAlert = @"disabled";
	NSString *pushSound = @"disabled";
    
	// Check what Registered Types are turned on. This is a bit tricky since if two are enabled, and one is off, it will return a number 2... not telling you which
	// one is actually disabled. So we are literally checking to see if rnTypes matches what is turned on, instead of by number. The "tricky" part is that the
	// single notification types will only match if they are the ONLY one enabled.  Likewise, when we are checking for a pair of notifications, it will only be
	// true if those two notifications are on.  This is why the code is written this way
	if(rntypes == UIRemoteNotificationTypeBadge){
		pushBadge = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeAlert){
		pushAlert = @"enabled";
	}
	else if(rntypes == UIRemoteNotificationTypeSound){
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
    
	// Get the users Device Model, Display Name, Unique ID, Token & Version Number
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = [GBKApi uniqueGlobalDeviceIdentifier];
    NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
    
	// Prepare the Device Token for Registration (remove spaces and < >)
	NSString *deviceToken = [[[[devToken description]
                               stringByReplacingOccurrencesOfString:@"<"withString:@""]
                              stringByReplacingOccurrencesOfString:@">" withString:@""]
                             stringByReplacingOccurrencesOfString: @" " withString: @""];
    
	// Build URL String for Registration
	// !!! CHANGE "www.mywebsite.com" TO YOUR WEBSITE. Leave out the http://
	// !!! SAMPLE: "secure.awesomeapp.com"
	//NSString *host = @"api.appsnotwar.com";
    //NSString *host = @"api.gbksoft.com";
    NSString *host =  [GBKApi host];
    
	// !!! CHANGE "/apns.php?" TO THE PATH TO WHERE apns.php IS INSTALLED
	// !!! ( MUST START WITH / AND END WITH ? ).
	// !!! SAMPLE: "/path/to/apns.php?"
	NSString *urlString = [@"/apns/apns.php?"stringByAppendingString:@"task=register"];
    
	urlString = [urlString stringByAppendingString:@"&appname="];
	urlString = [urlString stringByAppendingString:appName];
	urlString = [urlString stringByAppendingString:@"&appversion="];
	urlString = [urlString stringByAppendingString:appVersion];
	urlString = [urlString stringByAppendingString:@"&deviceuid="];
	urlString = [urlString stringByAppendingString:deviceUuid];
	urlString = [urlString stringByAppendingString:@"&devicetoken="];
	urlString = [urlString stringByAppendingString:deviceToken];
	urlString = [urlString stringByAppendingString:@"&devicename="];
	urlString = [urlString stringByAppendingString:deviceName];
	urlString = [urlString stringByAppendingString:@"&devicemodel="];
	urlString = [urlString stringByAppendingString:deviceModel];
	urlString = [urlString stringByAppendingString:@"&deviceversion="];
	urlString = [urlString stringByAppendingString:deviceSystemVersion];
	urlString = [urlString stringByAppendingString:@"&pushbadge="];
	urlString = [urlString stringByAppendingString:pushBadge];
	urlString = [urlString stringByAppendingString:@"&pushalert="];
	urlString = [urlString stringByAppendingString:pushAlert];
	urlString = [urlString stringByAppendingString:@"&pushsound="];
	urlString = [urlString stringByAppendingString:pushSound];
    
	// Register the Device Data
	// !!! CHANGE "http" TO "https" IF YOU ARE USING HTTPS PROTOCOL
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSLog(@"Register URL: %@", url);
    if(returnData){
        NSLog(@"Return Data: %@", [NSString stringWithUTF8String:[returnData bytes]]);
        return returnData;
    }
    return nil;
    //#endif
}

/**
 * Failed to Register for Remote Notifications
 */
+ (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    //#if !TARGET_IPHONE_SIMULATOR
    
	NSLog(@"Error in registration. Error: %@", error);
    
    //#endif
}

+ (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //#if !TARGET_IPHONE_SIMULATOR
    
    NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    
	NSString *alert = [apsInfo objectForKey:@"alert"];
	NSLog(@"Received Push Alert: %@", alert);
    
	NSString *sound =  [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	
	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
    
    
    //-----------------------APNS HANDLE----------------
    UIApplicationState state = [application applicationState];
    if (TRUE || state == UIApplicationStateActive){
        NSLog(@" It is in active state");
        
        if([userInfo objectForKey:@"GBKAPI_UPDATE"]){
            NSDictionary * update = [userInfo objectForKey:@"GBKAPI_UPDATE"];
            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"GBKAPI_UPDATE"] object:update];
            if([update valueForKey:@"name"]){
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"GBKAPI_UPDATE_%@",[update valueForKey:@"name"]] object:nil];
            }
        }
        
        if(sound){
            CFURLRef		soundFileURLRef;
            //SystemSoundID	soundFileObject;
            // создаем NSURL, который будет ссылаться на наш звуковой файл
            // Метод URLForResource:withExtension доступен начиная с iOS 4.0
            NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: sound
                                                        withExtension: nil];
            
            // Сохраняем URL как переменную типа CFURLRef
            soundFileURLRef = (__bridge_retained CFURLRef)tapSound;
            
            // Функция, которая создает звуковой объект. На вход принимает созданный нами
            // CFURLRef и SystemSoundId, в который будет помещен результат
            AudioServicesCreateSystemSoundID (
                                              soundFileURLRef,
                                              &APNSSoundFileObject
                                              );
            
            // Функция, которая непосредственно воспроизводит созданный нами объект
            AudioServicesPlaySystemSound (APNSSoundFileObject);
            
            
            //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        if(alert){
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:nil message:[apsInfo objectForKey:@"alert"] delegate:[GBKApi class] cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //alertView.delegate = (id)self;
            [alertView show];
        }
    }
    else {
        NSLog(@" It is in inactive state");
    }
    //application.applicationIconBadgeNumber=0;
    
    //#endif
}

+ (NSMutableDictionary*)mutableApnsUserInfo:(NSDictionary*)userInfo{
    NSMutableDictionary * _userInfo = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    if([_userInfo valueForKey:@"aps"]){
        [_userInfo setValue:[NSMutableDictionary dictionaryWithDictionary:[_userInfo valueForKey:@"aps"]] forKey:@"aps"];
    }
    return _userInfo;
}

+ (void)onUpdate:(NSString*)name observer:(id)observer selector:(SEL)selector{
    NSString * _name = name ? [NSString stringWithFormat:@"GBKAPI_UPDATE_%@",name] : @"GBKAPI_UPDATE";
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:_name object:nil];
}

+ (void)onUpdate:(NSString*)name usingBlock:(void (^)(NSNotification *note))block{
    NSString * _name = name ? [NSString stringWithFormat:@"GBKAPI_UPDATE_%@",name] : @"GBKAPI_UPDATE";
    [[NSNotificationCenter defaultCenter] addObserverForName:_name object:nil queue:nil usingBlock:block];
}

+ (void)onUpdateDealloc:(id)observer{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

/**
 * Remote Notification Received while application was open.
 */

+ (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    AudioServicesDisposeSystemSoundID(APNSSoundFileObject);
}

/*
 * ------------------------------------------------------------------------------------------
 *  END APNS CODE
 * ------------------------------------------------------------------------------------------
 */


#pragma mark - GEOCODE

/*
 
 https://developers.google.com/maps/documentation/geocoding/#ComponentFiltering
 
 [GBKApi geocodeAddress:@"Zaporizhzhia lenina 149" withComponents:@{@"country":@"US"} withCallback:^(id data) {
 NSLog(@"GEOCODE:%@",data);
 }];
 */

+ (NSURL*)prepareGeocodeAddress:(NSString*)address withComponents:(NSDictionary*)components{
    NSMutableDictionary * params = [@{@"address":address,@"sensor":@"false"} mutableCopy];
    if(components && components.count>0){
        NSMutableArray * _components = [NSMutableArray new];
        for (NSString * key in components) {
            [_components addObject:[NSString stringWithFormat:@"%@:%@",key,[components valueForKey:key]]];
        }
        [params setValue:[_components componentsJoinedByString:@"|"] forKey:@"components"];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?%@",[GBKApi buildQuery:params]]];
}

+ (id)geocodeAddress:(NSString*)address withComponents:(NSDictionary*)components withCallback:(void (^)(id data))callback {
    NSURL * _url = [GBKApi prepareGeocodeAddress:address withComponents:components];
    return [GBKApi get:_url withCallback:^(id data) {
        callback([GBKApi JSONFromData:data]);
    }];
}

+ (id)geocodeAddress:(NSString*)address withCallback:(void (^)(id data))callback {
    return [GBKApi geocodeAddress:address withComponents:nil withCallback:callback];
}

+ (id)geocodeAddress:(NSString*)address withComponents:(NSDictionary*)components{
    NSURL * _url = [GBKApi prepareGeocodeAddress:address withComponents:components];
    return [GBKApi JSONFromData:[GBKApi get:_url]];
}

+ (id)geocodeAddress:(NSString*)address{
    return [GBKApi geocodeAddress:address withComponents:nil];
}

+ (NSURL*)prepareAutocompleteCity:(NSString*)city withComponents:(NSDictionary*)components{
    NSMutableDictionary * params = [@{
                                    @"input":city,
                                    @"sensor":@"false",
                                    @"types":@"geocode",
                                    @"key":@"AIzaSyA3krR5bJp6zCdkx_SwfFbTRj9C63c7TRE"
                                    } mutableCopy];
    if(components && components.count>0){
        NSMutableArray * _components = [NSMutableArray new];
        for (NSString * key in components) {
            [_components addObject:[NSString stringWithFormat:@"%@:%@",key,[components valueForKey:key]]];
        }
        [params setValue:[_components componentsJoinedByString:@"|"] forKey:@"components"];
    }
    return [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?%@",[GBKApi buildQuery:params]]];
}

#pragma mark - AUTOCOMPLETE

/*
 
 https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Kyi&types=geocode&language=en&components=country:UA&sensor=true&key=AIzaSyA3krR5bJp6zCdkx_SwfFbTRj9C63c7TRE
 
 [GBKApi autocompleteCity:@"Zapor" withComponents:@{@"country":@"UA"} withCallback:^(id data) {
 NSLog(@"AUTOCOMPLETE:%@",data);
 }];
 */

+ (id)autocompleteCity:(NSString*)city withComponents:(NSDictionary*)components withCallback:(void (^)(id data))callback {
    NSURL * _url = [GBKApi prepareAutocompleteCity:city withComponents:components];
    return [GBKApi get:_url withCallback:^(id data) {
        callback([GBKApi JSONFromData:data]);
    }];
}

+ (id)autocompleteCity:(NSString*)city withCallback:(void (^)(id data))callback {
    return [GBKApi autocompleteCity:(NSString*)city withComponents:nil withCallback:callback];
}

+ (id)autocompleteCity:(NSString*)city withComponents:(NSDictionary*)components{
    NSURL * _url = [GBKApi prepareAutocompleteCity:city withComponents:components];
    return [GBKApi JSONFromData:[GBKApi get:_url]];
}

+ (id)autocompleteCity:(NSString*)city{
    return [GBKApi autocompleteCity:(NSString*)city withComponents:nil];
}

@end
