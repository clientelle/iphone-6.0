//
//  CTLABGroupTest.h
//  Clientelle
//
//  Created by Kevin Liu on 1/23/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
@class CTLAddressBook;

@interface CTLABGroupTest : SenTestCase{
    CTLAddressBook *_addressBook;
    NSString *_testGroupName;
    NSString *_renamedGroupName;
    ABRecordRef _groupRef;
}

@end
