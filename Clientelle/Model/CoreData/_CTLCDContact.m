// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDContact.m instead.

#import "_CTLCDContact.h"

const struct CTLCDContactAttributes CTLCDContactAttributes = {
	.address = @"address",
	.address2 = @"address2",
	.compositeName = @"compositeName",
	.contactID = @"contactID",
	.email = @"email",
	.firstName = @"firstName",
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
	.user_id = @"user_id",
};

const struct CTLCDContactRelationships CTLCDContactRelationships = {
	.account = @"account",
	.appointment = @"appointment",
	.conversation = @"conversation",
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
	
	if ([key isEqualToString:@"contactIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"contactID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"recordIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"recordID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"user_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"user_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic address;






@dynamic address2;






@dynamic compositeName;






@dynamic contactID;



- (int16_t)contactIDValue {
	NSNumber *result = [self contactID];
	return [result shortValue];
}

- (void)setContactIDValue:(int16_t)value_ {
	[self setContactID:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveContactIDValue {
	NSNumber *result = [self primitiveContactID];
	return [result shortValue];
}

- (void)setPrimitiveContactIDValue:(int16_t)value_ {
	[self setPrimitiveContactID:[NSNumber numberWithShort:value_]];
}





@dynamic email;






@dynamic firstName;






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





@dynamic user_id;



- (int32_t)user_idValue {
	NSNumber *result = [self user_id];
	return [result intValue];
}

- (void)setUser_idValue:(int32_t)value_ {
	[self setUser_id:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveUser_idValue {
	NSNumber *result = [self primitiveUser_id];
	return [result intValue];
}

- (void)setPrimitiveUser_idValue:(int32_t)value_ {
	[self setPrimitiveUser_id:[NSNumber numberWithInt:value_]];
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

	






@end
