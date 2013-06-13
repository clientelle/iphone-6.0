// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDContact.m instead.

#import "_CTLCDContact.h"

const struct CTLCDContactAttributes CTLCDContactAttributes = {
	.address = @"address",
	.address2 = @"address2",
	.contactID = @"contactID",
	.email = @"email",
	.firstName = @"firstName",
	.hasPrivateMsg = @"hasPrivateMsg",
	.jobTitle = @"jobTitle",
	.lastAccessed = @"lastAccessed",
	.lastName = @"lastName",
	.messagePreference = @"messagePreference",
	.mobile = @"mobile",
	.nickName = @"nickName",
	.note = @"note",
	.organization = @"organization",
	.phone = @"phone",
	.picture = @"picture",
	.recordID = @"recordID",
};

const struct CTLCDContactRelationships CTLCDContactRelationships = {
	.appointment = @"appointment",
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
	if ([key isEqualToString:@"hasPrivateMsgValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasPrivateMsg"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"messagePreferenceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"messagePreference"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"recordIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"recordID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic address;






@dynamic address2;






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






@dynamic hasPrivateMsg;



- (BOOL)hasPrivateMsgValue {
	NSNumber *result = [self hasPrivateMsg];
	return [result boolValue];
}

- (void)setHasPrivateMsgValue:(BOOL)value_ {
	[self setHasPrivateMsg:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasPrivateMsgValue {
	NSNumber *result = [self primitiveHasPrivateMsg];
	return [result boolValue];
}

- (void)setPrimitiveHasPrivateMsgValue:(BOOL)value_ {
	[self setPrimitiveHasPrivateMsg:[NSNumber numberWithBool:value_]];
}





@dynamic jobTitle;






@dynamic lastAccessed;






@dynamic lastName;






@dynamic messagePreference;



- (int16_t)messagePreferenceValue {
	NSNumber *result = [self messagePreference];
	return [result shortValue];
}

- (void)setMessagePreferenceValue:(int16_t)value_ {
	[self setMessagePreference:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveMessagePreferenceValue {
	NSNumber *result = [self primitiveMessagePreference];
	return [result shortValue];
}

- (void)setPrimitiveMessagePreferenceValue:(int16_t)value_ {
	[self setPrimitiveMessagePreference:[NSNumber numberWithShort:value_]];
}





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





@dynamic appointment;

	
- (NSMutableSet*)appointmentSet {
	[self willAccessValueForKey:@"appointment"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"appointment"];
  
	[self didAccessValueForKey:@"appointment"];
	return result;
}
	






@end
