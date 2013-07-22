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

- (void)signedPost:(NSString *)path withParams:(NSDictionary *)postDict completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock
{
    NSDictionary *params = [self signedParams:postDict];    
    [self postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        [self proccessResponse:responseObject completionBock:completionBlock errorBlock:errorBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);//AFNetworking Error
    }];
}

- (void)signedPut:(NSString *)path withParams:(NSDictionary *)postDict completionBlock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock
{
    NSDictionary *params = [self signedParams:postDict];
    [self putPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
        [self proccessResponse:responseObject completionBock:completionBlock errorBlock:errorBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        errorBlock(error);//AFNetworking Error
    }];
}

- (NSDictionary *)signedParams:(NSDictionary *)dict
{
    CTLCDAccount *currentUser = [[CTLAccountManager sharedInstance] currentUser];
    NSDictionary *params = [dict mutableCopy];
    [params setValue:@"json" forKey:@"format"];
    [params setValue:currentUser.auth_token forKey:@"auth_token"];
    
    return params;
}

- (void)proccessResponse:(NSDictionary *)responseObject completionBock:(CTLNetworkCompletionBlock)completionBlock errorBlock:(CTLNetworkErrorBlock)errorBlock
{
    if([self responseStatus:responseObject]){
        //Request was succesfull
        completionBlock(responseObject);
    }else{
        //TODO: translaßtion key!
        NSString *loginErrorTranslationKey = (responseObject[@"error"]) ? responseObject[@"error"] : @"COULD_NOT_LOGIN";
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : NSLocalizedString(loginErrorTranslationKey, nil) };
        NSError *error = [NSError errorWithDomain:@"com.ctl.clientelle.ErrorDomain" code:100 userInfo:userInfo];
        //Application Error
        errorBlock(error);
    }
}
    
- (BOOL)responseStatus:(NSDictionary *)responseDict
{
    if(responseDict[@"status"]){
        return [responseDict[@"status"] isEqualToNumber:@(0)];
    }
    
    return NO;
}

@end
