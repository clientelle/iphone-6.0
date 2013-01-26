#import "_CTLCDFormSchema.h"

extern NSString *const CTLABPersonSchemaPlist;
extern NSString *const CTLAddressSchemaPlist;

extern NSString *const kCTLFieldName;
extern NSString *const kCTLFieldValue;
extern NSString *const kCTLFieldLabel;
extern NSString *const kCTLFieldEnabled;
extern NSString *const kCTLFieldPlaceHolder;
extern NSString *const kCTLFieldType;
extern NSString *const kCTLFieldKeyboardType;

typedef enum{
    CTLInputTypeText = 0,
    CTLInputTypeTextView = 1
}CTLInputType;


@interface CTLCDFormSchema : _CTLCDFormSchema

+ (NSArray *)fieldsFromPlist:(NSString *)plist;
+ (NSDictionary *)dictionaryFromJSONData:(NSData *)jsonData;

@end
