//
//  CTLPersonRecord.h
//  Clientelle
//
//  Created by Kevin Liu on 4/25/12.
//  Copyright (c) 2012 Clientelle Ltd. All rights reserved.
//

extern NSString *const CTLPersonRecordIDProperty;
extern NSString *const CTLPersonCompositeNameProperty;
extern NSString *const CTLPersonFirstNameProperty;
extern NSString *const CTLPersonLastNameProperty;
extern NSString *const CTLPersonNickNameProperty;
extern NSString *const CTLPersonOrganizationProperty;
extern NSString *const CTLPersonJobTitleProperty;
extern NSString *const CTLPersonEmailProperty;
extern NSString *const CTLPersonPhoneProperty;
extern NSString *const CTLPersonMobileProperty;
extern NSString *const CTLPersonNoteProperty;
extern NSString *const CTLPersonCreatedDateProperty;
extern NSString *const CTLPersonAddressProperty;
extern NSString *const CTLPersonAddress2Property;
extern NSString *const CTLAddressStreetProperty;
extern NSString *const CTLAddressCityProperty;
extern NSString *const CTLAddressStateProperty;
extern NSString *const CTLAddressZIPProperty;

@interface CTLABPerson : NSObject

@property (nonatomic, assign) ABRecordID recordID;
@property (nonatomic, assign) ABRecordRef recordRef;
@property (nonatomic, copy) NSString *compositeName;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *organization;
@property (nonatomic, copy) NSString *jobTitle;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) UIImage *picture;
@property (nonatomic, strong) NSDictionary *addressDict;

@property (nonatomic, strong) NSDictionary *keyMap;

@property (nonatomic, copy) NSString *emailLabel;
@property (nonatomic, copy) NSString *addressLabel;
@property (nonatomic, assign) ABAddressBookRef addressBookRef;

- (id)initWithRecordID:(ABRecordID)recordID withAddressBookRef:(ABAddressBookRef)addressBookRef;
- (id)initWithRecordRef:(ABRecordRef)recordRef withAddressBookRef:(ABAddressBookRef)addressBookRef;
- (NSString *)description;

@end
