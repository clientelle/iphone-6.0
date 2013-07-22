//
//  CTLAccountManager.m
//  Clientelle
//
//  Created by Kevin Liu on 7/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLNetworkClient.h"
#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

@implementation CTLAccountManager

//+ (CTLAccountManager *) sharedInstance
//{
//	static CTLAccountManager *shared;
//	@synchronized(self)
//    {
//		if(!shared){
//			shared = [[CTLAccountManager alloc] init];
//		}
//		return shared;
//	}
//}

+ (id)sharedInstance
{
    static CTLAccountManager *shared = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

- (CTLCDAccount *)currentUser
{
    //device has only one account
    if([CTLCDAccount MR_countOfEntities] == 1){
        return [CTLCDAccount findFirst];
    }
    
    //device has mulitple accounts
    if([CTLCDAccount MR_countOfEntities] > 1){       
        int userId = [[NSUserDefaults standardUserDefaults] integerForKey:kCTLLoggedInUserId];
        if(userId){
            CTLCDAccount *account = [CTLCDAccount findFirstByAttribute:@"user_id" withValue:@(userId)];
            if(account){
                return account;
            }
        }
    }

    return nil;    
}

- (void)loginWith:(NSDictionary *)credentials onComplete:(CTLCompletionBlock)completionBlock onError:(CTLErrorBlock)errorBlock
{
    __block NSString *clear_text_password = credentials[@"user[password]"];    
    
    [[CTLNetworkClient api] post:@"login.json" params:credentials completionBlock:^(id responseObject){
        [self createAccountInCoreData:responseObject withPassword:clear_text_password completionBlock:completionBlock errorBlock:errorBlock];
    } errorBlock:^(NSError *error){
        errorBlock(error);
    }];
}

- (void)createAccount:(NSDictionary *)accountDict onComplete:(CTLCompletionBlock)completionBlock onError:(CTLErrorBlock)errorBlock
{    
    NSDictionary *postDict = [self prepareAccountDictionary:accountDict];
    __block NSString *clear_text_password = accountDict[@"password"];
    
    [[CTLNetworkClient api] post:@"register.json" params:postDict completionBlock:^(id responseObject){
        [self createAccountInCoreData:responseObject withPassword:clear_text_password completionBlock:completionBlock errorBlock:errorBlock];       
    } errorBlock:^(NSError *error){
        errorBlock(error);
    }];
}

- (void)updateAccount:(NSDictionary *)accountDict withAccount:(CTLCDAccount *)account onComplete:(CTLCompletionWithAccountBlock)completionBlock onError:(CTLErrorBlock)errorBlock
{       
    NSString *path = [NSString stringWithFormat:@"/account/%@", account.user_id];
    NSDictionary *postDict = [self prepareAccountDetailsDictionary:accountDict]; 
    
    [[CTLNetworkClient api] signedPut:path withParams:postDict completionBlock:^(id responseDict){
        [self setValues:responseDict[@"user"] forAccount:account];
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
            if(success){
                completionBlock(account, responseDict);
            }else{
                errorBlock(error);
            }
        }];
    } errorBlock:^(NSError *error){
        errorBlock(error);
    }];
}

- (void)switchAccount:(CTLCDAccount *)account onComplete:(CTLCompletionBlock)completionBlock onError:(CTLErrorBlock)errorBlock;
{
    NSDictionary *credentials = @{ @"user[email]":account.email, @"user[password]":account.password };    
    [[CTLNetworkClient api] post:@"login.json" params:credentials completionBlock:^(id responseObject){
        [self setLoggedInUserId:account.user_idValue];
        completionBlock(responseObject);
    } errorBlock:^(NSError *error){
        errorBlock(error);
    }];
}

- (CTLCDAccount *)createNewAccountFromApiResponse:(NSDictionary *)dict
{
    NSDictionary *userDict = dict[@"user"];
    CTLCDAccount *account = [CTLCDAccount findFirstByAttribute:@"user_id" withValue:userDict[@"id"]];
    
    if(!account){
        account = [CTLCDAccount createEntity];
        account.email = userDict[@"email"];
        account.user_id = userDict[@"id"];
        account.created_at = [NSDate date];
    }
    
    [self setValues:userDict forAccount:account];
    return account;
}

