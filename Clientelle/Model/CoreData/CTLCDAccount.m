#import "CTLCDAccount.h"

@implementation CTLCDAccount

+ (CTLCDAccount *)createFromDictionary:(NSDictionary *)dict;
{
    NSDictionary *user = dict[@"user"];
    
    CTLCDAccount *account = [self MR_createEntity];
    account.email = user[@"email"];
    account.password = user[@"password"];
    account.created_at = [NSDate date];
    account.user_id = user[@"id"];
    account.is_pro = @(1);
    
    if(user[@"authentication_token"]){
        account.auth_token = user[@"authentication_token"];
    }
    
    if(user[@"company"]){
        account.company = user[@"company"][@"name"];
        account.company_id = user[@"company"][@"id"];
    }
    
    if(user[@"industry"]){
        account.industry = user[@"industry"][@"name"];
        account.industry_id = user[@"industry"][@"id"];
    }

    return account;
}

@end
