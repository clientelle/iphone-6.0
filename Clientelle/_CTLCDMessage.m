// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDMessage.m instead.

#import "_CTLCDMessage.h"

const struct CTLCDMessageAttributes CTLCDMessageAttributes = {
	.created_at = @"created_at",
	.message_text = @"message_text",
	.sender_uid = @"sender_uid",
};

const struct CTLCDMessageRelationships CTLCDMessageRelationships = {
	.conversation = @"conversation",
};

const struct CTLCDMessageFetchedProperties CTLCDMessageFetchedProperties = {
};

@implementation CTLCDMessageID
@end

@implementation _CTLCDMessage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Message";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc_];
}

- (CTLCDMessageID*)objectID {
	return (CTLCDMessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"sender_uidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sender_uid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic created_at;






@dynamic message_text;






@dynamic sender_uid;



- (int32_t)sender_uidValue {
	NSNumber *result = [self sender_uid];
	return [result intValue];
}

- (void)setSender_uidValue:(int32_t)value_ {
	[self setSender_uid:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveSender_uidValue {
	NSNumber *result = [self primitiveSender_uid];
	return [result intValue];
}

- (void)setPrimitiveSender_uidValue:(int32_t)value_ {
	[self setPrimitiveSender_uid:[NSNumber numberWithInt:value_]];
}





@dynamic conversation;

	






@end
