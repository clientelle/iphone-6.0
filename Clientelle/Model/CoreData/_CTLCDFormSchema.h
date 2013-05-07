// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDFormSchema.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDFormSchemaAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *address2;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *jobTitle;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *nickName;
	__unsafe_unretained NSString *note;
	__unsafe_unretained NSString *organization;
	__unsafe_unretained NSString *phone;
} CTLCDFormSchemaAttributes;

extern const struct CTLCDFormSchemaRelationships {
} CTLCDFormSchemaRelationships;

extern const struct CTLCDFormSchemaFetchedProperties {
} CTLCDFormSchemaFetchedProperties;













@interface CTLCDFormSchemaID : NSManagedObjectID {}
@end

@interface _CTLCDFormSchema : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDFormSchemaID*)objectID;




@property (nonatomic, strong) NSNumber* address;


@property BOOL addressValue;
- (BOOL)addressValue;
- (void)setAddressValue:(BOOL)value_;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* address2;


@property BOOL address2Value;
- (BOOL)address2Value;
- (void)setAddress2Value:(BOOL)value_;

//- (BOOL)validateAddress2:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* email;


@property BOOL emailValue;
- (BOOL)emailValue;
- (void)setEmailValue:(BOOL)value_;

//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* firstName;


@property BOOL firstNameValue;
- (BOOL)firstNameValue;
- (void)setFirstNameValue:(BOOL)value_;

//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* jobTitle;


@property BOOL jobTitleValue;
- (BOOL)jobTitleValue;
- (void)setJobTitleValue:(BOOL)value_;

//- (BOOL)validateJobTitle:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* lastName;


@property BOOL lastNameValue;
- (BOOL)lastNameValue;
- (void)setLastNameValue:(BOOL)value_;

//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* nickName;


@property BOOL nickNameValue;
- (BOOL)nickNameValue;
- (void)setNickNameValue:(BOOL)value_;

//- (BOOL)validateNickName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* note;


@property BOOL noteValue;
- (BOOL)noteValue;
- (void)setNoteValue:(BOOL)value_;

//- (BOOL)validateNote:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* organization;


@property BOOL organizationValue;
- (BOOL)organizationValue;
- (void)setOrganizationValue:(BOOL)value_;

//- (BOOL)validateOrganization:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* phone;


@property BOOL phoneValue;
- (BOOL)phoneValue;
- (void)setPhoneValue:(BOOL)value_;

//- (BOOL)validatePhone:(id*)value_ error:(NSError**)error_;






@end

@interface _CTLCDFormSchema (CoreDataGeneratedAccessors)

@end

@interface _CTLCDFormSchema (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAddress;
- (void)setPrimitiveAddress:(NSNumber*)value;

- (BOOL)primitiveAddressValue;
- (void)setPrimitiveAddressValue:(BOOL)value_;




- (NSNumber*)primitiveAddress2;
- (void)setPrimitiveAddress2:(NSNumber*)value;

- (BOOL)primitiveAddress2Value;
- (void)setPrimitiveAddress2Value:(BOOL)value_;




- (NSNumber*)primitiveEmail;
- (void)setPrimitiveEmail:(NSNumber*)value;

- (BOOL)primitiveEmailValue;
- (void)setPrimitiveEmailValue:(BOOL)value_;




- (NSNumber*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSNumber*)value;

- (BOOL)primitiveFirstNameValue;
- (void)setPrimitiveFirstNameValue:(BOOL)value_;




- (NSNumber*)primitiveJobTitle;
- (void)setPrimitiveJobTitle:(NSNumber*)value;

- (BOOL)primitiveJobTitleValue;
- (void)setPrimitiveJobTitleValue:(BOOL)value_;




- (NSNumber*)primitiveLastName;
- (void)setPrimitiveLastName:(NSNumber*)value;

- (BOOL)primitiveLastNameValue;
- (void)setPrimitiveLastNameValue:(BOOL)value_;




- (NSNumber*)primitiveNickName;
- (void)setPrimitiveNickName:(NSNumber*)value;

- (BOOL)primitiveNickNameValue;
- (void)setPrimitiveNickNameValue:(BOOL)value_;




- (NSNumber*)primitiveNote;
- (void)setPrimitiveNote:(NSNumber*)value;

- (BOOL)primitiveNoteValue;
- (void)setPrimitiveNoteValue:(BOOL)value_;




- (NSNumber*)primitiveOrganization;
- (void)setPrimitiveOrganization:(NSNumber*)value;

- (BOOL)primitiveOrganizationValue;
- (void)setPrimitiveOrganizationValue:(BOOL)value_;




- (NSNumber*)primitivePhone;
- (void)setPrimitivePhone:(NSNumber*)value;

- (BOOL)primitivePhoneValue;
- (void)setPrimitivePhoneValue:(BOOL)value_;




@end
