#import "CTLCDFormSchema.h"

NSString *const CTLContactFormSchema = @"ABPersonSchema";
NSString *const CTLAddressSchemaPlist = @"AddressFields";

NSString *const kCTLFieldName = @"field";
NSString *const kCTLFieldValue = @"value";
NSString *const kCTLFieldLabel = @"label";

NSString *const kCTLFieldEnabled = @"enabled";
NSString *const kCTLFieldPlaceholder = @"placeholder";
NSString *const kCTLFieldKeyboardType = @"keyboardType";


@implementation CTLCDFormSchema

+ (NSArray *)fieldsFromPlist:(NSString *)plist{
    return [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]];
}

- (BOOL)fieldIsVisible:(id)field
{
    
    BOOL result = [[self valueForKey:field] isEqualToNumber:[NSNumber numberWithBool:YES]];
    
    NSLog(@"FIELD %@ | HIDDEN %i", field, result);
    
    return result;
}

@end
