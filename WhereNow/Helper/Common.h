//
//  Common.h
//  TapConnect
//
//  Created by Donald Pae on 4/27/14.
//  Copyright (c) 2014 donald. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATETIME_FORMAT @"yyyy-MM-dd HH:mm:ss"
#define DATE_FORMAT     @"yyyy-MM-dd"

#define kTriggeredAlertChanged  @"triggeredalertchanged"

#define kDataChanged        @"data changed"
#define kLocatingChanged    @"locating changed"

@interface Common : NSObject

+ (BOOL)hasConnectivity;
+ (NSString *)date2str:(NSDate *)convertDate withFormat:(NSString *)formatString;
+ (NSDate *)str2date:(NSString *)dateString withFormat:(NSString *)formatString;
@end
