#import "CTLCDFormSchema.h"

NSString *const CTLABPersonSchemaPlist = @"ABPersonSchema";
NSString *const CTLAddressSchemaPlist = @"AddressFields";

NSString *const kCTLFieldName = @"name";
NSString *const kCTLFieldValue = @"value";
NSString *const kCTLFieldLabel = @"label";
NSString *const kCTLFieldPlaceHolder = @"placeholder";
NSString *const kCTLFieldEnabled = @"enabled";
NSString *const kCTLFieldKeyboardType = @"keyboardType";

@implementation CTLCDFormSchema

+ (NSArray *)fieldsFromPlist:(NSString *)plist{
    return [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]];
}



@end
