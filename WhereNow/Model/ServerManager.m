//
//  SeverManager.m
//  WalkItOff
//
//  Created by Donald Pae on 7/2/14.
//  Copyright (c) 2014 daniel. All rights reserved.
//

#import "ServerManager.h"
#import "Reachability.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import "AFNetworking.h"
#import "SBJson.h"
#import <CoreLocation/CoreLocation.h>

static ServerManager *_sharedServerManager = nil;

NSString * const WhereNowErrorDomain = @"com.wherenow";

#define kDescriptionNotReachable    @"Network error"
#define ErrorFromNotReachable   ([NSError errorWithDomain:WhereNowErrorDomain code:ServiceErrorNetwork userInfo:@{NSLocalizedDescriptionKey:kDescriptionNotReachable}])

@implementation ServerManager

+ (ServerManager *)sharedManager
{
    if (_sharedServerManager == nil)
        _sharedServerManager = [[ServerManager alloc] init];
    return _sharedServerManager;
}

- (BOOL)hasConnectivity
{
    // test reachability
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    Reachability *reachability = [Reachability reachabilityWithAddress:&zeroAddress];
    if (reachability != nil)
    {
        if ([reachability isReachable])
            return YES;
        return NO;
    }
    return NO;
}

- (void)callMethodName:(NSString *)methodName isGet:(BOOL)isGet params:(NSDictionary *)params completion:(void (^)(NSString *, NSDictionary *, NSError *))handler
{
    if (![self hasConnectivity])
    {
        NSLog(@"Request error, network error");
        handler(nil, nil, ErrorFromNotReachable);
        return;
    }
    
    NSURL  *url = [NSURL URLWithString:API_URL];
	AFHTTPClient  *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    void (^successHandler)(AFHTTPRequestOperation *operation, id responseObject)  = ^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if (responseObject == nil)
        {
            NSLog(@"Request error, responseObject = nil");
            handler(nil, nil, [NSError errorWithDomain:WhereNowErrorDomain code:ServiceErrorNoResponse userInfo:nil]);
        }
        else
        {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            // remove <pre> tag if exists
            if ([[responseStr substringToIndex:5] isEqualToString:@"<pre>"])
                responseStr = [responseStr substringFromIndex:5];
            // remove prefix till to meet {
            NSRange range = [responseStr rangeOfString:@"{" options:0 range:NSMakeRange(0, responseStr.length)];
            NSRange range1 = [responseStr rangeOfString:@"[" options:0 range:NSMakeRange(0, responseStr.length)];
            
            NSRange range2;
            range2.length = 0;
            range2.location = NSNotFound;
            
            if (range.location != NSNotFound && range1.location != NSNotFound)
            {
                if (range1.location < range.location)
                    range2 = range1;
                else
                    range2 = range;
            }
            else if (range.location != NSNotFound)
            {
                range2 = range;
            }
            else if (range1.location != NSNotFound)
            {
                range2 = range1;
            }
                
            if (range2.location != NSNotFound && range2.location > 0)
            {
                responseStr = [responseStr substringFromIndex:range2.location];
            }
            
            NSDictionary *responseDic = [responseStr JSONValue];
            NSLog(@"Request Successful, response '%@'", responseStr);
            handler(responseStr, responseDic, nil);
        }
        
    };
    
    void (^errorHandler)(AFHTTPRequestOperation *operation, NSError *error)  = ^ (AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        handler(nil, nil, error);
    };
    
    if (isGet)
    {
        [httpClient getPath:methodName parameters:params success:successHandler failure:errorHandler];
    }
    else
    {
        [httpClient postPath:methodName parameters:params success:successHandler failure:errorHandler];
    }
    
}

- (void)getMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler
{
    [self callMethodName:methodName isGet:YES params:params completion:handler];
}

- (void)postMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler
{
    [self callMethodName:methodName isGet:NO params:params completion:handler];
}


#pragma mark - User Login
- (void)loginUserWithUserName:(NSString *)userName pwd:(NSString *)pwd success:(void (^)(NSString *sessionId, NSString *userId))success failure:(void (^)(NSString *))failure
{
    NSDictionary *params = nil;
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@/%@/%@.json", kMethodForLogin, userName, pwd];
    [manager getMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"] ||
                [responseStr isEqualToString:@"Invalid User Name Password\n"])
            {
                failure(@"Invalid User Name and Password!");
            }
            else
            {
                success(@"SESID-AABB", @"27");
            }
            return;
        }
        else
        {
            //{"ERROR":"Invalid User Name or Password"}
            // or {"ID":"SESID-AABB","UID":"27"}
            NSString *userId = [response objectForKey:@"UID"];
            if (userId == nil || [userId isEqual:[NSNull null]])
            {
                NSString *msg = [response objectForKey:@"ERROR"];
                if (msg == nil)
                    msg = @"Unknown error";
                failure(msg);
            }
            else
            {
                NSString *sessionId = [response objectForKey:@"ID"];
                if (sessionId == nil || [sessionId isEqual:[NSNull null]])
                    failure(@"Invalid response");
                else
                    success(sessionId, userId);
            }
        }
