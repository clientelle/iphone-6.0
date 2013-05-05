#import "_CTLCDPerson.h"

@class CTLABPerson;

@interface CTLCDPerson : _CTLCDPerson

- (void)updatePerson:(NSDictionary *)personDict;
- (void)updateFromABPerson:(CTLABPerson *)person;

@end
