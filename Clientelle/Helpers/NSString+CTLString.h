//
//  NSString+CTLString.h
//  Clientelle
//
//  Created by Kevin Liu on 9/26/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CTLString)

+ (NSString *)cleanPhoneNumber:(NSString *)phoneNumber;
+ (NSString *)formatPhoneNumber:(NSString *)phoneNumber;
+ (NSString *)trim:(NSString *)string;

@end
