//
//  CTLPersonRecord.h
//  Clientelle
//
//  Created by Kevin Liu on 4/25/12.
//  Copyright (c) 2012 Clientelle Ltd. All rights reserved.
//

typedef void (^CTLDictionayBlock)(NSDictionary* results);

extern NSString *const CTLPersonCompositeNameProperty;
extern NSString *const CTLPersonRecordIDProperty;
extern NSString *const CTLPersonFirstNameProperty;
extern NSString *const CTLPersonLastNameProperty;
extern NSString *const CTLPersonOrganizationProperty;
extern NSString *const CTLPersonJobTitleProperty;
extern NSString *const CTLPersonEmailProperty;
extern NSString *const CTLPersonPhoneProperty;
extern NSString *const CTLPersonNoteProperty;
extern NSString *const CTLPersonCreatedDateProperty;
extern NSString *const CTLPersonAddressProperty;

@interface CTLABPerson : NSObject

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, assign) ABRecordID recordID;
@property (nonatomic, assign) ABRecordRef recordRef;

@property (nonatomic, copy) NSString *compositeName;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *organization;
@property (nonatomic, copy) NSString *jobTitle;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *creationDate;
@property (nonatomic, copy) UIImage *picture;
@property (nonatomic, copy) NSDate *accessDate;
@property (nonatomic, strong) NSDictionary *addressDict;
@property (nonatomic, strong) NSDictionary *keyMap;

@property (nonatomic, copy) NSString *phoneLabel;
@property (nonatomic, copy) NSString *emailLabel;
@property (nonatomic, copy) NSString *addressLabel;

- (id)initWithRecordID:(ABRecordID)recordID withAddressBookRef:(ABAddressBookRef)addressBookRef;
- (id)initWithRecordRef:(ABRecordRef)recordRef withAddressBookRef:(ABAddressBookRef)addressBookRef;
- (id)initWithDictionary:(NSDictionary *)fields withAddressBookRef:(ABAddressBookRef)addressBookRef;

- (CTLABPerson *)updateWithDictionary:(NSDictionary *)fields;
+ (BOOL)validateContactInfo:(NSDictionary *)fieldsDict;

+ (void)peopleFromAddressBook:(ABAddressBookRef)addressBookRef withBlock:(CTLDictionayBlock)block;

+ (ABRecordRef)sourceByType:(ABSourceType)sourceType addessBookRef:(ABAddressBookRef)addressBookRef;

- (NSString *)description;

@end
