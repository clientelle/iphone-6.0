#import "_CTLCDFormSchema.h"

extern NSString *const CTLContactFormSchema;
extern NSString *const CTLAddressSchemaPlist;

extern NSString *const kCTLFieldName;
extern NSString *const kCTLFieldValue;
extern NSString *const kCTLFieldLabel;
extern NSString *const kCTLFieldEnabled;
extern NSString *const kCTLFieldPlaceholder;
extern NSString *const kCTLFieldKeyboardType;

@interface CTLCDFormSchema : _CTLCDFormSchema

+ (NSArray *)fieldsFromPlist:(NSString *)plist;
- (BOOL)fieldIsVisible:(id)field;

@end
