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

#define HOST_URL    @"http://dev.scmedical.com.au/"
//#define SERVICE_URL @"http://dev.scmedical.com.au/mobile/index.php/api/v1/scmd/"
#define API_URL     @"http://dev.scmedical.com.au/mobile/index.php/"

// url for action
#define kAPIBaseUrl         @"api/v1/scmd/"
#define kMethodForLogin     kAPIBaseUrl"ulin"


// v2
#define kAPIBaseUrlV2       @"api/v2/"
#define kMethodForLoginV2   kAPIBaseUrlV2"user"

#define DEF_SERVERMANAGER   ServerManager *manager = [ServerManager sharedManager];

typedef void (^ServerManagerRequestHandlerBlock)(NSString *, NSDictionary *, NSError *);

@interface ServerManager : NSObject

@property (nonatomic, strong) id<ResponseParseStrategyProtocol> parser;

+ (ServerManager *)sharedManager;

- (void)getMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler;
- (void)postMethod:(NSString *)methodName params:(NSDictionary *)params handler:(ServerManagerRequestHandlerBlock)handler;


- (void)loginUserWithUserName:(NSString *)userName pwd:(NSString *)pwd success:(void (^)(NSString *sessionId, NSString *userId))success failure:(void (^)(NSString *))failure;

- (void)loginUserV2WithUserName:(NSString *)userName pwd:(NSString *)pwd success:(void (^)(NSString *sessionId, NSString *userId))success failure:(void (^)(NSString *))failure;

/**
 * get generics list
 *
 */
- (void)getGenerics:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure;
- (void)getGenericsV2:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure;

- (void)getEquipments:(NSString *)sessionId userId:(NSString *)userId success:(void (^)())success failure:(void (^)(NSString *))failure;

/**
 *
 * get information(generics/equipments) of current location
 *   request location information with beacons scaned by the phone
 */
- (void)getCurrLocation:(NSString *)sessionId userId:(NSString *)userId arrayBeacons:(NSMutableArray *)arrayBeacons success:(void(^)(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments))success failure:(void (^)(NSString *))failure;
- (void)getCurrLocationV2:(NSString *)sessionId userId:(NSString *)userId arrayBeacons:(NSMutableArray *)arrayBeacons success:(void(^)(NSMutableArray *arrayGenerics, NSMutableArray *arrayVicinityEquipments, NSMutableArray *arrayLocationEquipments))success failure:(void (^)(NSString *))failure;

// utilities
- (void)setImageContent:(UIImageView*)ivContent urlString:(NSString *)urlString;

@end
