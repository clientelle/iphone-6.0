 //
//  CTLPersonRecord.m
//  Clientelle
//
//  Created by Kevin Liu on 9/25/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//
#import "CTLABPerson.h"
#import "CTLCDContact.h"
#import "NSString+CTLString.h"

NSString *const CTLPersonCompositeNameProperty = @"compositeName";
NSString *const CTLPersonRecordIDProperty = @"recordID";
NSString *const CTLPersonFirstNameProperty = @"firstName";
NSString *const CTLPersonLastNameProperty = @"lastName";
NSString *const CTLPersonNickNameProperty = @"nickName";
NSString *const CTLPersonOrganizationProperty = @"organization";
NSString *const CTLPersonJobTitleProperty = @"jobTitle";
NSString *const CTLPersonEmailProperty = @"email";
NSString *const CTLPersonPhoneProperty = @"phone";
NSString *const CTLPersonMobilePhoneProperty = @"mobilePhone";
NSString *const CTLPersonNoteProperty = @"note";
NSString *const CTLPersonAddressProperty = @"address";
NSString *const CTLPersonAddress2Property = @"address2";
NSString *const CTLAddressStreetProperty = @"Street";
NSString *const CTLAddressCityProperty = @"City";
NSString *const CTLAddressStateProperty = @"State";
NSString *const CTLAddressZIPProperty = @"ZIP";

NSString *const CTLLabelKey = @"label";
NSString *const CTLFieldKey = @"field";


@interface CTLABPerson()
    id copyValueFromMultiValueWithLabelKey(ABMutableMultiValueRef multi, CFStringRef labelKey);
@end

@implementation CTLABPerson

id copyValueFromMultiValueWithLabelKey(ABMutableMultiValueRef multi, CFStringRef labelKey) {
    CFIndex count = ABMultiValueGetCount(multi);
    if(count == 0){
        if(labelKey){
            CFRelease(labelKey);
        }
        return nil;
    }
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:2];
    if(count == 1){
        CFTypeRef valueRef = ABMultiValueCopyValueAtIndex(multi, 0);
        CFStringRef labelRef = ABMultiValueCopyLabelAtIndex(multi, 0);
         if(valueRef){
            [result setValue:(__bridge id)(valueRef) forKey:CTLFieldKey];
            CFRelease(valueRef);
        }
        if(labelRef){
            [result setValue:(__bridge id)(labelRef) forKey:CTLLabelKey];
            CFRelease(labelRef);
        }
        return result;
    }else{
        for(CFIndex i = 0; i < count; i++){
            CFTypeRef valueRef = ABMultiValueCopyValueAtIndex(multi, i);
            CFStringRef labelRef = ABMultiValueCopyLabelAtIndex(multi, i);
            if (labelKey && CFStringCompare(labelRef, labelKey, 0) == 0 && valueRef) {
                [result setValue:(__bridge NSString *)(valueRef) forKey:CTLFieldKey];
                [result setValue:(__bridge NSString *)(labelRef) forKey:CTLLabelKey];
                CFRelease(valueRef);
                CFRelease(labelRef);
                CFRelease(labelKey);
                return result;
               
            }
            
            if(!labelKey && valueRef){
                [result setValue:(__bridge NSString *)(valueRef) forKey:CTLFieldKey];
                [result setValue:(__bridge NSString *)(labelRef) forKey:CTLLabelKey];
                CFRelease(valueRef);
                CFRelease(labelRef);
                return result;
            }
            
            if(valueRef){
                CFRelease(valueRef);
            }
            if(labelRef){
                CFRelease(labelRef);
            }
            if(labelKey){
                CFRelease(labelKey);
            }
        }
        return nil;
    }
}

