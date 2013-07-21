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

@interface CTLAccountManager : NSObject

typedef void (^CTLCreateAccountCompletionBlock)(BOOL success, CTLCDAccount *account, NSError *error);

+ (CTLCDAccount *) currentUser;
+ (void)createDefaultAccount;
+ (void)createAccount:(NSDictionary *)accountDict withUser:(CTLCDAccount *)account completionBlock:(CTLCreateAccountCompletionBlock)completionBlock;
+ (void)updateAccount:(NSDictionary *)accountDict withUser:(CTLCDAccount *)account completionBlock:(CTLCreateAccountCompletionBlock)completionBlock;
+ (void)loginAndSync:(NSDictionary *)post withUser:(CTLCDAccount *)account withCompletionBlock:(CTLCreateAccountCompletionBlock)completionBlock;
+ (void)switchAccount:(CTLCDAccount *)account withCompletionBlock:(CTLCreateAccountCompletionBlock)completionBlock;

+ (CTLCDAccount *)createFromApiResponse:(NSDictionary *)dict withAccount:(CTLCDAccount *)account;
+ (CTLCDAccount *)setValues:(NSDictionary *)dict forAccount:(CTLCDAccount *)account;

+ (void)unsetLoggedInUserId;
+ (void)setLoggedInUserId:(int)user_id;
+ (int)getLoggedInUserId;

@end