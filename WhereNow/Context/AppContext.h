//
//  AppContext.h
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppContext : NSObject

+ (AppContext *)sharedAppContext;

+ (NSURL *)applicationDocumentsDirectory;

@end
