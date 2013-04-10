//
//  CTLABGroup.m
//  Clientelle
//
//  Created by Kevin Liu on 1/23/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLABGroup.h"
#import "CTLABPerson.h"
#import "CTLCDFormSchema.h"
#import "CTLCDPerson.h"

NSString *const CTLGroupTypeClient = @"CLIENTS";
NSString *const CTLGroupTypeProspect = @"PROSPECTS";
NSString *const CTLGroupTypeAssociate = @"ASSOCIATES";
NSString *const kCTLClientGroupID = @"ClientGroupID";
NSString *const kCTLProspectGroupID = @"ProspectGroupID";
NSString *const CTLDefaultSelectedGroupIDKey = @"defaultGroupKey";

@implementation CTLABGroup

- (id)initWithGroupID:(ABRecordID)groupID addressBook:(ABAddressBookRef)addressBookRef
{
    self = [super init];
    if(self != nil){
        self.addressBookRef = addressBookRef;
        ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(addressBookRef, groupID);
        if(groupRef){
            self.groupRef = groupRef;
            self.groupID = groupID;
            self.name = (__bridge NSString *)ABRecordCopyCompositeName(self.groupRef);
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
    }
    return self;
}

- (NSMutableDictionary *)members
{
    _members = [NSMutableDictionary dictionary];
    CFArrayRef contactsRef = ABGroupCopyArrayOfAllMembers(self.groupRef);
    if(contactsRef){
        CFIndex count = CFArrayGetCount(contactsRef);
        _members = [NSMutableDictionary dictionaryWithCapacity:count];
        for(CFIndex i = 0;i < count; i++){
            CTLABPerson *abPerson = [[CTLABPerson alloc] initWithRecordRef:CFArrayGetValueAtIndex(contactsRef, i) withAddressBookRef:self.addressBookRef];
            [_members setObject:abPerson forKey:@(abPerson.recordID)];
        }
        CFRelease(contactsRef);
    }

    return _members;
}

- (void)addMember:(CTLABPerson *)person
{
    ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(self.addressBookRef, person.recordID);
    ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(self.addressBookRef, self.groupID);
    
    CFErrorRef error = NULL;
    if(ABGroupAddMember(groupRef, personRef, &error)){
        if(ABAddressBookSave(self.addressBookRef, &error)){
            //successful
        }
    } else {
        //[self alertErrorMessage:error];
    }
}

- (void)addMembers:(NSMutableDictionary *)contacts
{
    if([contacts count] == 0){
        return;
    }
    
    ABRecordRef groupRef = ABAddressBookGetGroupWithRecordID(self.addressBookRef, self.groupID);
    
    for(NSNumber *recordID in contacts){
        CTLABPerson *person = [contacts objectForKey:recordID];
        ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(self.addressBookRef, person.recordID);
        
        CFErrorRef error = NULL;
        if(ABGroupAddMember(groupRef, personRef, &error)){
            if(ABAddressBookSave(self.addressBookRef, &error)){
                [CTLCDPerson createFromABPerson:person];
            }
        }
    }

    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
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

- (BOOL)deleteGroup:(ABRecordRef)groupRef
{
    __block BOOL result = NO;
    CFErrorRef error = NULL;
    if(ABAddressBookRemoveRecord(self.addressBookRef, groupRef, &error)){
        result = ABAddressBookSave(self.addressBookRef, &error);
    }
    
    return result;
}

#pragma mark - Class Methods
+ (void)createDefaultGroups:(ABAddressBookRef)addressBookRef completion:(CTLSaveCompletionHandler)completion
{
    ABRecordID clientsGroupID = kABRecordInvalidID;
    ABRecordID prospectsGroupID = kABRecordInvalidID;
    ABRecordID associatesGroupID = kABRecordInvalidID;
    
    NSString *clientsGroupName = NSLocalizedString(CTLGroupTypeClient, nil);
    NSString *associatesGroupName = NSLocalizedString(CTLGroupTypeAssociate, nil);
    NSString *prospectsGroupName = NSLocalizedString(CTLGroupTypeProspect, nil);
    
    NSArray *abGroups = [CTLABGroup groupsFromSourceType:kABSourceTypeLocal addressBookRef:addressBookRef];

    //create form schemas for existing groups
    for(NSUInteger i=0;i<[abGroups count];i++){
        
        ABRecordRef groupRef = (__bridge ABRecordRef)([abGroups objectAtIndex:i]);
        NSString *groupName = (__bridge NSString *)ABRecordCopyCompositeName(groupRef);
        ABRecordID groupID = ABRecordGetRecordID(groupRef);
        
        if([groupName isEqualToString:clientsGroupName]){
            clientsGroupID = groupID;
        }
        
        if([groupName isEqualToString:prospectsGroupName]){
            prospectsGroupID = groupID;
        }
        
        if([groupName isEqualToString:associatesGroupName]){
            associatesGroupID = groupID;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"groupID=%i", groupID];
        CTLCDFormSchema *formSchema = [CTLCDFormSchema MR_findFirstWithPredicate:predicate];
        if(!formSchema){
            formSchema = [CTLCDFormSchema MR_createEntity];
            formSchema.groupIDValue = groupID;
        }
    }
    
    if(clientsGroupID == kABRecordInvalidID){
        CTLCDFormSchema *clientGroup = [CTLCDFormSchema MR_createEntity];
        clientsGroupID = [CTLABGroup createGroup:clientsGroupName addressBookRef:addressBookRef];
        clientGroup.groupIDValue = clientsGroupID;
    }
    
    if(prospectsGroupID == kABRecordInvalidID){
        CTLCDFormSchema *prospectGroup = [CTLCDFormSchema MR_createEntity];
        prospectsGroupID = [CTLABGroup createGroup:prospectsGroupName addressBookRef:addressBookRef];
        prospectGroup.groupIDValue = prospectsGroupID;
    }
    
    if(associatesGroupID == kABRecordInvalidID){
        CTLCDFormSchema *associatesGroup = [CTLCDFormSchema MR_createEntity];
        associatesGroupID = [CTLABGroup createGroup:associatesGroupName addressBookRef:addressBookRef];
        associatesGroup.groupIDValue = associatesGroupID;
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    [[NSUserDefaults standardUserDefaults] setInteger:clientsGroupID forKey:kCTLClientGroupID];
    [[NSUserDefaults standardUserDefaults] setInteger:prospectsGroupID forKey:kCTLProspectGroupID];
    [[NSUserDefaults standardUserDefaults] setInteger:clientsGroupID forKey:CTLDefaultSelectedGroupIDKey];
    
    if (completion){
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    }
}

+ (NSMutableArray *)groupsInLocalSource:(ABAddressBookRef)addressBookRef
{
    NSMutableArray *groups = [NSMutableArray array];
    NSArray *groupsArray = [CTLABGroup groupsFromSourceType:kABSourceTypeLocal addressBookRef:addressBookRef];
    for(NSInteger i=0;i<[groupsArray count];i++){
        ABRecordRef groupRef = (__bridge ABRecordRef)([groupsArray objectAtIndex:i]);
        CTLABGroup *group = [[CTLABGroup alloc] initWithGroupRef:groupRef addressBook:addressBookRef];
        [groups addObject:group];
    }
    
    return groups;
}

+ (CTLABGroup *)getAnyGroup:(ABAddressBookRef)addressBookRef
{
    NSArray *groups = [CTLABGroup groupsInLocalSource:addressBookRef];
    if([groups count] == 0){
        //create a group
        NSString *clientsGroupName = NSLocalizedString(CTLGroupTypeClient, nil);
        ABRecordID groupID = [CTLABGroup createGroup:clientsGroupName addressBookRef:addressBookRef];
        return [[CTLABGroup alloc] initWithGroupID:groupID addressBook:addressBookRef];
    }else{
        return [groups objectAtIndex:0];
    }
}

+ (NSArray *)groupsFromSourceType:(ABSourceType)sourceType addressBookRef:(ABAddressBookRef)addressBookRef
{
    NSMutableArray *groupsInSource = [NSMutableArray array];
    ABRecordRef sourceRef = NULL;
    CFArrayRef sourcesRef = ABAddressBookCopyArrayOfAllSources(addressBookRef);
    CFIndex sourceCount = CFArrayGetCount(sourcesRef);
    
    for (CFIndex i = 0; i < sourceCount; i++) {
        ABRecordRef currentSource = CFArrayGetValueAtIndex(sourcesRef, i);
        CFTypeRef sourceTypeRef = ABRecordCopyValue(currentSource, kABSourceTypeProperty);
        BOOL isMatch = (sourceType == [(__bridge NSNumber *)sourceTypeRef intValue]);
        CFRelease(sourceTypeRef);
        if (isMatch) {
            sourceRef = currentSource;
            break;
        }
    }
    
    CFArrayRef groupsRef = ABAddressBookCopyArrayOfAllGroupsInSource (addressBookRef, sourceRef);
    if (CFArrayGetCount(groupsRef) > 0){
        groupsInSource = [[NSMutableArray alloc] initWithArray:(__bridge NSArray *)groupsRef];
    }
    
    CFRelease(groupsRef);
    CFRelease(sourcesRef);
    return groupsInSource;
}

+ (ABRecordRef)findByName:(NSString *)groupName addressBookRef:(ABAddressBookRef)addressBookRef
{
    ABRecordRef existingGroupRef = NULL;
    NSArray *groupsInSource = [CTLABGroup groupsFromSourceType:kABSourceTypeLocal addressBookRef:addressBookRef];
    for(int i=0;i<[groupsInSource count];i++){
        existingGroupRef = (__bridge ABRecordRef)([groupsInSource objectAtIndex:i]);
        CFTypeRef groupNameRef = ABRecordCopyValue(existingGroupRef, kABGroupNameProperty);
        NSString *groupNameStr = (__bridge NSString *)(groupNameRef);
        //Group already exists
        if([groupName isEqualToString:groupNameStr]){
            CFRelease(groupNameRef);
            break;
        }
        existingGroupRef = NULL;
        CFRelease(groupNameRef);
    }
    
    return existingGroupRef;
}

+ (ABRecordID)createGroup:(NSString *)groupName addressBookRef:(ABAddressBookRef)addressBookRef
{
    ABRecordRef newGroupRef = ABGroupCreate();
    
    CFErrorRef error = NULL;
    ABRecordSetValue(newGroupRef, kABGroupNameProperty, (__bridge CFTypeRef)(groupName), &error);
    
    if(ABAddressBookAddRecord(addressBookRef, newGroupRef, &error)){
        if(!ABAddressBookSave(addressBookRef, &error)){
            CFRelease(newGroupRef);
            return kABRecordInvalidID;
        }
    }else{
        CFRelease(newGroupRef);
        return kABRecordInvalidID;
    }
    
    ABRecordID groupID = ABRecordGetRecordID(newGroupRef); 
    CFRelease(newGroupRef);
    return groupID;
}

+ (BOOL)groupDoesExist:(ABRecordID)groupID addressBookRef:(ABAddressBookRef)addressBookRef
{
    return ABAddressBookGetGroupWithRecordID(addressBookRef, groupID);
}

+ (void)saveDefaultGroupID:(int)groupID
{
    [[NSUserDefaults standardUserDefaults] setInteger:groupID forKey:CTLDefaultSelectedGroupIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@, groupID:%i>", [self class], [self name], [self groupID]];
}

@end

