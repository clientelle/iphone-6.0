// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDInbox.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDInboxAttributes {
	__unsafe_unretained NSString *dateCreated;
	__unsafe_unretained NSString *formId;
	__unsafe_unretained NSString *installCode;
	__unsafe_unretained NSString *schema;
} CTLCDInboxAttributes;

extern const struct CTLCDInboxRelationships {
} CTLCDInboxRelationships;

extern const struct CTLCDInboxFetchedProperties {
} CTLCDInboxFetchedProperties;







@interface CTLCDInboxID : NSManagedObjectID {}
@end

@interface _CTLCDInbox : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDInboxID*)objectID;





@property (nonatomic, strong) NSDate* dateCreated;



//- (BOOL)validateDateCreated:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* formId;



//- (BOOL)validateFormId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* installCode;



//- (BOOL)validateInstallCode:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* schema;



//- (BOOL)validateSchema:(id*)value_ error:(NSError**)error_;






@end

@interface _CTLCDInbox (CoreDataGeneratedAccessors)

@end

@interface _CTLCDInbox (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDateCreated;
- (void)setPrimitiveDateCreated:(NSDate*)value;




- (NSString*)primitiveFormId;
- (void)setPrimitiveFormId:(NSString*)value;




- (NSString*)primitiveInstallCode;
- (void)setPrimitiveInstallCode:(NSString*)value;




- (NSString*)primitiveSchema;
- (void)setPrimitiveSchema:(NSString*)value;




@end
