
//
//  CTLAPI.m
//  Clientelle
//
//  Created by Samuel Goodwin on 3/24/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import "CTLAPI.h"

BOOL const DEBUG_MODE = YES;

// Error messages
NSString *const kServerErrorGeneric = @"Sorry... internet trouble";

// response keys
NSString *const kCTLMessageKey = @"message";
NSString *const kCTLStatusKey = @"status";
NSString *const kCTLResponseKey = @"response";
NSString *const kCTLAuthTokenKey = @"auth_token";

// user info
NSString *const kUserKey = @"user";
NSString *const kUserIDKey = @"user_id";
NSString *const kUserEmailKey = @"email";

typedef enum{
    CTLSuccess = 0,
    CTLFailure = 1
}CTLResponseCode;

@interface CTLAPI()
- (void)setUserDictionary:(NSDictionary *)user;
- (NSString *)urlStringForAPIMethod:(NSString *)method;
@end

@implementation CTLAPI

+ (id)sharedAPI{
    static CTLAPI *sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAPI = [[self alloc] init];
    });
    
    return sharedAPI;
}

- (id)init{
    if(self = [super init]){
        _internetOperationQueue = [[NSOperationQueue alloc] init];
        [_internetOperationQueue setName:@"com.clientelle.apiQueue"];
    }
    return self;
}

- (BOOL)hasInternetConnection {
    return [GOHTTPOperation hasConnection];
}

#pragma mark - Helper methods

- (NSString *)urlStringForAPIMethod:(NSString *)method{
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DevConfig" ofType:@"plist"]];
    NSString *url = [NSString stringWithFormat:@"%@%@", [plist objectForKey:@"server"], method];
    
    if(DEBUG_MODE){
        NSLog(@"URL: %@", url);
    }
    
    return url;
}

- (void)setUserDictionary:(NSDictionary *)user{
    // This is technically invalid, but not important to fix right now. At least both methods that do this all do it right here so it'll be easy to fix.
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:kUserKey];
}

- (void)makeRequest:(NSString *)path withBlock:(CTLResultBlock)block{
    
    NSString *urlString = [self urlStringForAPIMethod:path];
    GOHTTPOperation *operation = [GOHTTPOperation operationWithURL:urlString];
    [operation addCompletion:^(NSData *responseData) {
        NSError *error = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if(!responseDict){
            if(DEBUG_MODE){
                NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                NSLog(@"Response string: %@", responseString);
            }
            block(NO, responseDict);
            return;
        }
        
        NSNumber *result = [responseDict objectForKey:kCTLStatusKey];
        if([result intValue] == CTLFailure){
            block(NO, responseDict);
            return;
        }
        block(YES, responseDict);
    }];
    [_internetOperationQueue addOperation:operation];
}

- (void)makeRequest:(NSString *)path withParams:(NSDictionary *)params method:(GOHTTPMethod)method withBlock:(CTLResultBlock)block
{
    
    NSString *urlString = [self urlStringForAPIMethod:path];
    GOHTTPOperation *operation = [GOHTTPOperation operationWithURL:urlString method:method params:params];
    [operation addCompletion:^(NSData *responseData) {
        NSError *error = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                
        if(!responseDict){
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"Response string: %@", responseString);
            block(NO, responseDict);
            return;
        }
        
        if(responseDict[@"error"]){
            block(NO, responseDict);
            return;
        }
        
        NSNumber *result = [responseDict objectForKey:kCTLStatusKey];
        if([result intValue] == CTLFailure){
            block(NO, responseDict);
            return;
        }
        
        block(YES, responseDict);
    }];

    [_internetOperationQueue addOperation:operation];
}

- (void)makeRequest:(NSString *)path withParams:(NSDictionary *)params andWait:(CTLResultBlock)block
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    
    
    while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)makeRequest:(NSString *)path andWait:(CTLResultBlock)block
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    
    
    while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

#pragma mark API methods

