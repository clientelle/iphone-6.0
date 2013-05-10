//
//  NSString+CTLString.m
//  Clientelle
//
//  Created by Kevin Liu on 9/26/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "NSString+CTLString.h"
#import "RMPhoneFormat.h"

@implementation NSString (CTLString)

+ (NSString *)cleanPhoneNumber:(NSString *)phoneNumber {
    NSString *cleanPhoneNumber;
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[-\\s\\(\\)]" options:NSRegularExpressionCaseInsensitive error:&error];
    cleanPhoneNumber = [regex stringByReplacingMatchesInString:phoneNumber options:0 range:NSMakeRange(0, [phoneNumber length]) withTemplate:@""];
    return cleanPhoneNumber;
}

+ (NSString *)formatPhoneNumber:(NSString *)phoneNumber
{
    static RMPhoneFormat *formatter = nil;
    static NSString *formattedNumber;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        formatter = [[RMPhoneFormat alloc] init];
    });
    
    formattedNumber = [formatter format:phoneNumber];
    return formattedNumber;
   
}

+ (NSString *)trim:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
