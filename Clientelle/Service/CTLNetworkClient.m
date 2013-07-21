//
//  CTLNetworkClient.m
//  Clientelle
//
//  Created by Kevin Liu on 7/20/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLNetworkClient.h"

#ifdef DEBUG
@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end
#endif

@implementation CTLNetworkClient

+ (CTLNetworkClient *) sharedClient
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

- (void)loginAndSync:(NSDictionary *)post withUser:(CTLCDAccount *)account withCompletionBlock:(CTLNewAccountCompletionBlock)completionBlock
{
    
   [self postPath:@"/login.json" parameters:post success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
       NSLog(@"REPONSE %@", responseObject);
        //BOOL success = [
        //completionBlock(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //errorBlock(error);
        
    }];
    
}

@end
