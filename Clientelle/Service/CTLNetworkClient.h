//
//  CTLNetworkClient.h
//  Clientelle
//
//  Created by Kevin Liu on 7/20/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "AFHTTPClient.h"

@interface CTLNetworkClient : AFHTTPClient

typedef void (^CTLNetworkCompletionBlock)(id responseDict);
typedef void (^CTLNetworkErrorBlock)(NSError *error);

+ (CTLNetworkClient *) api;

- (void)get:(NSString *)path params:(NSDictionary *)params completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock;

- (void)post:(NSString *)path params:(NSDictionary *)params completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock;

- (void)put:(NSString *)path params:(NSDictionary *)params completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock;

- (void)signedPost:(NSString *)path withParams:(NSDictionary *)postDict completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock;

- (void)signedPut:(NSString *)path withParams:(NSDictionary *)postDict completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock;

@end