- (void)loginWithEmail:(NSString *)email password:(NSString *)password andBlock:(CTLResultBlock)block{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:password, @"password", email, @"email", nil];
    
    NSString *urlString = [self urlStringForAPIMethod:@"auth/login"];
    GOHTTPOperation *operation = [GOHTTPOperation operationWithURL:urlString method:GOHTTPMethodPOST params:params];
    [operation addCompletion:^(NSData *responseData) {
        NSError *error = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
        if(!responseDict){
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            if(DEBUG_MODE){
                NSLog(@"Response string: %@", responseString);
            }
            block(NO, responseDict);
            return;
        }
        
        if(DEBUG_MODE){
            NSLog(@"Response dict: %@", responseDict);
        }
        
        NSNumber *loginResult = [responseDict objectForKey:kCTLStatusKey];
        if([loginResult intValue] == CTLFailure){
            block(NO, responseDict);
            return;
        }
        
        // Store the user object
        //TODO: save the access token as well
        [self setUserDictionary:[responseDict objectForKey:kUserKey]];
        block(YES, [responseDict objectForKey:kCTLMessageKey]);
        //block(YES, [responseDict objectForKey:kCTLAuthTokenKey]);
    }];
    [_internetOperationQueue addOperation:operation];
}

- (void)submitContacts:(NSSet *)contacts withBlock:(CTLResultBlock)block{
    NSAssert([contacts count] > 0, @"You have to actually submit contacts!");
    NSString *urlString = [self urlStringForAPIMethod:@"contacts/add"];
    NSLog(@"Sending data to: %@", urlString);
    NSError *error = nil;
    
    NSArray *jsonArray = [[contacts allObjects] valueForKey:@"JSONFriendlyDictionary"];
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:&error];
    NSLog(@"Submitting JSON: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    if(!data){
        NSLog(@"Error JSON-ifying contacts: %@", [error localizedDescription]);
    }
    
    GOHTTPOperation *operation = [GOHTTPOperation POSToperationWithURL:urlString andJSONData:data];
    [operation addCompletion:^(NSData *responseData) {
        NSError *parsingError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&parsingError];
        if(!responseDict){
            NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            NSLog(@"Response string: %@", responseString);
            block(NO, responseDict);
            return;
        }
    }];
    [_internetOperationQueue addOperation:operation];
}

- (void)fetchInboxWithBlock:(CTLResultBlock)block{
    NSString *urlString = [self urlStringForAPIMethod:@"inbox"];
    
    GOHTTPOperation *operation = [GOHTTPOperation operationWithURL:urlString method:GOHTTPMethodGET params:nil];
    [operation addCompletion:^(NSData *data) {
        NSError *parsingError = nil;
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
        if(!responseDict){
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Response string: %@", responseString);
            block(NO, responseDict);
            return;
        }
        
        NSNumber *status = [responseDict objectForKey:kCTLStatusKey];
        //NSString *message = [responseDict objectForKey:kCTLMessageKey];
        if([status intValue] == CTLSuccess){
            NSLog(@"Success: %@", responseDict);
            block(YES, responseDict);
        }else{
            block(NO, responseDict);
        }
    }];
    [_internetOperationQueue addOperation:operation];
}

- (void)logActivity:(CTLActivityType)type forContactID:(NSString *)contactID{
    NSString *urlString = [self urlStringForAPIMethod:@"activity/add"];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@(type), @"action_type", contactID, @"conact_id", nil];
    GOHTTPOperation *operation = [GOHTTPOperation operationWithURL:urlString method:GOHTTPMethodPOST params:params];
    [_internetOperationQueue addOperation:operation];
}

+ (NSString *)messageFromResponse:(NSDictionary *)response {
    NSDictionary *message = [response objectForKey:kCTLMessageKey];
    NSMutableArray *errors = [NSMutableArray array];
    
    if(message){
        for(NSString *field in message){
            NSArray *errs = [message objectForKey:field];
            for(NSInteger i=0;i<[errs count];i++){
                [errors addObject:[NSString stringWithFormat:@"%@ %@", field, errs[i]]];
            }
        }
        return [errors componentsJoinedByString:@"\n"];
    }
    
    if([response objectForKey:@"error"]){
        return [response objectForKey:@"error"];
    }
    
    return kServerErrorGeneric;

}
 
@end
