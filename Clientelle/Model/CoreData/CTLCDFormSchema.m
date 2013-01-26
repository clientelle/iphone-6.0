#import "CTLCDFormSchema.h"

NSString *const CTLABPersonSchemaPlist = @"ABPersonSchema";
NSString *const CTLAddressSchemaPlist = @"AddressFields";

NSString *const kCTLFieldName = @"name";
NSString *const kCTLFieldValue = @"value";
NSString *const kCTLFieldLabel = @"label";
NSString *const kCTLFieldPlaceHolder = @"placeholder";
NSString *const kCTLFieldEnabled = @"enabled";
NSString *const kCTLFieldType = @"type";
NSString *const kCTLFieldKeyboardType = @"keyboardType";

@implementation CTLCDFormSchema

+ (NSArray *)fieldsFromPlist:(NSString *)plist
{
    return [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]];
}

+ (NSDictionary *)dictionaryFromJSONData:(NSData *)jsonData
{
    NSError *error = nil;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    return result;
}

@end
