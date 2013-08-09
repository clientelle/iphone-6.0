//
//  CTLAddressBook.h
//  Clientelle
//
//  Created by Kevin Liu on 8/5/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CTLPermissionCompletionBlock)(BOOL hasPermission, ABAddressBookRef addressBookRef);
typedef void (^CTLImportCompleteBlock)(NSDictionary *results);
typedef void (^CTLImportErrorBlock)(NSError *error);

@interface CTLAddressBook : NSObject

+ (id)sharedInstance;

- (void)loadContactsWithCompletionBlock:(CTLImportCompleteBlock)completeBlock;
- (ABRecordRef)sourceByType:(ABSourceType)sourceType addessBookRef:(ABAddressBookRef)addressBookRef;
- (BOOL)deletePerson:(ABRecordRef)recordRef withAddressBook:(ABAddressBookRef)addressBookRef;

- (void)alertPermissionRequirement;

@end
