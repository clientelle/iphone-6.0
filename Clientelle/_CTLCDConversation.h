// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDConversation.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDConversationAttributes {
	__unsafe_unretained NSString *last_sender_uid;
	__unsafe_unretained NSString *preview_message;
	__unsafe_unretained NSString *updated_at;
} CTLCDConversationAttributes;

extern const struct CTLCDConversationRelationships {
	__unsafe_unretained NSString *account;
	__unsafe_unretained NSString *contact;
	__unsafe_unretained NSString *messages;
} CTLCDConversationRelationships;

extern const struct CTLCDConversationFetchedProperties {
} CTLCDConversationFetchedProperties;

@class CTLCDAccount;
@class CTLCDContact;
@class CTLCDMessage;





@interface CTLCDConversationID : NSManagedObjectID {}
@end

@interface _CTLCDConversation : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDConversationID*)objectID;





@property (nonatomic, strong) NSNumber* last_sender_uid;



@property int16_t last_sender_uidValue;
- (int16_t)last_sender_uidValue;
- (void)setLast_sender_uidValue:(int16_t)value_;

//- (BOOL)validateLast_sender_uid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* preview_message;



//- (BOOL)validatePreview_message:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updated_at;



//- (BOOL)validateUpdated_at:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CTLCDAccount *account;

//- (BOOL)validateAccount:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) CTLCDContact *contact;

//- (BOOL)validateContact:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;





@end

@interface _CTLCDConversation (CoreDataGeneratedAccessors)

- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(CTLCDMessage*)value_;
- (void)removeMessagesObject:(CTLCDMessage*)value_;

@end

@interface _CTLCDConversation (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveLast_sender_uid;
- (void)setPrimitiveLast_sender_uid:(NSNumber*)value;

- (int16_t)primitiveLast_sender_uidValue;
- (void)setPrimitiveLast_sender_uidValue:(int16_t)value_;




- (NSString*)primitivePreview_message;
- (void)setPrimitivePreview_message:(NSString*)value;




- (NSDate*)primitiveUpdated_at;
- (void)setPrimitiveUpdated_at:(NSDate*)value;





- (CTLCDAccount*)primitiveAccount;
- (void)setPrimitiveAccount:(CTLCDAccount*)value;



- (CTLCDContact*)primitiveContact;
- (void)setPrimitiveContact:(CTLCDContact*)value;



- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;


@end
