//
//  ResponseParseStrategyProtocol.h
//  WhereNow
//
//  Created by Xiaoxue Han on 07/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#ifndef WhereNow_ResponseParseStrategyProtocol_h
#define WhereNow_ResponseParseStrategyProtocol_h

@protocol ResponseParseStrategyProtocol <NSObject>

@optional
- (BOOL)parseGenericResponse:(NSDictionary *)dicResult;
- (BOOL)parseEquipmentResponse:(NSDictionary *)dicResult;

@end

#endif