- (id)initWithRecordID:(ABRecordID)recordID withAddressBookRef:(ABAddressBookRef)addressBookRef
{
    self = [super init];
	if(self != nil){
        ABRecordRef recordRef = ABAddressBookGetPersonWithRecordID(addressBookRef, recordID);
        if(!recordRef){
            return nil;
        }
        self.addressBookRef = addressBookRef;
        self.recordID = recordID;
        self.recordRef = recordRef;
        [self personFromAddressbookRef];
    }
    return self;
}

- (id)initWithRecordRef:(ABRecordRef)recordRef withAddressBookRef:(ABAddressBookRef)addressBookRef
{
    self = [super init];
	if(self != nil){
        ABRecordID recordID = ABRecordGetRecordID(recordRef);
        if(!recordID){
            return nil;
        }
        self.addressBookRef = addressBookRef;
        self.recordID = recordID;
        self.recordRef = recordRef;
        [self personFromAddressbookRef];
    }
    return self;
}

- (void)personFromAddressbookRef
{
    [self setProperty:kABPersonNicknameProperty];
    [self setProperty:kABPersonFirstNameProperty];
    [self setProperty:kABPersonLastNameProperty];
    [self setProperty:kABPersonOrganizationProperty];
    [self setProperty:kABPersonJobTitleProperty];
    [self setProperty:kABPersonNoteProperty];
    
    CFStringRef compositeName = ABRecordCopyCompositeName(self.recordRef);
    if(compositeName){
        self.compositeName = (__bridge NSString *)compositeName;
        CFRelease(compositeName);
    }    
    
    if(ABPersonHasImageData(self.recordRef)){
        NSData *imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(self.recordRef, kABPersonImageFormatThumbnail);
        self.picture = [UIImage imageWithData:imageData];
    }
    
    //set email
    CFStringRef email = ABRecordCopyValue(self.recordRef, kABPersonEmailProperty);
    if(email){
        //prefer work email. then work down the list
        NSDictionary *emailData = copyValueFromMultiValueWithLabelKey(email, kABWorkLabel);
        if(!emailData){
            emailData = copyValueFromMultiValueWithLabelKey(email, kABHomeLabel);
        }
        if(!emailData){ //take anything!
            emailData = copyValueFromMultiValueWithLabelKey(email, nil);
        }
        if(emailData){
            self.email = [emailData objectForKey:CTLFieldKey];
            self.emailLabel = [emailData objectForKey:CTLLabelKey];
        }
        CFRelease(email);
    }
    
    //set phone number
    ABMultiValueRef phone = ABRecordCopyValue(self.recordRef, kABPersonPhoneProperty);
    if(phone){
        
        NSDictionary *phoneDict = copyValueFromMultiValueWithLabelKey(phone, kABPersonPhoneMainLabel);
        
        if(phoneDict){
            self.phone = [NSString formatPhoneNumber:[phoneDict objectForKey:CTLFieldKey]];
            //self.phoneLabel = [phoneDict objectForKey:CTLLabelKey];
        }
        
        NSDictionary *mobileDict = copyValueFromMultiValueWithLabelKey(phone, kABPersonPhoneMobileLabel);
        
        if(mobileDict){
            NSString *mobileNumber = [mobileDict objectForKey:CTLFieldKey];
            self.mobilePhone = [NSString formatPhoneNumber:mobileNumber];
            //self.mobilePhoneLabel = [mobileDict objectForKey:CTLLabelKey];
        }else{
            mobileDict = copyValueFromMultiValueWithLabelKey(phone, kABPersonPhoneIPhoneLabel);
            if(mobileDict){
                self.mobilePhone = [NSString formatPhoneNumber:[mobileDict objectForKey:CTLFieldKey]];
                //self.mobilePhoneLabel = [mobileDict objectForKey:CTLLabelKey];
            }
        }        

        
        
        CFRelease(phone);
    }
    
    //set address (location)
    ABMultiValueRef address = ABRecordCopyValue(self.recordRef, kABPersonAddressProperty);
    if(address){
        NSDictionary *addressData = copyValueFromMultiValueWithLabelKey(address, kABWorkLabel);
        if(!addressData){
            addressData = copyValueFromMultiValueWithLabelKey(address, kABHomeLabel);
        }
        if(addressData){
            self.addressDict = [addressData objectForKey:CTLFieldKey];
            self.addressLabel = [addressData objectForKey:CTLLabelKey];
        }
        CFRelease(address);
    }
}

