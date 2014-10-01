//
//  UserContext.m
//  WhereNow
//
//  Created by Xiaoxue Han on 01/08/14.
//  Copyright (c) 2014 nicholas. All rights reserved.
//

#import "UserContext.h"

static UserContext *_sharedUserContext = nil;

@implementation UserContext

+ (UserContext *)sharedUserContext
{
    if (_sharedUserContext == nil)
        _sharedUserContext = [[UserContext alloc] init];
    return _sharedUserContext;
}

- (id)init
{
    self = [super init];
    if (self) {
        _userName = @"";
        _password = @"";
        _isLastLoggedin = NO;
        _sessionId = @"invalid";
        _userId = @"";
        _isLoggedIn = NO;
        
        [self load];
    }
    return self;
}

- (void)load
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSObject *obj = [userDefaults objectForKey:@"username"];
    if (obj != nil)
        _userName = (NSString *)obj;
    obj = [userDefaults objectForKey:@"password"];
    if (obj != nil)
        _password = (NSString *)obj;
    obj = [userDefaults objectForKey:@"islastloggedin"];
    if (obj != nil)
        _isLastLoggedin = [(NSNumber*)obj boolValue];
    obj = [userDefaults objectForKey:@"sessionid"];
    if (obj != nil)
        _sessionId = (NSString *)obj;
    obj = [userDefaults objectForKey:@"userid"];
    if (obj != nil)
        _userId = (NSString *)obj;
    obj = [userDefaults objectForKey:@"isloggedin"];
    if (obj != nil)
        _isLoggedIn = [(NSNumber*)obj boolValue];
}

- (void)save
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.userName forKey:@"username"];
    [userDefaults setObject:self.password forKey:@"password"];
    [userDefaults setObject:@(self.isLastLoggedin) forKey:@"islastloggedin"];
    [userDefaults setObject:self.sessionId forKey:@"sessionid"];
    [userDefaults setObject:self.userId forKey:@"userid"];
    [userDefaults setObject:@(self.isLoggedIn) forKey:@"isloggedin"];
    
    [userDefaults synchronize];
}

- (void)setUserName:(NSString *)userName
{
    _userName = userName;
    [self save];
}

- (void)setPassword:(NSString *)password
{
    _password = password;
    [self save];
}

- (void)setIsLastLoggedin:(BOOL)isLastLoggedin
{
    _isLastLoggedin = isLastLoggedin;
    [self save];
}

- (void)setSessionId:(NSString *)sessionId
{
    _sessionId = sessionId;
    [self save];
}

- (void)setUserId:(NSString *)userId
{
    _userId = userId;
    [self save];
}

- (void)setIsLoggedIn:(BOOL)isLoggedIn
{
    _isLoggedIn = isLoggedIn;
    [self save];
}

@end
