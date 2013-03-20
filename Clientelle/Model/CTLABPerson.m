 //
//  CTLPersonRecord.m
//  Clientelle
//
//  Created by Kevin Liu on 9/25/12.
//  Copyright (c) 2012 Clientelle Ltd.. All rights reserved.
//
#import "CTLABPerson.h"
#import "NSString+CTLString.h"

NSString *const CTLPersonCompositeNameProperty = @"compositeName";
NSString *const CTLPersonRecordIDProperty = @"recordID";
NSString *const CTLPersonFirstNameProperty = @"firstName";
NSString *const CTLPersonLastNameProperty = @"lastName";
NSString *const CTLPersonOrganizationProperty = @"organization";
NSString *const CTLPersonJobTitleProperty = @"jobTitle";
NSString *const CTLPersonEmailProperty = @"email";
NSString *const CTLPersonPhoneProperty = @"phone";
NSString *const CTLPersonNoteProperty = @"note";
NSString *const CTLPersonCreatedDateProperty = @"creationDate";
NSString *const CTLPersonAddressProperty = @"address";
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
        [self personFromRef:recordRef];
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
        [self personFromRef:recordRef];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)fields withAddressBookRef:(ABAddressBookRef)addressBookRef
{
    self = [super init];
	if(self != nil){
        ABRecordRef sourceRef = [CTLABPerson sourceByType:kABSourceTypeLocal addessBookRef:addressBookRef];
        ABRecordRef recordRef = ABPersonCreateInSource(sourceRef);
        if(!recordRef){
            return nil;
        }
        self.addressBookRef = addressBookRef;
        self.recordRef = recordRef;
        
        BOOL result = [self setFieldsToDictionary:fields];
        if(result){
            CFErrorRef abAddRecordError = NULL, abSaveError = NULL;
            //TODO: Error Handling
            if(ABAddressBookAddRecord(self.addressBookRef, self.recordRef, &abAddRecordError)){
                if(ABAddressBookSave(self.addressBookRef, &abSaveError)){
                    NSLog(@"SAVED!! YAY");
                    self.recordID = ABRecordGetRecordID(recordRef);
                    [self personFromRef:recordRef];
                }else{
                    NSLog(@"ERROR!! BOO %@", abSaveError);
                }
            }else{
                 NSLog(@"ERROR!! BOO %@", abAddRecordError);
            }
        }
    }
    
    return self;
}

- (void)personFromRef:(ABRecordRef)recordRef
{
    CFStringRef compositeName = ABRecordCopyCompositeName(recordRef);
    if(compositeName){
        self.compositeName = (__bridge NSString *)compositeName;
        CFRelease(compositeName);
    }
    
    if(ABPersonHasImageData(recordRef)){
        NSData *imageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(recordRef, kABPersonImageFormatThumbnail);
        self.picture = [UIImage imageWithData:imageData];
    }else{
        self.picture = [UIImage imageNamed:@"default-pic.png"];
    }
    
    [self setProperty:kABPersonFirstNameProperty];
    [self setProperty:kABPersonLastNameProperty];
    [self setProperty:kABPersonOrganizationProperty];
    [self setProperty:kABPersonJobTitleProperty];
    [self setProperty:kABPersonNoteProperty];
    [self setProperty:kABPersonCreationDateProperty];
    
    //set email
    CFStringRef email = ABRecordCopyValue(recordRef, kABPersonEmailProperty);
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
    ABMultiValueRef phone = ABRecordCopyValue(recordRef, kABPersonPhoneProperty);
    if(phone){
        NSDictionary *phoneData = copyValueFromMultiValueWithLabelKey(phone, kABPersonPhoneMobileLabel);
        if(!phoneData){
            phoneData = copyValueFromMultiValueWithLabelKey(phone, kABPersonPhoneMainLabel);
        }
        if(!phoneData){
            phoneData = copyValueFromMultiValueWithLabelKey(phone, kABPersonPhoneIPhoneLabel);
        }
        if(!phoneData){
            //take anything!
            phoneData = copyValueFromMultiValueWithLabelKey(phone, nil);
        }
        if(phoneData){
            NSString *phoneNumber = [phoneData objectForKey:CTLFieldKey];
            self.phone = [NSString formatPhoneNumber:phoneNumber];
            self.phoneLabel = [phoneData objectForKey:CTLLabelKey];
        }
        CFRelease(phone);
    }
    
    //set address (location)
    ABMultiValueRef address = ABRecordCopyValue(recordRef, kABPersonAddressProperty);
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

- (CTLABPerson *)updateWithDictionary:(NSDictionary *)fields
{
    BOOL result = [self setFieldsToDictionary:fields];
    
    if(!result){
        return self;
    }else{
        ABRecordID recordID = self.recordID; //memoize to use later
        CFErrorRef abAddError = NULL, abSaveError = NULL;
        if(ABAddressBookAddRecord(self.addressBookRef, self.recordRef, &abAddError)){
            if(ABAddressBookSave(self.addressBookRef, &abSaveError)){
                NSLog(@"SAVED!!");
            }
        }else{
            NSLog(@"ERROR2 %@", abAddError);
        }
        
        //After record is updated get new copy of abPerson
        CFErrorRef error;
        ABAddressBookRef newABRef = ABAddressBookCreateWithOptions(NULL, &error); //Requires new ABRef
        CTLABPerson *abPerson = [[CTLABPerson alloc] initWithRecordID:recordID withAddressBookRef:newABRef];
        abPerson.addressBookRef = self.addressBookRef;
        return abPerson;
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
            CTLPersonOrganizationProperty: @(kABPersonOrganizationProperty),
            CTLPersonJobTitleProperty: @(kABPersonJobTitleProperty),
            CTLPersonEmailProperty: @(kABPersonEmailProperty),
            CTLPersonPhoneProperty: @(kABPersonPhoneProperty),
            CTLPersonNoteProperty : @(kABPersonNoteProperty),
            CTLPersonCreatedDateProperty: @(kABPersonCreationDateProperty),
            CTLPersonAddressProperty : @(kABPersonAddressProperty)
        };
    }
    
    return _keyMap;
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<%@: %@, %@>", [self class], [self compositeName], [self email]];
}

