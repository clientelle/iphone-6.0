// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDInbox.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDInboxAttributes {
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *form_id;
	__unsafe_unretained NSString *install_code;
	__unsafe_unretained NSString *schema;
} CTLCDInboxAttributes;

extern const struct CTLCDInboxRelationships {
	__unsafe_unretained NSString *account;
} CTLCDInboxRelationships;

extern const struct CTLCDInboxFetchedProperties {
} CTLCDInboxFetchedProperties;

@class CTLCDAccount;






@interface CTLCDInboxID : NSManagedObjectID {}
@end

@interface _CTLCDInbox : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDInboxID*)objectID;





@property (nonatomic, strong) NSDate* created_at;



//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* form_id;



//- (BOOL)validateForm_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* install_code;



//- (BOOL)validateInstall_code:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* schema;



//- (BOOL)validateSchema:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CTLCDAccount *account;

//- (BOOL)validateAccount:(id*)value_ error:(NSError**)error_;





@end

@interface _CTLCDInbox (CoreDataGeneratedAccessors)

@end

@interface _CTLCDInbox (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;




- (NSString*)primitiveForm_id;
- (void)setPrimitiveForm_id:(NSString*)value;




- (NSString*)primitiveInstall_code;
- (void)setPrimitiveInstall_code:(NSString*)value;




- (NSString*)primitiveSchema;
- (void)setPrimitiveSchema:(NSString*)value;





- (CTLCDAccount*)primitiveAccount;
- (void)setPrimitiveAccount:(CTLCDAccount*)value;


@end
