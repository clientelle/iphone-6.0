//
//  CTLPhoneNumberFormatter.m
//  Clientelle
//
//  Created by Ahmed Abdelkader on 1/22/10.
//  This work is licensed under a Creative Commons Attribution 3.0 License.
//

#import "CTLPhoneNumberFormatter.h"

@implementation CTLPhoneNumberFormatter

- (id)init
{
    self = [super init];
    
    if(self != nil){
        NSArray *us = @[@"+1 (###) ###-####", @"1 (###) ###-####", @"011 $", @"###-####", @"(###) ###-####"];
        NSArray *uk = @[@"+44 ##########", @"00 $", @"0### - ### ####", @"0## - #### ####", @"0#### - ######"];
        NSArray *jp = @[@"+81 ############", @"001 $", @"(0#) #######", @"(0#) #### ####"];
        
        _predefinedFormats = @{@"US":us, @"GB":uk, @"JP":jp};
        _countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    }
    return self;
}

- (NSString *)formatPhone:(NSString *)number
{
    NSArray *localeFormats = [_predefinedFormats objectForKey:_countryCode];
    NSString *input = [self strip:number];
    
    for(NSString *phoneFormat in localeFormats) {
        int i = 0;
        NSMutableString *temp = [[NSMutableString alloc] init];
        for(int p = 0; temp != nil && i < [input length] && p < [phoneFormat length]; p++) {
            unichar c = [phoneFormat characterAtIndex:p];
            BOOL required = [self canBeInputByPhonePad:c];
            unichar next = [input characterAtIndex:i];
            switch(c) {
                case '$':
                    p--;
                    [temp appendFormat:@"%c", next]; i++;
                    break;
                case '#':
                    if(next < '0' || next > '9') {
                        temp = nil;
                        break;
                    }
                    [temp appendFormat:@"%c", next]; i++;
                    break;
                default:
                    if(required) {
                        if(next != c) {
                            temp = nil;
                            break;
                        }
                        [temp appendFormat:@"%c", next]; i++;
                    } else {
                        [temp appendFormat:@"%c", c];
                        if(next == c) i++;
                    }
                    break;
            }
        }
        
        if(i == [input length]) {
            return temp;
        }
    }
    return input;
}

- (NSString *)strip:(NSString *)phoneNumber {
    NSMutableString *res = [[NSMutableString alloc] init];
    for(NSUInteger i = 0; i < [phoneNumber length]; i++) {
        unichar next = [phoneNumber characterAtIndex:i];
        if([self canBeInputByPhonePad:next]){
            [res appendFormat:@"%c", next];
        }
        
    }
    return res;
}

- (BOOL)canBeInputByPhonePad:(unichar)c {
    if(c == '+' || c == '*' || c == '#'){
        return YES;
    }
    if(c >= '0' && c <= '9'){
        return YES;
    }    
    return NO;
}

@end
