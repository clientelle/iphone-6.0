#import "_CTLCDPerson.h"


@class CTLABPerson;

@interface CTLCDPerson : _CTLCDPerson {}

+ (id)createFromABPerson:(CTLABPerson *)abPerson;
- (void)updatePerson:(NSDictionary *)personDict;
- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues;
@end
