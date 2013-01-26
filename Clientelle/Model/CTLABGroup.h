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
    NSMutableDictionary *_members;
}

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, assign) ABRecordRef groupRef;
@property (nonatomic, assign) ABRecordID groupID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableDictionary *members;

- (id)initWithGroupID:(ABRecordID)groupID addressBook:(ABAddressBookRef)addressBookRef;
- (id)initWithGroupRef:(ABRecordRef)groupRef addressBook:(ABAddressBookRef)addressBookRef;

//- (NSMutableDictionary *)members;

- (void)addMember:(ABRecordID)personID;
- (void)addMembers:(NSMutableDictionary *)contacts;
- (void)removeMember:(ABRecordID)personID;
- (void)removeMembers;
- (BOOL)renameTo:(NSString *)newName;
- (BOOL)deleteGroup:(ABRecordRef)groupRef;

+ (ABRecordRef)findByName:(NSString *)groupName addressBookRef:(ABAddressBookRef)addressBookRef;
+ (NSMutableArray *)groupsInLocalSource:(ABAddressBookRef)addressBookRef;
+ (void)createDefaultGroups:(ABAddressBookRef)addressBookRef;
+ (ABRecordID)createGroup:(NSString *)groupName addressBookRef:(ABAddressBookRef)addressBookRef;
+ (NSArray *)groupsFromSourceType:(ABSourceType)sourceType addressBookRef:(ABAddressBookRef)addressBookRef;

+ (void)saveDefaultGroupID:(int)groupID;
+ (ABRecordID)defaultGroupID;
+ (ABRecordID)prospectGroupID;
+ (ABRecordID)clientGroupID;

- (NSString *)description;

@end
