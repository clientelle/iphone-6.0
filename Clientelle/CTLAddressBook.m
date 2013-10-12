//
//  CTLAddressBook.m
//  Clientelle
//
//  Created by Kevin Liu on 8/5/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAddressBook.h"
#import "CTLABPerson.h"

@interface CTLAddressBook()

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@end


@implementation CTLAddressBook

- (id)initWithAddressBookRef:(ABAddressBookRef)addresBookRef
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.addressBookRef = addresBookRef;    
    return self;
}

+ (id)sharedInstance
{
    static CTLAddressBook *shared = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            shared = [[self alloc] initWithAddressBookRef:addressBookRef];
        }else{
            shared = [[self alloc] init];
        }
    });
    
    return shared;
}

- (void)checkForPermissionWithCompletionBlock:(CTLPermissionCompletionBlock)completionBlock
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            // First time access has been granted
            self.addressBookRef = addressBookRef;
            completionBlock(granted, addressBookRef);
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access.        
        completionBlock(YES, addressBookRef);
    } else {
        // The user has previously denied access
        completionBlock(NO, addressBookRef);
    }
}

- (void)loadContactsWithCompletionBlock:(CTLImportCompleteBlock)completeBlock
{
    [self checkForPermissionWithCompletionBlock:^(BOOL granted, ABAddressBookRef addressBookRef){        
        
        if(granted){
        
            ABRecordRef localSource = [self sourceByType:kABSourceTypeLocal addessBookRef:addressBookRef];
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
            
            completeBlock(results);
            CFRelease(allPeople);
        }else{
            [self alertPermissionRequirement];
        }
    }];
}

- (ABRecordRef)sourceByType:(ABSourceType)sourceType addessBookRef:(ABAddressBookRef)addressBookRef
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

- (BOOL)deletePerson:(ABRecordRef)recordRef withAddressBook:(ABAddressBookRef)addressBookRef
{
    __block BOOL result = NO;
    CFErrorRef error = NULL;
    if(ABAddressBookRemoveRecord(addressBookRef, recordRef, &error)){
        result = ABAddressBookSave(addressBookRef, &error);
    }    
    return result;
}

- (void)alertPermissionRequirement
{
    UIAlertView *requirePermission = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"REQUIRES_ACCESS_TO_CONTACTS", nil)
                                                                message:NSLocalizedString(@"GO_TO_SETTINGS_CONTACTS", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
    [requirePermission show];
}


@end
