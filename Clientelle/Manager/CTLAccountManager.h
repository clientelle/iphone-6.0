//
//  CTLAccountManager.h
//  Clientelle
//
//  Created by Kevin Liu on 7/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTLCDAccount;
@class CTLCDContact;

@interface CTLAccountManager : NSObject

typedef void (^CTLCompletionBlock)(NSDictionary *responseObject);
typedef void (^CTLCompletionWithAccountBlock)(CTLCDAccount *account, NSDictionary *responseObject);
typedef void (^CTLCompletionWithInviteTokenBlock)(NSString *inviteToken);
typedef void (^CTLErrorBlock)(NSError *error);

+ (id)sharedInstance;

- (CTLCDAccount *)currentUser;

- (void)loginWith:(NSDictionary *)credentials onComplete:(CTLCompletionBlock)completionBlock onError:(CTLErrorBlock)errorBlock;
- (void)createAccount:(NSDictionary *)accountDict onComplete:(CTLCompletionBlock)completionBlock onError:(CTLErrorBlock)errorBlock;
- (void)updateAccount:(NSDictionary *)accountDict withAccount:(CTLCDAccount *)account onComplete:(CTLCompletionWithAccountBlock)completionBlock onError:(CTLErrorBlock)errorBlock;

- (void)switchAccount:(CTLCDAccount *)account onComplete:(CTLCompletionBlock)completionBlock onError:(CTLErrorBlock)errorBlock;

- (void)unsetLoggedInUserId;
- (void)setLoggedInUserId:(int)user_id;
- (int)getLoggedInUserId;

- (NSString *)generatePassword;

- (void)createInviteLinkWithContact:(CTLCDContact *)contact onComplete:(CTLCompletionWithInviteTokenBlock)completionBlock onError:(CTLErrorBlock)errorBlock;
- (void)syncInvites:(CTLErrorBlock)errorBlock;

@end