- (void)setProperty:(ABPropertyID)propertyID
{
    CFStringRef propertyValue = ABRecordCopyValue(self.recordRef, propertyID);
    if(propertyValue){
        NSArray *field = [self.keyMap allKeysForObject:@(propertyID)];
        NSString *fieldValue = (__bridge NSString *)propertyValue;
        [self setValue:fieldValue forKey:[field objectAtIndex:0]];
        CFRelease(propertyValue);
    }
}

- (NSDictionary *)keyMap
{
    if(_keyMap == nil){
        _keyMap = @{
            CTLPersonFirstNameProperty: @(kABPersonFirstNameProperty),
            CTLPersonLastNameProperty: @(kABPersonLastNameProperty),
            CTLPersonNickNameProperty: @(kABPersonNicknameProperty),
            CTLPersonOrganizationProperty: @(kABPersonOrganizationProperty),
            CTLPersonJobTitleProperty: @(kABPersonJobTitleProperty),
            CTLPersonEmailProperty: @(kABPersonEmailProperty),
            CTLPersonPhoneProperty: @(kABPersonPhoneProperty),
            CTLPersonNoteProperty : @(kABPersonNoteProperty),
            CTLPersonAddressProperty : @(kABPersonAddressProperty)
        };
    }
    
    return _keyMap;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<%@: %@, %@>", [self class], [self compositeName], [self email]];
}

+ (void)peopleFromAddressBook:(ABAddressBookRef)addressBookRef withBlock:(CTLDictionayBlock)block
{
    ABRecordRef localSource = [CTLABPerson sourceByType:kABSourceTypeLocal addessBookRef:addressBookRef];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSource(addressBookRef, localSource);
    
    if(!allPeople){
        return;
    }
    
    CFIndex count = CFArrayGetCount(allPeople);
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    for(CFIndex i = 0;i < count; i++){
        ABRecordRef contactRef = CFArrayGetValueAtIndex(allPeople, i);
        CTLABPerson *abPerson = [[CTLABPerson alloc] initWithRecordRef:contactRef withAddressBookRef:addressBookRef];
        if(abPerson){
            [results setObject:abPerson forKey:@(abPerson.recordID)];
        }
    }
    
    block(results);
    CFRelease(allPeople);
    
}

+ (ABRecordRef)sourceByType:(ABSourceType)sourceType addessBookRef:(ABAddressBookRef)addressBookRef
{
    CFArrayRef sourcesRef = ABAddressBookCopyArrayOfAllSources(addressBookRef);
    CFIndex sourceCount = CFArrayGetCount(sourcesRef);
    
    for (CFIndex i = 0 ; i < sourceCount; i++) {
        ABRecordRef currentSource = CFArrayGetValueAtIndex(sourcesRef, i);
        CFTypeRef sourceTypeRef = ABRecordCopyValue(currentSource, kABSourceTypeProperty);
        if (sourceType == [(__bridge NSNumber *)sourceTypeRef intValue]) {
            CFRelease(sourcesRef);
            CFRelease(sourceTypeRef);
            return currentSource;
        }
        CFRelease(sourceTypeRef);
    }
    
    CFRelease(sourcesRef);
    return nil;
}

+ (BOOL)deletePerson:(ABRecordRef)recordRef withAddressBook:(ABAddressBookRef)addressBookRef
{
    __block BOOL result = NO;
    CFErrorRef error = NULL;
    if(ABAddressBookRemoveRecord(addressBookRef, recordRef, &error)){
        result = ABAddressBookSave(addressBookRef, &error);
    }
    
    return result;
}

@end
