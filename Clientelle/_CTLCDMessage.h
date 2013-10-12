// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDMessage.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDMessageAttributes {
	__unsafe_unretained NSString *created_at;
	__unsafe_unretained NSString *message_text;
	__unsafe_unretained NSString *sender_uid;
} CTLCDMessageAttributes;

extern const struct CTLCDMessageRelationships {
	__unsafe_unretained NSString *conversation;
} CTLCDMessageRelationships;

extern const struct CTLCDMessageFetchedProperties {
} CTLCDMessageFetchedProperties;

@class CTLCDConversation;





@interface CTLCDMessageID : NSManagedObjectID {}
@end

@interface _CTLCDMessage : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDMessageID*)objectID;





@property (nonatomic, strong) NSDate* created_at;



//- (BOOL)validateCreated_at:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* message_text;



//- (BOOL)validateMessage_text:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sender_uid;



@property int32_t sender_uidValue;
- (int32_t)sender_uidValue;
- (void)setSender_uidValue:(int32_t)value_;

//- (BOOL)validateSender_uid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CTLCDConversation *conversation;

//- (BOOL)validateConversation:(id*)value_ error:(NSError**)error_;





@end

@interface _CTLCDMessage (CoreDataGeneratedAccessors)

@end

@interface _CTLCDMessage (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreated_at;
- (void)setPrimitiveCreated_at:(NSDate*)value;




- (NSString*)primitiveMessage_text;
- (void)setPrimitiveMessage_text:(NSString*)value;




- (NSNumber*)primitiveSender_uid;
- (void)setPrimitiveSender_uid:(NSNumber*)value;

- (int32_t)primitiveSender_uidValue;
- (void)setPrimitiveSender_uidValue:(int32_t)value_;





- (CTLCDConversation*)primitiveConversation;
- (void)setPrimitiveConversation:(CTLCDConversation*)value;


@end
