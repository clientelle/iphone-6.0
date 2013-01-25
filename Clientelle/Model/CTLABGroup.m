//
//  CTLABGroup.m
//  Clientelle
//
//  Created by Kevin Liu on 1/23/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAddressBook.h"
#import "CTLABGroup.h"
#import "CTLABPerson.h"
#import "CTLCDFormSchema.h"

NSString *const CTLGroupTypeClient = @"Clients";
NSString *const CTLGroupTypeProspect = @"Prospects";
NSString *const CTLGroupTypeAssociate = @"Associates";

NSString *const kCTLClientGroupID = @"ClientGroupID";
NSString *const kCTLProspectGroupID = @"ProspectGroupID";

NSString *const CTLDefaultSelectedGroupIDKey = @"defaultGroupKey";


@implementation CTLABGroup


- (id)initWithGroupID:(ABRecordID)groupID addressBook:(ABAddressBookRef)addressBookRef includeMembers:(BOOL)incudeMembers
{
    self = [super init];
    if(self != nil){
        self.addressBookRef = addressBookRef;
        ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(addressBookRef, groupID);
        if(groupRef){
            self.groupRef = groupRef;
            self.groupID = groupID;
            self.name = (__bridge NSString *)ABRecordCopyCompositeName(self.groupRef);
            if(!incudeMembers){
                self.members = [NSMutableArray array];
                self.memberCount = [self countMembers];
            }else{
                self.members = [self contactsInGroup];
                self.memberCount = [self.members count];
            }
        }
    }
    return self;
}

- (id)initWithGroupRef:(ABRecordRef)groupRef addressBook:(ABAddressBookRef)addressBookRef
{
    self = [super init];
    if(self != nil){
        self.addressBookRef = addressBookRef;
        self.groupRef = groupRef;
        self.groupID = ABRecordGetRecordID(groupRef);
        self.name = (__bridge NSString *)ABRecordCopyCompositeName(groupRef);
        self.members = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray *)contactsInGroup
{
    CFArrayRef contactsRef = ABGroupCopyArrayOfAllMembers(self.groupRef);
    if(contactsRef){
        CFIndex count = CFArrayGetCount(contactsRef);
        _members = [NSMutableArray arrayWithCapacity:count];
        for(CFIndex i = 0;i < count; i++){
            ABRecordRef personRef = CFArrayGetValueAtIndex(contactsRef, i);
            CTLABPerson *abPerson = [[CTLABPerson alloc] initWithRecordRef:personRef withAddressBookRef:self.addressBookRef];
            if(abPerson){
                [_members addObject:abPerson];
            }
        }
        CFRelease(contactsRef);
    }
    
    return _members;
}

- (CFIndex)countMembers
{
    CFIndex count = 0;
    CFArrayRef contactsRef = ABGroupCopyArrayOfAllMembers(self.groupRef);
    if(contactsRef){
        count = CFArrayGetCount(contactsRef);
        CFRelease(contactsRef);
    }
    return count;
}

- (void)removeMembers
{
    CFArrayRef contactsRef = ABGroupCopyArrayOfAllMembers(self.groupRef);
    BOOL result = NO;
    
    if(!contactsRef){
        return;
    }
    
    CFIndex count = CFArrayGetCount(contactsRef);
    CFErrorRef error = NULL;
    
    for(CFIndex i = 0;i < count; i++){
        ABRecordRef contactRef = CFArrayGetValueAtIndex(contactsRef, i);
        if(ABGroupRemoveMember(self.groupRef, contactRef, &error)){
            result = ABAddressBookSave(self.addressBookRef, &error);
        }
    }
    
    CFRelease(contactsRef);
}

- (BOOL)renameTo:(NSString *)newName
{
 	if ([newName length] == 0){
        return NO;
    }
    
    CFErrorRef error;
    ABRecordSetValue(self.groupRef, kABGroupNameProperty, (__bridge CFTypeRef)(newName), &error);
    return ABAddressBookSave(self.addressBookRef, &error);
}

- (void)addMember:(ABRecordID)personID
{
    ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personID);
    ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(self.addressBookRef, self.groupID);
    
    CFErrorRef error = NULL;
    if(ABGroupAddMember(groupRef, personRef, &error)){
        if(!ABAddressBookSave(self.addressBookRef, &error)){
            //[self alertErrorMessage:error];
        }
    } else {
        //[self alertErrorMessage:error];
    }
}

