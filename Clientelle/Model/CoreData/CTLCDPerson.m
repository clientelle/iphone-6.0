#import "CTLCDPerson.h"
#import "CTLABPerson.h"

@implementation CTLCDPerson

+ (id)createFromABPerson:(CTLABPerson *)person
{
    CTLCDPerson *cdPerson = [CTLCDPerson MR_createEntity];
    cdPerson.recordID = @(person.recordID);
    cdPerson.firstName = person.firstName;
    cdPerson.lastName = person.lastName;
    cdPerson.phone = person.phone;
    cdPerson.email = person.email;
    cdPerson.jobTitle  = person.jobTitle;
    cdPerson.organization = person.organization;
    cdPerson.note = person.note;
    cdPerson.lastAccessed = [NSDate date];
    
    NSDictionary *address = person.addressDict;
    cdPerson.address = address[@"Street"];
    cdPerson.city = address[@"City"];
    cdPerson.state = address[@"State"];
    cdPerson.zip = address[@"ZIP"];
    
    return cdPerson;
}

- (void)updatePerson:(NSDictionary *)personDict
{
    self.firstName = personDict[@"firstName"];
    self.lastName = personDict[@"lastName"];
    self.phone = personDict[@"phone"];
    self.email = personDict[@"email"];
    self.jobTitle  = personDict[@"jobTitle"];
    self.organization = personDict[@"organization"];
    self.note = personDict[@"note"];
    
    self.lastAccessed = [NSDate date];
    
    NSDictionary *address = personDict[@"addressDict"];
    self.address = address[@"Street"];
    self.city = address[@"City"];
    self.state = address[@"State"];
    self.zip = address[@"ZIP"];
    
}

- (void)safeSetValuesForKeysWithDictionary:(NSDictionary *)keyedValues
{
    NSDictionary *attributes = [[self entity] attributesByName];
    for (NSString *attribute in attributes) {
        id value = [keyedValues objectForKey:attribute];
        if (value == nil) {
            // Don't attempt to set nil, or you'll overwite values in self that aren't present in keyedValues
            continue;
        }
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
        if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
            value = [value stringValue];
        } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithInteger:[value  integerValue]];
        } else if ((attributeType == NSFloatAttributeType) && ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        }else if (([value isKindOfClass:[NSDictionary class]])){
            continue;
        }
        [self setValue:value forKey:attribute];
    }
}

@end
