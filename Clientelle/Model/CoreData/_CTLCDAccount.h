// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDAccount.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDAccountAttributes {
	__unsafe_unretained NSString *access_token;
	__unsafe_unretained NSString *company;
	__unsafe_unretained NSString *company_id;
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *first_name;
	__unsafe_unretained NSString *industry;
	__unsafe_unretained NSString *industry_id;
	__unsafe_unretained NSString *last_name;
	__unsafe_unretained NSString *password;
	__unsafe_unretained NSString *user_id;
} CTLCDAccountAttributes;

extern const struct CTLCDAccountRelationships {
} CTLCDAccountRelationships;

extern const struct CTLCDAccountFetchedProperties {
} CTLCDAccountFetchedProperties;














@interface CTLCDAccountID : NSManagedObjectID {}
@end

@interface _CTLCDAccount : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDAccountID*)objectID;




@property (nonatomic, strong) NSString* access_token;


//- (BOOL)validateAccess_token:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* company;


//- (BOOL)validateCompany:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* company_id;


@property int16_t company_idValue;
- (int16_t)company_idValue;
- (void)setCompany_idValue:(int16_t)value_;

//- (BOOL)validateCompany_id:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* dateCreated;


//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* email;


//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* first_name;


//- (BOOL)validateFirst_name:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* industry;


//- (BOOL)validateIndustry:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* industry_id;


@property int16_t industry_idValue;
- (int16_t)industry_idValue;
- (void)setIndustry_idValue:(int16_t)value_;

//- (BOOL)validateIndustry_id:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* last_name;


//- (BOOL)validateLast_name:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* password;


//- (BOOL)validatePassword:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* user_id;


@property int16_t user_idValue;
- (int16_t)user_idValue;
- (void)setUser_idValue:(int16_t)value_;

//- (BOOL)validateUser_id:(id*)value_ error:(NSError**)error_;






@end

@interface _CTLCDAccount (CoreDataGeneratedAccessors)

@end

@interface _CTLCDAccount (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAccess_token;
- (void)setPrimitiveAccess_token:(NSString*)value;




- (NSString*)primitiveCompany;
- (void)setPrimitiveCompany:(NSString*)value;




- (NSNumber*)primitiveCompany_id;
- (void)setPrimitiveCompany_id:(NSNumber*)value;

- (int16_t)primitiveCompany_idValue;
- (void)setPrimitiveCompany_idValue:(int16_t)value_;




- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFirst_name;
- (void)setPrimitiveFirst_name:(NSString*)value;




- (NSString*)primitiveIndustry;
- (void)setPrimitiveIndustry:(NSString*)value;




- (NSNumber*)primitiveIndustry_id;
- (void)setPrimitiveIndustry_id:(NSNumber*)value;

- (int16_t)primitiveIndustry_idValue;
- (void)setPrimitiveIndustry_idValue:(int16_t)value_;




- (NSString*)primitiveLast_name;
- (void)setPrimitiveLast_name:(NSString*)value;




- (NSString*)primitivePassword;
- (void)setPrimitivePassword:(NSString*)value;




- (NSNumber*)primitiveUser_id;
- (void)setPrimitiveUser_id:(NSNumber*)value;

- (int16_t)primitiveUser_idValue;
- (void)setPrimitiveUser_idValue:(int16_t)value_;




@end
