//
//  CTLAccountManager.h
//  Clientelle
//
//  Created by Kevin Liu on 7/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "_CTLCDAccount.h"
#import <Foundation/Foundation.h>

@class CTLCDAccount;

@interface CTLAccountManager : _CTLCDAccount

typedef void (^CTLCreateAccountCompletionBlock)(BOOL success, CTLCDAccount *account, NSError *error);

+ (CTLCDAccount *) currentUser;

+ (void)createAccount:(NSDictionary *)accountDict completionBlock:(CTLCreateAccountCompletionBlock)completionBlock;
+ (void)updateAccount:(NSDictionary *)accountDict withUser:(CTLCDAccount *)account completionBlock:(CTLCreateAccountCompletionBlock)completionBlock;

+ (CTLCDAccount *)createFromApiResponse:(NSDictionary *)dict;
+ (CTLCDAccount *)setValues:(NSDictionary *)dict forAccount:(CTLCDAccount *)account;

+ (void)recordPurchase;
+ (BOOL)userDidPurchasePro;

@end