#import "_CTLCDPerson.h"

@class CTLABPerson;

@interface CTLCDPerson : _CTLCDPerson

+ (id)createFromABPerson:(CTLABPerson *)abPerson;
- (void)updatePerson:(NSDictionary *)personDict;
+ (NSString *)addressString:(NSDictionary *)addressDict;

@end
