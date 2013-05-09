#import "CTLABPerson.h"
#import "CTLCDContact.h"

@implementation CTLCDContact

- (void)createFromABPerson:(CTLABPerson *)person
{
    if(person.firstName){
        self.firstName = person.firstName;
    }
    if(person.lastName){
        self.lastName = person.lastName;
    }
    
    if(person.nickName){
        self.nickName = person.nickName;
    }
    
    if(person.phone){
        self.phone = person.phone;
    }
    
    if(person.mobilePhone){
        self.mobilePhone = person.mobilePhone;
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
    self.firstName = personDict[CTLPersonFirstNameProperty];
    self.lastName = personDict[CTLPersonLastNameProperty];
    self.nickName = personDict[CTLPersonNickNameProperty];
    self.phone = personDict[CTLPersonPhoneProperty];
    self.email = personDict[CTLPersonEmailProperty];
    self.jobTitle  = personDict[CTLPersonJobTitleProperty];
    self.organization = personDict[CTLPersonOrganizationProperty];
    self.note = personDict[CTLPersonNoteProperty];
    self.address = personDict[CTLPersonAddressProperty];
    self.address2 = personDict[CTLPersonAddress2Property];
    self.lastAccessed = [NSDate date];
}

- (NSString *)compositeName
{
    NSMutableString *compositeName = [NSMutableString stringWithString:@""];
    
    if([self.firstName length] > 0){
        [compositeName appendString:self.firstName];
    }
    
    if([self.lastName length] > 0){
        if([compositeName length] == 0){
            [compositeName appendString:self.lastName];
        }else{
            [compositeName appendFormat:@" %@", self.lastName];
        }
    }
    
    return compositeName;
}

- (NSString *)cityStateZipFromAddressDict:(NSDictionary *)addressDict
{
    NSMutableString *addressStr = [NSMutableString stringWithString:@""];
    
    if(addressDict[CTLAddressCityProperty]){
        [addressStr appendString:addressDict[CTLAddressCityProperty]];
    }
    
    if(addressDict[CTLAddressStateProperty]){
        if([addressStr length] == 0){
            [addressStr appendString:addressDict[CTLAddressStateProperty]];
        }else{
            [addressStr appendFormat:@", %@", addressDict[CTLAddressStateProperty]];
        }
    }
    
    if(addressDict[CTLAddressZIPProperty]){
        if([addressStr length] > 0){
            [addressStr appendFormat:@" %@", addressDict[CTLAddressZIPProperty]];
        }else{
            [addressStr appendString:addressDict[CTLAddressZIPProperty]];
        }
    }
    
    return addressStr;
}

@end
