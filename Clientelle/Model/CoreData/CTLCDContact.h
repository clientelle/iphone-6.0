#import "_CTLCDContact.h"

@class CTLABPerson;

@interface CTLCDContact : _CTLCDContact

- (void)updatePerson:(NSDictionary *)personDict;
- (void)createFromABPerson:(CTLABPerson *)person;

- (NSString *)compositeName;

@end
