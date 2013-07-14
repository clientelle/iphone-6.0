#import "CTLABPerson.h"
#import "CTLCDContact.h"

@implementation CTLCDContact

- (void)createFromABPerson:(CTLABPerson *)person
{
    if(person.compositeName){
        self.compositeName = person.compositeName;
    }
    
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
    
    if(person.mobile){
        self.mobile = person.mobile;
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

- (NSString *)displayContactStr
{
    NSString *contactStr = @"";
        
    if([self.mobile length] > 0){
        contactStr = self.mobile;
    }else if([self.phone length] > 0){
        contactStr = self.phone;
    }else if([self.email length] > 0){
        contactStr = self.email;
    }else if([self.address length] >0){
        contactStr = self.address;
    }else if([self.organization length] >0){
        contactStr = self.organization;
    }
    
    return contactStr;
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
