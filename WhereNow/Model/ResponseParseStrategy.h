//
//  ResponseParseStrategy.h
//  WhereNow
//
//  Created by Xiaoxue Han on 07/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParseStrategyProtocol.h"

@interface ResponseParseStrategy : NSObject <ResponseParseStrategyProtocol>

+ (ResponseParseStrategy *)sharedParseStrategy;

- (BOOL)parseGenericResponse:(NSDictionary *)dicResult;
- (BOOL)parseEquipmentResponse:(NSDictionary *)dicResult;

@end
