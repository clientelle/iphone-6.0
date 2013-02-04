// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDPerson.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDPersonAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *city;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *jobTitle;
	__unsafe_unretained NSString *lastAccessed;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *note;
	__unsafe_unretained NSString *organization;
	__unsafe_unretained NSString *phone;
	__unsafe_unretained NSString *rating;
	__unsafe_unretained NSString *recordID;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *zip;
} CTLCDPersonAttributes;

extern const struct CTLCDPersonRelationships {
} CTLCDPersonRelationships;

extern const struct CTLCDPersonFetchedProperties {
} CTLCDPersonFetchedProperties;

















@interface CTLCDPersonID : NSManagedObjectID {}
@end

@interface _CTLCDPerson : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDPersonID*)objectID;




@property (nonatomic, strong) NSString* address;


//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* city;


//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;




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




@property (nonatomic, strong) NSString* note;


//- (BOOL)validateNote:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* organization;


//- (BOOL)validateOrganization:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* phone;


//- (BOOL)validatePhone:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* rating;


@property int16_t ratingValue;
- (int16_t)ratingValue;
- (void)setRatingValue:(int16_t)value_;

//- (BOOL)validateRating:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* recordID;


@property int16_t recordIDValue;
- (int16_t)recordIDValue;
- (void)setRecordIDValue:(int16_t)value_;

//- (BOOL)validateRecordID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* state;


//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* zip;


//- (BOOL)validateZip:(id*)value_ error:(NSError**)error_;






@end

@interface _CTLCDPerson (CoreDataGeneratedAccessors)

@end

@interface _CTLCDPerson (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;




- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;




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




- (NSString*)primitiveNote;
- (void)setPrimitiveNote:(NSString*)value;




- (NSString*)primitiveOrganization;
- (void)setPrimitiveOrganization:(NSString*)value;




- (NSString*)primitivePhone;
- (void)setPrimitivePhone:(NSString*)value;




- (NSNumber*)primitiveRating;
- (void)setPrimitiveRating:(NSNumber*)value;

- (int16_t)primitiveRatingValue;
- (void)setPrimitiveRatingValue:(int16_t)value_;




- (NSNumber*)primitiveRecordID;
- (void)setPrimitiveRecordID:(NSNumber*)value;

- (int16_t)primitiveRecordIDValue;
- (void)setPrimitiveRecordIDValue:(int16_t)value_;




- (NSString*)primitiveState;
- (void)setPrimitiveState:(NSString*)value;




- (NSString*)primitiveZip;
- (void)setPrimitiveZip:(NSString*)value;




@end