//        
//        int errorCode = [[response objectForKey:kResponseErrorKey] intValue];
//        if (errorCode != ServiceSuccess)
//        {
//            NSString *msg = [response objectForKey:kResponseMsgKey];
//            failure(msg);
//            return;
//        }
//        
//        NSDictionary *data = [response objectForKey:kResponseDataKey];
//        
//        User *user = [User getUserFromResponse:data];
//        user.type = UserTypeNormal;
//        
//        [User setCurrentUser:user];
    }];
}

- (void)loginUserV2WithUserName:(NSString *)userName pwd:(NSString *)pwd success:(void (^)(NSString *sessionId, NSString *userId))success failure:(void (^)(NSString *))failure
{
    NSDictionary *params = @{@"uname": userName, @"upass": pwd};
    DEF_SERVERMANAGER
    NSString *methodName = [NSString stringWithFormat:@"%@.json", kMethodForLoginV2];
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"] ||
                [responseStr isEqualToString:@"Invalid User Name Password\n"])
            {
                failure(@"Invalid User Name and Password!");
            }
            else
            {
                success(@"SESID-AABB", @"27");
            }
            return;
        }
        else
        {
            //{"ERROR":"Invalid User Name or Password"}
            // or {"ID":"SESID-AABB","UID":"27"}
            NSString *userId = [response objectForKey:@"UID"];
            if (userId == nil || [userId isEqual:[NSNull null]])
            {
                NSString *msg = [response objectForKey:@"ERROR"];
                if (msg == nil)
                    msg = @"Unknown error";
                failure(msg);
            }
            else
            {
                NSString *sessionId = [response objectForKey:@"ID"];
                if (sessionId == nil || [sessionId isEqual:[NSNull null]])
                    failure(@"Invalid response");
                else
                    success(sessionId, userId);
            }
        }
    }];
}


#pragma mark - get generics
- (void)getGenerics:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure
{
    NSDictionary *params = nil;
    DEF_SERVERMANAGER
   
    NSString *methodName = [NSString stringWithFormat:@"%@/%@/%@/%@.json", kAPIBaseUrl, sessionId, @"getglist", userId];

    [manager getMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid Response!");
            }
            return;
        }
        else
        {
            NSString *msg = [response objectForKey:@"ERROR"];
            if (msg != nil)
            {
                failure(msg);
                return;
            }
            
            
            // parse response, insert & update managed objects, save context
            [self.parser parseGenericResponse:response];
            
            // delegate to oberver success
            success();
        }
        
    }];
    
}

- (void)getGenericsV2:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure
{
    NSDictionary *params = @{@"uid": userId};
    DEF_SERVERMANAGER
    
    NSString *methodName = [NSString stringWithFormat:@"%@%@/%@.json", kAPIBaseUrlV2, sessionId, @"getglist"];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid Response!");
            }
            return;
        }
        else
        {
            if ([response isKindOfClass:[NSDictionary class]])
            {
                NSString *msg = [response objectForKey:@"ERROR"];
                if (msg != nil)
                {
                    failure(msg);
                    return;
                }
                else
                {
                    failure(@"unknown error!");
                    return;
                }
            }
            
            // parse response, insert & update managed objects, save context
            [self.parser parseGenericResponse:response];
            
            // delegate to oberver success
            success();
        }
        
    }];
    
}

#pragma mark - get equipments
- (void)getEquipments:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure
{
    NSDictionary *params = nil;
    DEF_SERVERMANAGER
    
    NSString *methodName = [NSString stringWithFormat:@"%@/%@/%@.json", sessionId, @"getelist", userId];
    
    [manager getMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                //
            }
            return;
        }
        else
        {
            // parse response, insert & update managed objects, save context
            [self.parser parseGenericResponse:response];
            
            // delegate to oberver success
            success();
        }
        
    }];
}

- (void)getCurrLocation:(NSString *)sessionId userId:(NSString *)userId arrayBeacons:(NSMutableArray *)arrayBeacons success:(void (^)(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments))sc failure:(void (^)(NSString *))failure
{
    
    DEF_SERVERMANAGER
    
    // parse beacon arrays and make params
    NSMutableArray *beaconsJsonArray = [[NSMutableArray alloc] init];
    for (CLBeacon *beacon in arrayBeacons) {
        NSMutableDictionary *dicBeacon = [[NSMutableDictionary alloc] init];
        [dicBeacon setObject:[beacon.proximityUUID UUIDString] forKey:@"uuid"];
        [dicBeacon setObject:[NSString stringWithFormat:@"%d", [beacon.major intValue]] forKey:@"major"];
        [dicBeacon setObject:[NSString stringWithFormat:@"%d", [beacon.minor intValue]] forKey:@"minor"];
        [beaconsJsonArray addObject:dicBeacon];
    }
    
    if (arrayBeacons.count <= 0)
    {
        NSMutableDictionary *dicBeacon = [[NSMutableDictionary alloc] init];
        [dicBeacon setObject:@"B125AA4F-2D82-401D-92E5-F962E8037F5C" forKey:@"uuid"];
        [dicBeacon setObject:[NSString stringWithFormat:@"%d", 100] forKey:@"major"];
        [dicBeacon setObject:[NSString stringWithFormat:@"%d", 10] forKey:@"minor"];
        [beaconsJsonArray addObject:dicBeacon];
    }
    
    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:beaconsJsonArray options:0 error:nil];
    NSString *strJsonScanned = [[NSString alloc] initWithBytes:[serializedData bytes] length:[serializedData length] encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:strJsonScanned, @"scanned", nil];
    
    NSString *methodName = [NSString stringWithFormat:@"%@/%@/%@.json", sessionId, @"getglist", userId];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            // parse response
            [self.parser parseNearmeResponse:response complete:^(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments) {
                
                sc(arrayGenerics, arrayVicinityEquipments, arrayLocationEquipments);
                
            } failure:^() {
                //
                failure(@"failed to parse response");
            }];
        }
    }];
}

