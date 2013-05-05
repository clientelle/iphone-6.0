#import "CTLCDPerson.h"
#import "CTLABPerson.h"

@implementation CTLCDPerson

- (void)updateFromABPerson:(CTLABPerson *)person
{
    self.compositeName = person.compositeName;
    
    if(person.firstName){
        self.firstName = person.firstName;
    }
    if(person.lastName){
        self.lastName = person.lastName;
    }
    if(person.phone){
        self.phone = person.phone;
    }
    if(person.email){
        self.email = person.email;
    }
    if(person.jobTitle){
        self.jobTitle  = person.jobTitle;
    }
    if(person.organization){
        self.organization = person.organization;
    }
    if(person.note){
        self.note = person.note;
    }
    
    if(person.picture){
        self.picture = UIImagePNGRepresentation(person.picture);
    }
    
    if(person.addressDict){
        if(person.addressDict[CTLAddressStreetProperty]){
            self.address = person.addressDict[CTLAddressStreetProperty];
        }
        self.address2 = [self cityStateZipFromAddressDict:person.addressDict];
    }
    self.lastAccessed = [NSDate date];
}

- (void)updatePerson:(NSDictionary *)personDict
{
    NSString *compositeName = @"";
    
    if([personDict[CTLPersonFirstNameProperty] length] > 0){
        compositeName = [compositeName stringByAppendingString:personDict[CTLPersonFirstNameProperty]];
    }
    
    if([personDict[CTLPersonLastNameProperty] length] > 0){
        if([compositeName length] > 0){
            compositeName = [compositeName stringByAppendingFormat:@" %@", personDict[CTLPersonLastNameProperty]];
        }else{
            compositeName = personDict[CTLPersonLastNameProperty];
        }
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

- (NSString *)cityStateZipFromAddressDict:(NSDictionary *)addressDict
{
    NSMutableArray *addressArr = [NSMutableArray array];
    
    if(addressDict[CTLAddressCityProperty]){
        [addressArr addObject:addressDict[CTLAddressCityProperty]];
    }
    
    if(addressDict[CTLAddressStateProperty]){
        [addressArr addObject:addressDict[CTLAddressStateProperty]];
    }
    
    if(addressDict[CTLAddressZIPProperty]){
        [addressArr addObject:addressDict[CTLAddressZIPProperty]];
    }
    
    return [addressArr componentsJoinedByString:@" "];
}

@end
