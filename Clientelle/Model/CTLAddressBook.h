//
//  CTLAddressBook.h
//  Clientelle
//
//  Created by Kevin Liu on 1/23/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CTLVoidBlock)(void);
typedef void (^CTLABRefBlock)(ABAddressBookRef addressBookRef);
typedef void (^CTLDictionayBlock)(NSDictionary* results);

extern NSString *const CTLAddressBookChanged;

@interface CTLAddressBook : NSObject{
    ABAddressBookRef _addressBookRef;
}

@property(nonatomic, assign)ABAddressBookRef addressBookRef;

- (id)initWithAddressBookRef:(ABAddressBookRef)addressBookRef;

+ (void)performWithBlock:(CTLABRefBlock)block withErrorBlock:(CTLVoidBlock)errorBlock;

// Source
- (ABRecordRef)sourceByType:(ABSourceType)sourceType;

// People
+ (void)peopleFromAddressBookWithDictionaryBlock:(CTLDictionayBlock)block;


@end