- (void)setValues:(NSDictionary *)dict forAccount:(CTLCDAccount *)account
{
    account.updated_at = [NSDate date];
    
    if(dict[@"authentication_token"]){
        account.auth_token = dict[@"authentication_token"];
    }
    
    if(dict[@"first_name"]){
        account.first_name = dict[@"first_name"];
    }
    
    if(dict[@"last_name"]){
        account.last_name = dict[@"last_name"];
    }
    
    if(dict[@"company"]){
        account.company = dict[@"company"][@"name"];
        account.company_id = dict[@"company"][@"id"];
    }
    
    if(dict[@"industry"]){
        account.industry = dict[@"industry"][@"name"];
        account.industry_id = dict[@"industry"][@"id"];
    }
}

- (int)getLoggedInUserId
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kCTLLoggedInUserId];
}

- (void)unsetLoggedInUserId
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kCTLLoggedInUserId];
}

- (void)setLoggedInUserId:(int)user_id
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:user_id forKey:kCTLLoggedInUserId];
    [defaults synchronize];
}

//Helpers

- (void)createAccountInCoreData:(NSDictionary *)returnData withPassword:(NSString *)password completionBlock:(CTLCompletionBlock)completionBlock errorBlock:(CTLErrorBlock)errorBlock
{
    __block CTLCDAccount *account = [self createNewAccountFromApiResponse:returnData];
    account.password = password;//store plaintext password for autologin and multiple accounts (future feature)
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        if(success){
            [self setLoggedInUserId:account.user_idValue];
            completionBlock(returnData);            
        }else{
            errorBlock(error);
        }
    }];
}

- (NSDictionary *)prepareAccountDictionary:(NSDictionary *)accountDict
{
    //required fields
    NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
    [postDict setValue:accountDict[@"email"] forKey:@"user[email]"];
    [postDict setValue:accountDict[@"password"] forKey:@"user[password]"];
    [postDict setValue:accountDict[@"password"] forKey:@"user[password_confirmation]"];
    
    //set company if present
    if([accountDict[@"company"] length] > 0){
        [postDict setValue:accountDict[@"company"] forKey:@"company[name]"];
    }
    
    //set industry if present
    if([accountDict[@"industry"] length] > 0){
        [postDict setValue:accountDict[@"industry"] forKey:@"industry[name]"];
        [postDict setValue:accountDict[@"industry_id"] forKey:@"industry[id]"];
    }
    
    //set device token if present
    NSString *deviceToken = [[NSUserDefaults standardUserDefaults] objectForKey:kCTLPushNotifToken];
    if(deviceToken){
        [postDict setValue:deviceToken forKey:@"user[apn_token]"];
    }
    
    //Set meta data for account
    [postDict setValue:[[NSLocale currentLocale] localeIdentifier] forKey:@"user[locale]"];
    [postDict setValue:@"iphone" forKey:@"user[source]"];
    
    return postDict;
}

- (NSDictionary *)prepareAccountDetailsDictionary:(NSDictionary *)accountDict
{
    NSMutableDictionary *postDict = [NSMutableDictionary dictionary];
    
    if(accountDict[@"first_name"]){
        [postDict setValue:accountDict[@"first_name"] forKey:@"user[first_name]"];
    }
    
    if(accountDict[@"last_name"]){
        [postDict setValue:accountDict[@"last_name"] forKey:@"user[last_name]"];
    }
    
    if(accountDict[@"company"]){
        [postDict setValue:accountDict[@"company"] forKey:@"company[name]"];
    }
    
    if(accountDict[@"industry"]){
        [postDict setValue:accountDict[@"industry"] forKey:@"industry[name]"];
    }
    
    if(accountDict[@"industry_id"]){
        [postDict setValue:accountDict[@"industry_id"] forKey:@"industry[id]"];
    }
    
    NSString *apn_token = [[NSUserDefaults standardUserDefaults] objectForKey:kCTLPushNotifToken];
    if(apn_token){
        [postDict setValue:apn_token forKey:@"user[apn_token]"];
    }
    
    return postDict;
}

@end
