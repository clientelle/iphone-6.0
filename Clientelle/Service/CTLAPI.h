//
//  CTLAPI.h
//  Clientelle
//
//  Created by Samuel Goodwin on 3/24/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GOHTTPOperation.h"

typedef void (^CTLResultBlock)(BOOL requestSucceeded, NSDictionary *response);

typedef enum{
    CTLActivityTypeCall = 1,
    CTLActivityTypeEmail = 2,
    CTLActivityTypeSms = 3
}CTLActivityType;

extern NSString *const kResponseKey;
extern NSString *const kCTLMessageKey;
extern NSString *const kCTLStatusKey;
extern NSString *const kCTLResponseKey;
extern NSString *const kCTLAuthTokenKey;


@interface CTLAPI : NSObject {
    NSOperationQueue *_internetOperationQueue;
}

+ (id)sharedAPI;

- (BOOL)hasInternetConnection;

- (void)makeRequest:(NSString *)path withBlock:(CTLResultBlock)block;
- (void)makeRequest:(NSString *)path withParams:(NSDictionary *)params andWait:(CTLResultBlock)block;
- (void)makeRequest:(NSString *)path withParams:(NSDictionary *)params method:(GOHTTPMethod)method withBlock:(CTLResultBlock)block;
- (void)makeRequest:(NSString *)path andWait:(CTLResultBlock)block;

- (void)loginWithEmail:(NSString *)email password:(NSString *)password andBlock:(CTLResultBlock)block;
- (void)submitContacts:(NSSet *)contacts withBlock:(CTLResultBlock)block;
- (void)fetchInboxWithBlock:(CTLResultBlock)block;
- (void)logActivity:(CTLActivityType)type forContactID:(NSString *)contactID;

+ (NSString *)messageFromResponse:(NSDictionary *)response;

@end
