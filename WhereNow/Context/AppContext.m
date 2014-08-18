//
//  AppContext.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "AppContext.h"

static AppContext *_sharedAppContext = nil;

@implementation AppContext

+ (AppContext *)sharedAppContext
{
    if (_sharedAppContext == nil)
        _sharedAppContext = [[AppContext alloc] init];
    return _sharedAppContext;
}

+ (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask]
            lastObject];
}

@end