- (void)removeMember:(ABRecordID)personID
{
    ABRecordRef contactRef = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personID);
    
    CFErrorRef error = NULL;
    if(ABGroupRemoveMember(self.groupRef, contactRef, &error)){
        if(!ABAddressBookSave(self.addressBookRef, &error)){
            //[self alertErrorMessage:error];
        }
    }else{
        //[self alertErrorMessage:error];
    }
}


- (void)addMembers:(NSMutableDictionary *)contacts
{
    ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(self.addressBookRef, self.groupID);
    [contacts enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        CTLABPerson *person = obj;
        ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(self.addressBookRef, person.recordID);
        
        CFErrorRef error = NULL;
        if(ABGroupAddMember(groupRef, personRef, &error)){
            if(!ABAddressBookSave(self.addressBookRef, &error)){
                //[self alertErrorMessage:error];
            }
        }else{
            //[self alertErrorMessageWithString:(__bridge NSString *)(CFErrorCopyDescription(error))];
        }
    }];
}


#pragma mark - Class Methods

+ (ABRecordID)defaultGroupID
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:CTLDefaultSelectedGroupIDKey];
}

+ (ABRecordID)prospectGroupID
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kCTLProspectGroupID];
}

+ (ABRecordID)clientGroupID
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kCTLClientGroupID];
}

- (NSString *)description{
    return [NSString stringWithFormat:@"<%@: %@, groupID:%i>", [self class], [self name], [self groupID]];
}

+ (void)createDefaultGroups:(ABAddressBookRef)addressBookRef
{
    CTLAddressBook *addressBook = [[CTLAddressBook alloc] initWithAddressBookRef:addressBookRef];
    NSArray *abGroups = [addressBook groupsFromSourceType:kABSourceTypeLocal];
    
    ABRecordID clientsGroupID = kABRecordInvalidID;
    ABRecordID prospectsGroupID = kABRecordInvalidID;
    ABRecordID associatesGroupID = kABRecordInvalidID;
    
    //create form schemas for existing groups
    for(NSUInteger i=0;i<[abGroups count];i++){
        
        ABRecordRef groupRef = (__bridge ABRecordRef)([abGroups objectAtIndex:i]);
        ABRecordID groupID = ABRecordGetRecordID(groupRef);
        NSString *groupName = (__bridge NSString *)ABRecordCopyCompositeName(groupRef);
        
        if([groupName isEqualToString:CTLGroupTypeClient]){
            clientsGroupID = groupID;
        }
        
        if([groupName isEqualToString:CTLGroupTypeProspect]){
            prospectsGroupID = groupID;
        }
        
        if([groupName isEqualToString:CTLGroupTypeAssociate]){
            associatesGroupID = groupID;
        }
        
        CTLCDFormSchema *formSchema = [CTLCDFormSchema MR_createEntity];
        formSchema.groupIDValue = groupID;
    }
    
    if(clientsGroupID == kABRecordInvalidID){
        CTLCDFormSchema *clientGroup = [CTLCDFormSchema MR_createEntity];
        clientsGroupID = [addressBook createGroup:CTLGroupTypeClient];
        clientGroup.groupIDValue = clientsGroupID;
    }
    
    if(prospectsGroupID == kABRecordInvalidID){
        CTLCDFormSchema *prospectGroup = [CTLCDFormSchema MR_createEntity];
        prospectsGroupID = [addressBook createGroup:CTLGroupTypeProspect];
        prospectGroup.groupIDValue = prospectsGroupID;
    }
    
    if(associatesGroupID == kABRecordInvalidID){
        CTLCDFormSchema *associatesGroup = [CTLCDFormSchema MR_createEntity];
        associatesGroupID = [addressBook createGroup:CTLGroupTypeAssociate];
        associatesGroup.groupIDValue = associatesGroupID;
    }
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error){
        [[NSUserDefaults standardUserDefaults] setInteger:clientsGroupID forKey:kCTLClientGroupID];
        [[NSUserDefaults standardUserDefaults] setInteger:prospectsGroupID forKey:kCTLProspectGroupID];
        [[NSUserDefaults standardUserDefaults] setInteger:clientsGroupID forKey:CTLDefaultSelectedGroupIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

@end

