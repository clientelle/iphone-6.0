//
//  CTLAddressBook.h
//  Clientelle
//
//  Created by Kevin Liu on 1/23/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CTLAddressBook : NSObject{
    ABAddressBookRef _addressBookRef;
}

@property(nonatomic, assign)ABAddressBookRef addressBookRef;

- (id)initWithAddressBookRef:(ABAddressBookRef)addressBookRef;

- (NSMutableArray *)groupsInLocalSource;
- (NSArray *)groupsFromSourceType:(ABSourceType)sourceType;
- (ABRecordID)createGroup:(NSString *)groupName;
- (ABRecordRef)findGroupByName:(NSString *)groupName;
@end
