// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDInvite.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDInviteAttributes {
	__unsafe_unretained NSString *accepted;
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *record_id;
	__unsafe_unretained NSString *token;
} CTLCDInviteAttributes;

extern const struct CTLCDInviteRelationships {
	__unsafe_unretained NSString *contact;
} CTLCDInviteRelationships;

extern const struct CTLCDInviteFetchedProperties {
} CTLCDInviteFetchedProperties;

@class CTLCDContact;








@interface CTLCDInviteID : NSManagedObjectID {}
@end

@interface _CTLCDInvite : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDInviteID*)objectID;





@property (nonatomic, strong) NSNumber* accepted;



@property BOOL acceptedValue;
- (BOOL)acceptedValue;
- (void)setAcceptedValue:(BOOL)value_;

//- (BOOL)validateAccepted:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* created_at;



//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* id;



@property int32_t idValue;
- (int32_t)idValue;
- (void)setIdValue:(int32_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* record_id;



@property int16_t record_idValue;
- (int16_t)record_idValue;
- (void)setRecord_idValue:(int16_t)value_;

//- (BOOL)validateRecord_id:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* token;



//- (BOOL)validateToken:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CTLCDContact *contact;

//- (BOOL)validateContact:(id*)value_ error:(NSError**)error_;





@end

@interface _CTLCDInvite (CoreDataGeneratedAccessors)

@end

@interface _CTLCDInvite (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAccepted;
- (void)setPrimitiveAccepted:(NSNumber*)value;

- (BOOL)primitiveAcceptedValue;
- (void)setPrimitiveAcceptedValue:(BOOL)value_;




- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;




- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int32_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveRecord_id;
- (void)setPrimitiveRecord_id:(NSNumber*)value;

- (int16_t)primitiveRecord_idValue;
- (void)setPrimitiveRecord_idValue:(int16_t)value_;




- (NSString*)primitiveToken;
- (void)setPrimitiveToken:(NSString*)value;





- (CTLCDContact*)primitiveContact;
- (void)setPrimitiveContact:(CTLCDContact*)value;


@end
