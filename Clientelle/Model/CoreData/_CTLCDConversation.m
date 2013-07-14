// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDConversation.m instead.

#import "_CTLCDConversation.h"

const struct CTLCDConversationAttributes CTLCDConversationAttributes = {
	.last_sender_uid = @"last_sender_uid",
	.preview_message = @"preview_message",
	.updated_at = @"updated_at",
};

const struct CTLCDConversationRelationships CTLCDConversationRelationships = {
	.account = @"account",
	.contact = @"contact",
	.messages = @"messages",
};

const struct CTLCDConversationFetchedProperties CTLCDConversationFetchedProperties = {
};

@implementation CTLCDConversationID
@end

@implementation _CTLCDConversation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Conversation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Conversation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Conversation" inManagedObjectContext:moc_];
}

- (CTLCDConversationID*)objectID {
	return (CTLCDConversationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"last_sender_uidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"last_sender_uid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic last_sender_uid;



- (int16_t)last_sender_uidValue {
	NSNumber *result = [self last_sender_uid];
	return [result shortValue];
}

- (void)setLast_sender_uidValue:(int16_t)value_ {
	[self setLast_sender_uid:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveLast_sender_uidValue {
	NSNumber *result = [self primitiveLast_sender_uid];
	return [result shortValue];
}

- (void)setPrimitiveLast_sender_uidValue:(int16_t)value_ {
	[self setPrimitiveLast_sender_uid:[NSNumber numberWithShort:value_]];
}





@dynamic preview_message;






@dynamic updated_at;






@dynamic account;

	

@dynamic contact;

	

@dynamic messages;

	
- (NSMutableSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"messages"];
  
	[self didAccessValueForKey:@"messages"];
	return result;
}
	






@end
