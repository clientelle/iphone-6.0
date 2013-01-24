//
//  CTLABGroupTest.m
//  Clientelle
//
//  Created by Kevin Liu on 1/23/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLAddressBook.h"
#import "CTLABGroup.h"
#import "CTLABGroupTest.h"

@implementation CTLABGroupTest

- (void)setUp
{
    [super setUp];

    _addressBook = [[CTLAddressBook alloc] init];
    _testGroupName = @"Random Group";
    _renamedGroupName = @"Renamed Group";
}

- (void)tearDown
{
    _addressBook = nil;
    _testGroupName = nil;
    
    [super tearDown];
}

- (void)testCreateDefaultGroups
{

}

/*

- (void)testCreateGroup
{
    ABRecordID newGroupID = [_addressBook createGroup:_testGroupName];
    if(!newGroupID || newGroupID == kABRecordInvalidID){
        STFail(@"Could not create Group");
    }
}

- (void)testFindGroupByName
{
    ABRecordRef groupRef = [_addressBook findGroupByName:_testGroupName];
    if(!groupRef){
        STFail(@"Could not find Group");
    }
}

- (void)testRenameGroup
{
    ABRecordRef groupRef = [_addressBook findGroupByName:_testGroupName];
    if(!groupRef){
        STFail(@"Could not find Group to rename");
    }
    
    
}
 
 */

@end
