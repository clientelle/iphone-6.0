//
//  CTLInitializer.m
//  Clientelle
//
//  Created by Kevin Liu on 9/26/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "CTLInitializer.h"
#import "CTLAddressBook.h"
#import "CTLABGroup.h"
#import "CTLCDFormSchema.h"


NSString *const kCTLInitializerRunOnce = @"initializerRunOnce";

@implementation CTLInitializer

+ (void)runOnce {
    if(![[NSUserDefaults standardUserDefaults] boolForKey:kCTLInitializerRunOnce]){
        [self createDefaultGroups];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCTLInitializerRunOnce];
    }
}

+ (void)createDefaultGroups{
    
    CTLAddressBook *addressBook = [[CTLAddressBook alloc] init];
     
    __block ABRecordID clientGroupID = kABRecordInvalidID;
    __block ABRecordID prospectGroupID = kABRecordInvalidID;
    
    [addressBook performBlockAndWait:^{
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
        
        NSArray *abGroups = [addressBook groupsFromSourceType:kABSourceTypeLocal];
        for(NSUInteger i=0;i<[abGroups count];i++){
            CTLCDFormSchema *formSchema = [CTLCDFormSchema MR_createEntity];
            ABRecordRef group = (__bridge ABRecordRef)([abGroups objectAtIndex:i]);
            formSchema.groupID = @(ABRecordGetRecordID(group));
        }
        
        CTLCDFormSchema *clientGroup = [CTLCDFormSchema MR_createEntity];
        clientGroupID = [addressBook createGroup:CTLGroupTypeClient];
        clientGroup.groupID = @(clientGroupID);
        
        CTLCDFormSchema *prospectGroup = [CTLCDFormSchema MR_createEntity];
        prospectGroupID = [addressBook createGroup:CTLGroupTypeProspect];
        prospectGroup.groupID = @(prospectGroupID);
                
        CTLCDFormSchema *associateGroup = [CTLCDFormSchema MR_createEntity];
        associateGroup.groupID = @([addressBook createGroup:CTLGroupTypeAssociate]);
        
        [context MR_save];
        
        //save system groupID's to NSUserDefaults
        [[NSUserDefaults standardUserDefaults] setInteger:clientGroupID forKey:kCTLClientGroupID];
        [[NSUserDefaults standardUserDefaults] setInteger:prospectGroupID forKey:kCTLProspectGroupID];
        [[NSUserDefaults standardUserDefaults] setInteger:clientGroupID forKey:CTLDefaultSelectedGroupIDKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

@end
