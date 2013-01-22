//
//  CTLPhoneNumberFormater.h
//  Clientelle
//
//  Created by Kevin Liu on 10/29/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTLPhoneNumberFormatter : NSObject {
    NSDictionary *_predefinedFormats;
    NSString *_countryCode;
}

- (id)init;

- (NSString *)formatPhone:(NSString *)number;
- (NSString *)strip:(NSString *)phoneNumber;
- (BOOL)canBeInputByPhonePad:(unichar)c;

@end
