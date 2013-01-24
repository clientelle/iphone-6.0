//
//  CTLABGroup.m
//  Clientelle
//
//  Created by Kevin Liu on 1/23/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAddressBook.h"
#import "CTLABGroup.h"
#import "CTLCDFormSchema.h"

NSString *const CTLGroupTypeClient = @"Clients";
NSString *const CTLGroupTypeProspect = @"Prospects";
NSString *const CTLGroupTypeAssociate = @"Associates";

NSString *const kCTLClientGroupID = @"ClientGroupID";
NSString *const kCTLProspectGroupID = @"ProspectGroupID";

NSString *const CTLDefaultSelectedGroupIDKey = @"defaultGroupKey";


@implementation CTLABGroup

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