- (void)getCurrLocationV2:(NSString *)sessionId userId:(NSString *)userId arrayBeacons:(NSMutableArray *)arrayBeacons success:(void (^)(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments))sc failure:(void (^)(NSString *))failure
{
    
    DEF_SERVERMANAGER
    
    // parse beacon arrays and make params
    NSMutableArray *beaconsJsonArray = [[NSMutableArray alloc] init];
    for (CLBeacon *beacon in arrayBeacons) {
        NSMutableDictionary *dicBeacon = [[NSMutableDictionary alloc] init];
        [dicBeacon setObject:[beacon.proximityUUID UUIDString] forKey:@"uuid"];
        [dicBeacon setObject:[NSString stringWithFormat:@"%d", [beacon.major intValue]] forKey:@"major"];
        [dicBeacon setObject:[NSString stringWithFormat:@"%d", [beacon.minor intValue]] forKey:@"minor"];
        [beaconsJsonArray addObject:dicBeacon];
    }
    
    if (arrayBeacons.count <= 0)
    {
        NSMutableDictionary *dicBeacon = [[NSMutableDictionary alloc] init];
        [dicBeacon setObject:@"B125AA4F-2D82-401D-92E5-F962E8037F5C" forKey:@"uuid"];
        [dicBeacon setObject:[NSString stringWithFormat:@"%d", 100] forKey:@"major"];
        [dicBeacon setObject:[NSString stringWithFormat:@"%d", 10] forKey:@"minor"];
        [beaconsJsonArray addObject:dicBeacon];
    }
    
    NSData *serializedData = [NSJSONSerialization dataWithJSONObject:beaconsJsonArray options:0 error:nil];
    NSString *strJsonScanned = [[NSString alloc] initWithBytes:[serializedData bytes] length:[serializedData length] encoding:NSUTF8StringEncoding];
    
    NSDictionary *params = @{@"uid":userId, @"scanned":strJsonScanned};
    
    NSString *methodName = [NSString stringWithFormat:@"%@/%@/%@.json", kAPIBaseUrlV2, sessionId, @"getglist"];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            // parse response
            [self.parser parseNearmeResponse:response complete:^(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments) {
                
                sc(arrayGenerics, arrayVicinityEquipments, arrayLocationEquipments);
                
            } failure:^() {
                //
                failure(@"failed to parse response");
            }];
        }
    }];
}

- (void)updateDeviceToken:(NSString *)deviceToken userId:(NSString *)userId success:(void (^)(NSString *tokenId))success failure:(void (^)(NSString *))failure
{
    
    DEF_SERVERMANAGER
    
    NSDictionary *params = @{@"uid":userId, @"utoken":deviceToken};
    
    NSString *methodName = [NSString stringWithFormat:@"%@.json", kMethodForRegisterToken];
    
    [manager postMethod:methodName params:params handler:^(NSString *responseStr, NSDictionary *response, NSError *error){
        
        if (error != nil)
        {
            failure([error localizedDescription]);
            return;
        }
        
        if (response == nil)
        {
            if ([responseStr isEqualToString:@"Invalid Parameters\n"])
            {
                failure(@"Invalid Parameters!");
            }
            else
            {
                failure(@"Invalid response");
            }
            return;
        }
        else
        {
            //NSString *userId = [response objectForKey:@"UID"];
            NSString *tokenId = [response objectForKey:@"tokenID"];
            success(tokenId);
        }
    }];
}


#pragma mark - Utilities
- (void) setImageContent:(UIImageView*)ivContent urlString:(NSString *)urlString
{
    if (urlString != nil && ![urlString isEqualToString:@""])
    {
        NSString *strImage = [NSString stringWithFormat:@"%@%@", HOST_URL, urlString];
        [ivContent setImageWithURL:[NSURL URLWithString:strImage] placeholderImage:[UIImage imageNamed:@"Loading"]];
    }
    else
    {
        // url is incorrect
        NSString *strImage = [NSString stringWithFormat:@"%@%@", HOST_URL, urlString];
        [ivContent setImageWithURL:[NSURL URLWithString:strImage] placeholderImage:[UIImage imageNamed:@"Loading"]];
    }
}

@end
