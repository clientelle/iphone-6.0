// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDContact.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDContactAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *address2;
	__unsafe_unretained NSString *contactID;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *jobTitle;
	__unsafe_unretained NSString *lastAccessed;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *mobile;
	__unsafe_unretained NSString *nickName;
	__unsafe_unretained NSString *note;
	__unsafe_unretained NSString *organization;
	__unsafe_unretained NSString *phone;
	__unsafe_unretained NSString *picture;
	__unsafe_unretained NSString *preferredConactType;
	__unsafe_unretained NSString *recordID;
} CTLCDContactAttributes;

extern const struct CTLCDContactRelationships {
	__unsafe_unretained NSString *appointment;
} CTLCDContactRelationships;

extern const struct CTLCDContactFetchedProperties {
} CTLCDContactFetchedProperties;

@class CTLCDAppointment;


















@interface CTLCDContactID : NSManagedObjectID {}
@end

@interface _CTLCDContact : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDContactID*)objectID;





@property (nonatomic, strong) NSString* address;



//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* address2;



//- (BOOL)validateAddress2:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* contactID;



@property int16_t contactIDValue;
- (int16_t)contactIDValue;
- (void)setContactIDValue:(int16_t)value_;

//- (BOOL)validateContactID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* firstName;



//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* jobTitle;



//- (BOOL)validateJobTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* lastAccessed;



//- (BOOL)validateLastAccessed:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastName;



//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* mobile;



//- (BOOL)validateMobile:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* nickName;



//- (BOOL)validateNickName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* note;



//- (BOOL)validateNote:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* organization;



//- (BOOL)validateOrganization:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* phone;



//- (BOOL)validatePhone:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSData* picture;



//- (BOOL)validatePicture:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* preferredConactType;



@property int16_t preferredConactTypeValue;
- (int16_t)preferredConactTypeValue;
- (void)setPreferredConactTypeValue:(int16_t)value_;

//- (BOOL)validatePreferredConactType:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* recordID;



@property int16_t recordIDValue;
- (int16_t)recordIDValue;
- (void)setRecordIDValue:(int16_t)value_;

//- (BOOL)validateRecordID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *appointment;

- (NSMutableSet*)appointmentSet;





@end

@interface _CTLCDContact (CoreDataGeneratedAccessors)

- (void)addAppointment:(NSSet*)value_;
- (void)removeAppointment:(NSSet*)value_;
- (void)addAppointmentObject:(CTLCDAppointment*)value_;
- (void)removeAppointmentObject:(CTLCDAppointment*)value_;

@end

@interface _CTLCDContact (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;




- (NSString*)primitiveAddress2;
- (void)setPrimitiveAddress2:(NSString*)value;




- (NSNumber*)primitiveContactID;
- (void)setPrimitiveContactID:(NSNumber*)value;

- (int16_t)primitiveContactIDValue;
- (void)setPrimitiveContactIDValue:(int16_t)value_;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;




- (NSString*)primitiveJobTitle;
- (void)setPrimitiveJobTitle:(NSString*)value;




- (NSDate*)primitiveLastAccessed;
- (void)setPrimitiveLastAccessed:(NSDate*)value;




- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;




- (NSString*)primitiveMobile;
- (void)setPrimitiveMobile:(NSString*)value;




- (NSString*)primitiveNickName;
- (void)setPrimitiveNickName:(NSString*)value;




- (NSString*)primitiveNote;
- (void)setPrimitiveNote:(NSString*)value;




- (NSString*)primitiveOrganization;
- (void)setPrimitiveOrganization:(NSString*)value;




- (NSString*)primitivePhone;
- (void)setPrimitivePhone:(NSString*)value;




- (NSData*)primitivePicture;
- (void)setPrimitivePicture:(NSData*)value;




- (NSNumber*)primitivePreferredConactType;
- (void)setPrimitivePreferredConactType:(NSNumber*)value;

- (int16_t)primitivePreferredConactTypeValue;
- (void)setPrimitivePreferredConactTypeValue:(int16_t)value_;




- (NSNumber*)primitiveRecordID;
- (void)setPrimitiveRecordID:(NSNumber*)value;

- (int16_t)primitiveRecordIDValue;
- (void)setPrimitiveRecordIDValue:(int16_t)value_;





- (NSMutableSet*)primitiveAppointment;
- (void)setPrimitiveAppointment:(NSMutableSet*)value;


@end
