#import "CTLCDPerson.h"
#import "CTLABPerson.h"

@implementation CTLCDPerson

+ (id)createFromABPerson:(CTLABPerson *)person
{
    CTLCDPerson *cdPerson = [CTLCDPerson MR_createEntity];
    cdPerson.recordID = @(person.recordID);
    
    cdPerson.compositeName = person.compositeName;
    
    if(person.firstName){
        cdPerson.firstName = person.firstName;
    }
    if(person.lastName){
        cdPerson.lastName = person.lastName;
    }
    if(person.phone){
        cdPerson.phone = person.phone;
    }
    if(person.email){
        cdPerson.email = person.email;
    }
    if(person.jobTitle){
        cdPerson.jobTitle  = person.jobTitle;
    }
    if(person.organization){
        cdPerson.organization = person.organization;
    }
    if(person.note){
        cdPerson.note = person.note;
    }
    
    if(person.picture){
        cdPerson.picture = UIImagePNGRepresentation(person.picture);
    }
    if(person.addressDict){
        cdPerson.address = [CTLCDPerson addressString:person.addressDict];
    }
    
    cdPerson.lastAccessed = [NSDate date];

    return cdPerson;
}

- (void)updatePerson:(NSDictionary *)personDict
{
    NSString *compositeName = @"";
    
    if([personDict[CTLPersonFirstNameProperty] length] > 0){
        compositeName = [compositeName stringByAppendingString:personDict[CTLPersonFirstNameProperty]];
    }
    
    if([personDict[CTLPersonLastNameProperty] length] > 0){
        compositeName = [compositeName stringByAppendingFormat:@" %@", personDict[CTLPersonLastNameProperty]];
    }
    
    self.compositeName = compositeName;
    
    self.firstName = personDict[CTLPersonFirstNameProperty];
    self.lastName = personDict[CTLPersonLastNameProperty];
    self.phone = personDict[CTLPersonPhoneProperty];
    self.email = personDict[CTLPersonEmailProperty];
    self.jobTitle  = personDict[CTLPersonJobTitleProperty];
    self.organization = personDict[CTLPersonOrganizationProperty];
    self.note = personDict[CTLPersonNoteProperty];
    self.address = personDict[CTLPersonAddressProperty];
    self.lastAccessed = [NSDate date];
}

+ (NSString *)addressString:(NSDictionary *)addressDict
{
    NSMutableArray *addressArr = [NSMutableArray array];
    
    if(addressDict[CTLAddressStreetProperty]){
        [addressArr addObject:addressDict[CTLAddressStreetProperty]];
    }
    
    if(addressDict[CTLAddressCityProperty]){
        [addressArr addObject:addressDict[CTLAddressCityProperty]];
    }
    
    if(addressDict[CTLAddressStateProperty]){
        [addressArr addObject:addressDict[CTLAddressStateProperty]];
    }
    
    if(addressDict[CTLAddressZIPProperty]){
        [addressArr addObject:addressDict[CTLAddressZIPProperty]];
    }
    
    return [addressArr componentsJoinedByString:@", "];
}

@end
