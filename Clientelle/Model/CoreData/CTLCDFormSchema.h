#import "_CTLCDFormSchema.h"

extern NSString *const CTLContactFormSchemaPlist;

@interface CTLCDFormSchema : _CTLCDFormSchema

+ (NSArray *)fieldsFromPlist:(NSString *)plist;
- (BOOL)fieldIsVisible:(id)field;

@end
