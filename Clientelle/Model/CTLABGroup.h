//
//  CTLABGroup.h
//  Clientelle
//
//  Created by Kevin Liu on 1/23/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kCTLClientGroupID;
extern NSString *const kCTLProspectGroupID;

extern NSString *const CTLGroupTypeClient;
extern NSString *const CTLGroupTypeProspect;
extern NSString *const CTLGroupTypeAssociate;

extern NSString *const CTLDefaultSelectedGroupIDKey;


@interface CTLABGroup : NSObject{
    ABAddressBookRef _addressBookRef;
    ABRecordRef _groupRef;
    ABRecordID _groupID;
    NSString *_name;
    NSMutableArray *_members;
}

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, assign) ABRecordRef groupRef;
@property (nonatomic, assign) ABRecordID groupID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *members;
@property (nonatomic, assign) CFIndex memberCount;

- (id)initWithGroupRef:(ABRecordRef)groupRef addressBook:(ABAddressBookRef)addressBookRef;


+ (void)createDefaultGroups:(ABAddressBookRef)addressBookRef;

@end
