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
    cdPerson.address = address[CTLAddressStreetProperty];
    cdPerson.city = address[CTLAddressCityProperty];
    cdPerson.state = address[CTLAddressStateProperty];
    cdPerson.zip = address[CTLAddressZIPProperty];
    
    return cdPerson;
}

- (void)updatePerson:(NSDictionary *)personDict
{
    self.firstName = personDict[CTLPersonFirstNameProperty];
    self.lastName = personDict[CTLPersonLastNameProperty];
    self.phone = personDict[CTLPersonPhoneProperty];
    self.email = personDict[CTLPersonEmailProperty];
    self.jobTitle  = personDict[CTLPersonJobTitleProperty];
    self.organization = personDict[CTLPersonOrganizationProperty];
    self.note = personDict[CTLPersonNoteProperty];
    
    self.lastAccessed = [NSDate date];
    
    NSDictionary *address = personDict[@"addressDict"];
    self.address = address[CTLAddressStreetProperty];
    self.city = address[CTLAddressCityProperty];
    self.state = address[CTLAddressStateProperty];
    self.zip = address[CTLAddressZIPProperty];
}

@end
