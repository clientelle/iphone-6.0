//
//  CTLAddressBook.m
//  Clientelle
//
//  Created by Kevin Liu on 1/23/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAddressBook.h"
#import "CTLABGroup.h"
#import "CTLABPerson.h"

NSString *const CTLAddressBookChanged = @"CTLAddressBookChanged";

@implementation CTLAddressBook

- (id)init
{
    self = [super init];
    if(self){
        CFErrorRef error;
        self.addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
        ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef requestError){
            if(granted){
                
            }
        });
    }
    
    return self;
}

- (id)initWithAddressBookRef:(ABAddressBookRef)addressBookRef
{
    self = [super init];
    
    if(self){
        self.addressBookRef = addressBookRef;
    }
    
    return self;
}

+ (void)performWithBlock:(CTLABRefBlock)block withErrorBlock:(CTLVoidBlock)errorBlock
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    CFErrorRef error;
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef reqError) {
        if(granted){
            dispatch_sync(dispatch_get_main_queue(), ^{
                block(addressBookRef);
                dispatch_semaphore_signal(semaphore);
            });
        }else{
            errorBlock();
            dispatch_semaphore_signal(semaphore);
        }
    });
    while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}


#pragma mark - Source Methods

- (ABRecordRef)sourceByType:(ABSourceType)sourceType
{
    CFArrayRef sourcesRef = ABAddressBookCopyArrayOfAllSources(self.addressBookRef);
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

- (NSString *)nameForSource:(ABRecordRef)source
{
	CFNumberRef sourceType = ABRecordCopyValue(source, kABSourceTypeProperty);
	NSString *sourceName = [self nameForSourceWithIdentifier:[(__bridge NSNumber*)sourceType intValue]];
	CFRelease(sourceType);
	return sourceName;
}

- (NSString *)nameForSourceWithIdentifier:(ABSourceType)identifier
{
	switch (identifier){
		case kABSourceTypeLocal:
			return @"On My Device";
			break;
		case kABSourceTypeExchange:
			return @"Exchange server";
			break;
		case kABSourceTypeExchangeGAL:
			return @"Exchange Global Address List";
			break;
		case kABSourceTypeMobileMe:
			return @"MobileMe";
			break;
		case kABSourceTypeLDAP:
			return @"LDAP server";
			break;
		case kABSourceTypeCardDAV:
			return @"CardDAV server";
			break;
		case kABSourceTypeCardDAVSearch:
			return @"Searchable CardDAV server";
			break;
		default:
			break;
	}
	return nil;
}



#pragma mark - People Methods

- (void)peopleFromAddressBookWithDictionaryBlock:(CTLDictionayBlock)block
{
    ABRecordRef localSource = [self sourceByType:kABSourceTypeLocal];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSource(self.addressBookRef, localSource);
    
    if(!allPeople){
        return;
    }
    
    CFIndex count = CFArrayGetCount(allPeople);
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    for(CFIndex i = 0;i < count; i++){
        ABRecordRef contactRef = CFArrayGetValueAtIndex(allPeople, i);
        CTLABPerson *abPerson = [[CTLABPerson alloc] initWithRecordRef:contactRef withAddressBookRef:self.addressBookRef];
        if(abPerson){
            [results setObject:abPerson forKey:@(abPerson.recordID)];
        }
    }
    
    block(results);
    CFRelease(allPeople);
    
}


@end
