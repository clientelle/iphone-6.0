//
//  CTLNetworkClient.m
//  Clientelle
//
//  Created by Kevin Liu on 7/20/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLNetworkClient.h"
#import "CTLAccountManager.h"
#import "CTLCDAccount.h"

#ifdef DEBUG
@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end
#endif

@implementation CTLNetworkClient

+ (CTLNetworkClient *) api
{
	static CTLNetworkClient * shared;
	@synchronized(self)
    {
		if(!shared){
			shared = [[CTLNetworkClient alloc] initWithBaseURL:[NSURL URLWithString:CTL_BASE_URL]];
            [shared registerHTTPOperationClass:[AFJSONRequestOperation class]];            
		}
		return shared;
	}
}

- (void)get:(NSString *)path params:(NSDictionary *)params completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock
{
    [self getPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        [self proccessResponse:responseObject completionBock:completionBlock errorBlock:errorBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);//AFNetworking Error
    }];
}

- (void)post:(NSString *)path params:(NSDictionary *)params completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock
{        
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        [self proccessResponse:responseObject completionBock:completionBlock errorBlock:errorBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);//AFNetworking Error
    }];
}

- (void)put:(NSString *)path params:(NSDictionary *)params completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock
{
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        [self proccessResponse:responseObject completionBock:completionBlock errorBlock:errorBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);//AFNetworking Error
    }];
}

- (void)signedGet:(NSString *)path params:(NSDictionary *)params completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock
{
    [self getPath:path parameters:[self signedParams:params] success:^(AFHTTPRequestOperation *operation, id responseObject){
        [self proccessResponse:responseObject completionBock:completionBlock errorBlock:errorBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);//AFNetworking Error
    }];
}

- (void)signedPost:(NSString *)path params:(NSDictionary *)postDict completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock
{
    [self postPath:path parameters:[self signedParams:postDict] success:^(AFHTTPRequestOperation *operation, id responseObject){
        [self proccessResponse:responseObject completionBock:completionBlock errorBlock:errorBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);//AFNetworking Error
    }];
}

- (void)signedPut:(NSString *)path params:(NSDictionary *)postDict completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock
{
    [self putPath:path parameters:[self signedParams:postDict] success:^(AFHTTPRequestOperation *operation, id responseObject){
        [self proccessResponse:responseObject completionBock:completionBlock errorBlock:errorBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);//AFNetworking Error
    }];
}

- (NSDictionary *)signedParams:(NSDictionary *)dict
{
    CTLCDAccount *currentUser = [[CTLAccountManager sharedInstance] currentUser];
    
    NSMutableDictionary *params = nil;
    
    if(dict){
        params = [dict mutableCopy];
    }else{
        params = [NSMutableDictionary dictionary];
    }
    
    [params setValue:@"json" forKey:@"format"];
    [params setValue:currentUser.auth_token forKey:@"auth_token"];
    
    return params;
}

- (void)proccessResponse:(NSDictionary *)responseObject completionBock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock
{
    if([self responseStatusIsSuccessful:responseObject]){
        //Request was succesfull
        completionBlock(responseObject);
    }else{

        //TODO: translation key!
        NSString *loginErrorTranslationKey = @"COULD_NOT_REGISTER";        
        if(responseObject[@"message"]){
            if(responseObject[@"message"][@"email"] && [responseObject[@"message"][@"email"][0]isEqualToString:@"has already been taken"]){
                loginErrorTranslationKey = @"EMAIL_TAKEN";
            }
        }
        
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(loginErrorTranslationKey, nil) };
        NSError *error = [NSError errorWithDomain:@"com.ctl.clientelle.ErrorDomain" code:100 userInfo:userInfo];
        //Application Error
        errorBlock(error);
    }
}
    
- (BOOL)responseStatusIsSuccessful:(NSDictionary *)responseDict
{
    if(responseDict[@"status"]){
        return [responseDict[@"status"] isEqualToNumber:@(0)];
    }
    
    return NO;
}

@end
