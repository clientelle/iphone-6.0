//
//  CTLAddressBook.m
//  Clientelle
//
//  Created by Kevin Liu on 1/23/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLABGroup.h"
#import "CTLAddressBook.h"

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

- (NSMutableArray *)groupsInLocalSource
{
    NSMutableArray *groups = [NSMutableArray array];
    NSArray *groupsArray = [self groupsFromSourceType:kABSourceTypeLocal];
    for(NSInteger i=0;i<[groupsArray count];i++){
        ABRecordRef groupRef = (__bridge ABRecordRef)([groupsArray objectAtIndex:i]);
        CTLABGroup *group = [[CTLABGroup alloc] initWithGroupRef:groupRef addressBook:self.addressBookRef];
        [groups addObject:group];
    }
    
    return groups;
}


- (NSArray *)groupsFromSourceType:(ABSourceType)sourceType
{
    NSMutableArray *groupsInSource = [NSMutableArray array];
    ABRecordRef sourceRef = NULL;
    CFArrayRef sourcesRef = ABAddressBookCopyArrayOfAllSources(self.addressBookRef);
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
    
    CFArrayRef groupsRef = ABAddressBookCopyArrayOfAllGroupsInSource (self.addressBookRef, sourceRef);
    if (CFArrayGetCount(groupsRef) > 0){
        groupsInSource = [[NSMutableArray alloc] initWithArray:(__bridge NSArray *)groupsRef];
    }
    
    CFRelease(groupsRef);
    CFRelease(sourcesRef);
    return groupsInSource;
}

- (ABRecordRef)findGroupByName:(NSString *)groupName
{
    ABRecordRef existingGroupRef = NULL;
    NSArray *groupsInSource = [self groupsFromSourceType:kABSourceTypeLocal];
    for(int i=0;i<[groupsInSource count];i++){
        existingGroupRef = (__bridge ABRecordRef)([groupsInSource objectAtIndex:i]);
        CFTypeRef groupNameRef = ABRecordCopyValue(existingGroupRef, kABGroupNameProperty);
        NSString *groupNameStr = (__bridge NSString *)(groupNameRef);
        if([groupName isEqualToString:groupNameStr]){
            //Group already exists
            CFRelease(groupNameRef);
            break;
        }
        existingGroupRef = NULL;
        CFRelease(groupNameRef);
    }
    
    return existingGroupRef;
}

- (ABRecordID)createGroup:(NSString *)groupName
{
    ABRecordRef newGroupRef = ABGroupCreate();
    
    CFErrorRef error = NULL;
    ABRecordSetValue(newGroupRef, kABGroupNameProperty, (__bridge CFTypeRef)(groupName), &error);
    
    if(ABAddressBookAddRecord(self.addressBookRef, newGroupRef, &error)){
        if(!ABAddressBookSave(self.addressBookRef, &error)){
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

- (BOOL)deleteGroup:(ABRecordRef)groupRef
{
    __block BOOL result = NO;
    CFErrorRef error = NULL;
    if(ABAddressBookRemoveRecord(self.addressBookRef, groupRef, &error)){
        result = ABAddressBookSave(self.addressBookRef, &error);
    }
    
    return result;
}

@end
