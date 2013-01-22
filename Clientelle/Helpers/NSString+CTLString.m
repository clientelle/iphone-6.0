//
//  NSString+CTLString.m
//  Clientelle
//
//  Created by Kevin Liu on 9/26/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "NSString+CTLString.h"

@implementation NSString (CTLString)

+ (NSString *)cleanPhoneNumber:(NSString *)phoneNumber {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[-\\s\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *cleanPhoneNumber = [regex stringByReplacingMatchesInString:phoneNumber options:0 range:NSMakeRange(0, [phoneNumber length]) withTemplate:@""];
    
    if(error){
        //TODO: Handle error
    }
    
    return cleanPhoneNumber;
}

+ (NSString *)trim:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
