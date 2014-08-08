//
//  SeverManager.h
//  WalkItOff
//
//  Created by Donald Pae on 7/2/14.
//  Copyright (c) 2014 daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceErrorCodes.h"
#import "ResponseParseStrategyProtocol.h"

#define SERVICE_URL @"http://dev.scmedical.com.au/mobile/index.php/api/v1/scmd/"


#define DEF_SERVERMANAGER   ServerManager *manager = [ServerManager sharedManager];

typedef void (^ServerManagerRequestHandlerBlock)(NSString *, NSDictionary *, NSError *);

@interface ServerManager : NSObject

@property (nonatomic, strong) id<ResponseParseStrategyProtocol> parser;

+ (ServerManager *)sharedManager;

- (void)getMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler;
- (void)postMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler;


- (void)loginUserWithUserName:(NSString *)userName pwd:(NSString *)pwd success:(void (^)(NSString *sessionId))success failure:(void (^)(NSString *))failure;

- (void)getGenerics:(NSString *)sessionId success:(void (^)())success failure:(void (^)(NSString *))failure;

@end
