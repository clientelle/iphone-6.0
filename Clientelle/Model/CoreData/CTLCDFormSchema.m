#import "CTLCDFormSchema.h"

NSString *const CTLContactFormSchemaPlist = @"ABPersonSchema";

@implementation CTLCDFormSchema

+ (NSArray *)fieldsFromPlist:(NSString *)plist{
    return [[NSArray alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plist ofType:@"plist"]];
}

- (BOOL)fieldIsVisible:(id)field
{
    return [[self valueForKey:field] isEqualToNumber:[NSNumber numberWithBool:YES]];
}

@end
