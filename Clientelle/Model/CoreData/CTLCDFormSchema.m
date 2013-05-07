#import "CTLCDFormSchema.h"

NSString *const CTLContactFormSchemaPlist = @"ABPersonSchema";

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
    return [[self valueForKey:field] isEqualToNumber:[NSNumber numberWithBool:YES]];
}

@end
