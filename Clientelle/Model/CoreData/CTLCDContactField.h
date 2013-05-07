#import "_CTLCDContactField.h"

extern NSString *const kCTLFieldName;
extern NSString *const kCTLFieldValue;
extern NSString *const kCTLFieldLabel;
extern NSString *const kCTLFieldEnabled;
extern NSString *const kCTLFieldPlaceholder;
extern NSString *const kCTLFieldKeyboardType;
extern NSString *const kCTLFieldSortOrder;
extern NSString *const kCTLFieldAutoCapitalizeType;
extern NSString *const kCTLFieldAutoCorrectionType;

@interface CTLCDContactField : _CTLCDContactField {}

- (NSString *)label;
- (NSString *)placeholder;

+ (NSArray *)fetchSortedFields;
+ (NSArray *)generateFieldsFromSchema:(NSEntityDescription *)entity;

@end
