//
//  CTLAccountManager.m
//  Clientelle
//
//  Created by Kevin Liu on 7/13/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAPI.h"
#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

@implementation CTLAccountManager

+ (CTLCDAccount *)currentUser
{
    //device has only one account
    if([CTLCDAccount MR_countOfEntities] == 1){
        return [CTLCDAccount findFirst];
    }
    
    //device has mulitple accounts
    if([CTLCDAccount MR_countOfEntities] > 1){       
        int userId = [[NSUserDefaults standardUserDefaults] integerForKey:kCTLLoggedInUserId];
        CTLCDAccount *account = [CTLCDAccount findFirstByAttribute:@"user_id" withValue:@(userId)];
        if(account){
            return account;
        }
    }    

    return nil;    
}

+ (void)createAccount:(NSDictionary *)accountDict completionBlock:(CTLCreateAccountCompletionBlock)completionBlock
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

    //set password so we can swith accounts
    __block NSString *password = accountDict[@"password"];
    
    CTLAPI *api = [CTLAPI sharedAPI];
    [api makeRequest:@"/register.json" withParams:postDict method:GOHTTPMethodPOST withBlock:^(BOOL requestSucceeded, NSDictionary *responseDict) {        
     
        if(requestSucceeded){
            __block CTLCDAccount *account = [CTLAccountManager createFromApiResponse:responseDict];
            account.password = password;
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){

                completionBlock(success, account, error);

                if(success){
                    //Save account user_id to NSUserDefaults for current_user login
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setInteger:account.user_idValue forKey:kCTLLoggedInUserId];
                    [defaults synchronize];
                }            
            }];

        }else{
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"COULD_NOT_CREATE_ACCOUNT", nil) };
            NSError *error = [NSError errorWithDomain:@"com.ctl.clientelle.ErrorDomain" code:100 userInfo:userInfo];
            completionBlock(NO, nil, error);
        }
    }];
}

+ (void)updateAccount:(NSDictionary *)accountDict withUser:(CTLCDAccount *)account completionBlock:(CTLCreateAccountCompletionBlock)completionBlock
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

    CTLAPI *api = [CTLAPI sharedAPI];
    NSString *path = [NSString stringWithFormat:@"/account/%@", account.user_id];
    [api makeSignedRequest:path withUser:account params:postDict method:GOHTTPMethodPUT withBlock:^(BOOL result, NSDictionary *responseDict) {
        
        if(result){
            __block CTLCDAccount *loggedInUser = [CTLCDAccount MR_findFirstByAttribute:@"user_id" withValue:account.user_id];
            
            loggedInUser = [CTLAccountManager setValues:responseDict[@"user"] forAccount:loggedInUser];
                
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
                
                completionBlock(success, loggedInUser, error);
                
            }];
        } else {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(@"COULD_NOT_UPDATE_ACCOUNT", nil) };
            NSError *error = [NSError errorWithDomain:@"com.ctl.clientelle.ErrorDomain" code:100 userInfo:userInfo];
            completionBlock(NO, nil, error);
        }        
    }];
}





+ (CTLCDAccount *)createFromApiResponse:(NSDictionary *)dict
{
    CTLCDAccount *account = [CTLCDAccount MR_createEntity];
    account.email = dict[@"user"][@"email"];
    account.user_id = dict[@"user"][@"id"];
    account.created_at = [NSDate date];
    account.is_pro = @(1);
    
    account = [CTLAccountManager setValues:dict[@"user"] forAccount:account];
    return account;
}

+ (CTLCDAccount *)setValues:(NSDictionary *)dict forAccount:(CTLCDAccount *)account
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
    
    return account;
}


+ (void)recordPurchase
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"IS_PRO"];
    [defaults synchronize];

}

+ (BOOL)userDidPurchasePro
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"IS_PRO"];
}

@end
