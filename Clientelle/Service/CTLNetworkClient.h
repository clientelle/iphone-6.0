//
//  CTLNetworkClient.h
//  Clientelle
//
//  Created by Kevin Liu on 7/20/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "AFHTTPClient.h"

@class CTLCDAccount;

@interface CTLNetworkClient : AFHTTPClient


+ (CTLNetworkClient *) sharedClient;
typedef void (^CTLNetworkCompletionBlock)(id returnData);
typedef void (^CTLNetworkErrorBlock)(NSError *error);
typedef void (^CTLNewAccountCompletionBlock)(BOOL success, CTLCDAccount *account, NSError *error);

- (void)loginAndSync:(NSDictionary *)post withUser:(CTLCDAccount *)account withCompletionBlock:(CTLNewAccountCompletionBlock)completionBlock;

@end
