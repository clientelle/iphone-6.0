// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDAccount.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDAccountAttributes {
	__unsafe_unretained NSString *auth_token;
	__unsafe_unretained NSString *company;
	__unsafe_unretained NSString *company_id;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *first_name;
	__unsafe_unretained NSString *has_inbox;
	__unsafe_unretained NSString *industry;
	__unsafe_unretained NSString *industry_id;
	__unsafe_unretained NSString *is_pro;
	__unsafe_unretained NSString *last_name;
	__unsafe_unretained NSString *password;
	__unsafe_unretained NSString *updated_at;
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




@property (nonatomic, strong) NSString* auth_token;


//- (BOOL)validateAuth_token:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* company;


//- (BOOL)validateCompany:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* company_id;


@property int16_t company_idValue;
- (int16_t)company_idValue;
- (void)setCompany_idValue:(int16_t)value_;

//- (BOOL)validateCompany_id:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* created_at;


//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* email;


//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* first_name;


//- (BOOL)validateFirst_name:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* has_inbox;


@property BOOL has_inboxValue;
- (BOOL)has_inboxValue;
- (void)setHas_inboxValue:(BOOL)value_;

//- (BOOL)validateHas_inbox:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* industry;


//- (BOOL)validateIndustry:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* industry_id;


@property int16_t industry_idValue;
- (int16_t)industry_idValue;
- (void)setIndustry_idValue:(int16_t)value_;

//- (BOOL)validateIndustry_id:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* is_pro;


@property BOOL is_proValue;
- (BOOL)is_proValue;
- (void)setIs_proValue:(BOOL)value_;

//- (BOOL)validateIs_pro:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* last_name;


//- (BOOL)validateLast_name:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* password;


//- (BOOL)validatePassword:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* updated_at;


//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* user_id;


@property int16_t user_idValue;
- (int16_t)user_idValue;
- (void)setUser_idValue:(int16_t)value_;

//- (BOOL)validateUser_id:(id*)value_ error:(NSError**)error_;






@end

@interface _CTLCDAccount (CoreDataGeneratedAccessors)

@end

@interface _CTLCDAccount (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAuth_token;
- (void)setPrimitiveAuth_token:(NSString*)value;




- (NSString*)primitiveCompany;
- (void)setPrimitiveCompany:(NSString*)value;




- (NSNumber*)primitiveCompany_id;
- (void)setPrimitiveCompany_id:(NSNumber*)value;

- (int16_t)primitiveCompany_idValue;
- (void)setPrimitiveCompany_idValue:(int16_t)value_;




- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFirst_name;
- (void)setPrimitiveFirst_name:(NSString*)value;




- (NSNumber*)primitiveHas_inbox;
- (void)setPrimitiveHas_inbox:(NSNumber*)value;

- (BOOL)primitiveHas_inboxValue;
- (void)setPrimitiveHas_inboxValue:(BOOL)value_;




- (NSString*)primitiveIndustry;
- (void)setPrimitiveIndustry:(NSString*)value;




- (NSNumber*)primitiveIndustry_id;
- (void)setPrimitiveIndustry_id:(NSNumber*)value;

- (int16_t)primitiveIndustry_idValue;
- (void)setPrimitiveIndustry_idValue:(int16_t)value_;




- (NSNumber*)primitiveIs_pro;
- (void)setPrimitiveIs_pro:(NSNumber*)value;

- (BOOL)primitiveIs_proValue;
- (void)setPrimitiveIs_proValue:(BOOL)value_;




- (NSString*)primitiveLast_name;
- (void)setPrimitiveLast_name:(NSString*)value;




- (NSString*)primitivePassword;
- (void)setPrimitivePassword:(NSString*)value;




- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;




- (NSNumber*)primitiveUser_id;
- (void)setPrimitiveUser_id:(NSNumber*)value;

- (int16_t)primitiveUser_idValue;
- (void)setPrimitiveUser_idValue:(int16_t)value_;




@end
