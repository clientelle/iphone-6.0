// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDContact.m instead.

#import "_CTLCDContact.h"

const struct CTLCDContactAttributes CTLCDContactAttributes = {
	.address = @"address",
	.address2 = @"address2",
	.compositeName = @"compositeName",
	.email = @"email",
	.firstName = @"firstName",
	.hasMessenger = @"hasMessenger",
	.jobTitle = @"jobTitle",
	.lastAccessed = @"lastAccessed",
	.lastName = @"lastName",
	.mobile = @"mobile",
	.nickName = @"nickName",
	.note = @"note",
	.organization = @"organization",
	.phone = @"phone",
	.picture = @"picture",
	.recordID = @"recordID",
	.userId = @"userId",
};

const struct CTLCDContactRelationships CTLCDContactRelationships = {
	.account = @"account",
	.appointment = @"appointment",
	.conversation = @"conversation",
	.invite = @"invite",
};

const struct CTLCDContactFetchedProperties CTLCDContactFetchedProperties = {
};

@implementation CTLCDContactID
@end

@implementation _CTLCDContact

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Contact";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:moc_];
}

- (CTLCDContactID*)objectID {
	return (CTLCDContactID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"hasMessengerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasMessenger"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"recordIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"recordID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"userIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"userId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic address;






@dynamic address2;






@dynamic compositeName;






@dynamic email;






@dynamic firstName;






@dynamic hasMessenger;



- (BOOL)hasMessengerValue {
	NSNumber *result = [self hasMessenger];
	return [result boolValue];
}

- (void)setHasMessengerValue:(BOOL)value_ {
	[self setHasMessenger:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasMessengerValue {
	NSNumber *result = [self primitiveHasMessenger];
	return [result boolValue];
}

- (void)setPrimitiveHasMessengerValue:(BOOL)value_ {
	[self setPrimitiveHasMessenger:[NSNumber numberWithBool:value_]];
}





@dynamic jobTitle;






@dynamic lastAccessed;






@dynamic lastName;






@dynamic mobile;






@dynamic nickName;






@dynamic note;






@dynamic organization;






@dynamic phone;






@dynamic picture;






@dynamic recordID;



- (int16_t)recordIDValue {
	NSNumber *result = [self recordID];
	return [result shortValue];
}

- (void)setRecordIDValue:(int16_t)value_ {
	[self setRecordID:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveRecordIDValue {
	NSNumber *result = [self primitiveRecordID];
	return [result shortValue];
}

- (void)setPrimitiveRecordIDValue:(int16_t)value_ {
	[self setPrimitiveRecordID:[NSNumber numberWithShort:value_]];
}





@dynamic userId;



- (int16_t)userIdValue {
	NSNumber *result = [self userId];
	return [result shortValue];
}

- (void)setUserIdValue:(int16_t)value_ {
	[self setUserId:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveUserIdValue {
	NSNumber *result = [self primitiveUserId];
	return [result shortValue];
}

- (void)setPrimitiveUserIdValue:(int16_t)value_ {
	[self setPrimitiveUserId:[NSNumber numberWithShort:value_]];
}





@dynamic account;

	

@dynamic appointment;

	
- (NSMutableSet*)appointmentSet {
	[self willAccessValueForKey:@"appointment"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"appointment"];
  
	[self didAccessValueForKey:@"appointment"];
	return result;
}
	

@dynamic conversation;

	

@dynamic invite;

	






@end