- (BOOL)setFieldsToDictionary:(NSDictionary *)fields
{
    CFStringRef emailPropertyLabel = NULL;
    CFStringRef phonePropertyLabel = NULL;
    CFStringRef addressPropertyLabel = NULL;
    
    if(self.recordID == kABRecordInvalidID){
        //new user; default phone and email label keys
        emailPropertyLabel = kABWorkLabel;
        phonePropertyLabel = kABPersonPhoneMainLabel;
        addressPropertyLabel = kABHomeLabel;
    }else{
        emailPropertyLabel = (__bridge CFStringRef)(self.emailLabel);
        phonePropertyLabel = (__bridge CFStringRef)(self.phoneLabel);
        addressPropertyLabel = (__bridge CFStringRef)(self.addressLabel);
    }

    __block BOOL contactDidChange = NO;
    
    [fields enumerateKeysAndObjectsUsingBlock:^(id fieldName, id propertyValue, BOOL *stop){
        
        //filter out non keyed values
        NSNumber *fieldKey = [self.keyMap objectForKey:fieldName];
        
        if(fieldKey != (id)[NSNull null]){
            ABPropertyID propertyKey = (ABPropertyID)[fieldKey intValue];
            
            if(propertyKey == kABPersonAddressProperty){
                CFErrorRef error = NULL;
                ABMutableMultiValueRef multiRef = ABMultiValueCreateMutable(kABDictionaryPropertyType);
                ABMultiValueAddValueAndLabel(multiRef, (__bridge CFDictionaryRef)(propertyValue), addressPropertyLabel, NULL);
                 
                if(!ABRecordSetValue(self.recordRef, propertyKey, multiRef, &error)){
                    //[self alertErrorMessage:error];
                    NSLog(@"Couldn't save addressDict");
                }
                CFRelease(multiRef);

            }else{
                //only save fields that changed
                if(propertyValue != [self valueForKey:fieldName]){
                    contactDidChange = YES;
                    CFErrorRef error = NULL;
                    ABMutableMultiValueRef multiRef = NULL;
                    
                    if([fieldName isEqualToString:CTLPersonEmailProperty]){
                        multiRef = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                        ABMultiValueAddValueAndLabel(multiRef, (__bridge CFStringRef)(propertyValue), emailPropertyLabel, NULL);
                    }
                    
                    if([fieldName isEqualToString:CTLPersonPhoneProperty]){
                        multiRef = ABMultiValueCreateMutable(kABMultiStringPropertyType);
                        ABMultiValueAddValueAndLabel(multiRef, (__bridge CFStringRef)(propertyValue), phonePropertyLabel, NULL);
                    }

                    if(multiRef){
                        if(!ABRecordSetValue(self.recordRef, propertyKey, multiRef, &error)){
                            //[self alertErrorMessage:error];
                            NSLog(@"Couldn't save multi");
                        }
                        CFRelease(multiRef);
                    }else{
                        CFErrorRef setValError = NULL;
                        if(!ABRecordSetValue(self.recordRef, propertyKey, (__bridge CFStringRef)propertyValue, &setValError)){
                            //[self alertErrorMessage:setValError];
                            NSLog(@"Couldn't save non-multi");
                        }
                    }
                }
            }
        }
    }];
    
    return contactDidChange;
}

+ (BOOL)validateContactInfo:(NSDictionary *)fieldsDict
{
    int validityScore = 0;
    BOOL isValid = YES;
    
    if(([fieldsDict objectForKey:CTLPersonFirstNameProperty] && [[fieldsDict objectForKey:CTLPersonFirstNameProperty] length] > 0) ||
       ([fieldsDict objectForKey:CTLPersonLastNameProperty] && [[fieldsDict objectForKey:CTLPersonLastNameProperty] length] > 0)){
        validityScore++;
    }
    
    if([fieldsDict objectForKey:CTLPersonEmailProperty] && [[fieldsDict objectForKey:CTLPersonEmailProperty] length] > 0){
        validityScore++;
    }
    
    if([fieldsDict objectForKey:CTLPersonPhoneProperty] && [[fieldsDict objectForKey:CTLPersonPhoneProperty] length] > 0){
        validityScore++;
    }
    
    if(validityScore == 0){
        isValid = NO;
    }
    
    if(validityScore < 2){
        isValid = NO;
    }
    
    return isValid;
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

@end
