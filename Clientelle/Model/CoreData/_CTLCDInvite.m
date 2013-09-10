// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDInvite.m instead.

#import "_CTLCDInvite.h"

const struct CTLCDInviteAttributes CTLCDInviteAttributes = {
	.accepted = @"accepted",
	.created_at = @"created_at",
	.id = @"id",
	.name = @"name",
	.record_id = @"record_id",
	.token = @"token",
};

const struct CTLCDInviteRelationships CTLCDInviteRelationships = {
	.account = @"account",
};

const struct CTLCDInviteFetchedProperties CTLCDInviteFetchedProperties = {
};

@implementation CTLCDInviteID
@end

@implementation _CTLCDInvite

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Invite" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Invite";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Invite" inManagedObjectContext:moc_];
}

- (CTLCDInviteID*)objectID {
	return (CTLCDInviteID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"acceptedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"accepted"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"record_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"record_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic accepted;



- (BOOL)acceptedValue {
	NSNumber *result = [self accepted];
	return [result boolValue];
}

- (void)setAcceptedValue:(BOOL)value_ {
	[self setAccepted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAcceptedValue {
	NSNumber *result = [self primitiveAccepted];
	return [result boolValue];
}

- (void)setPrimitiveAcceptedValue:(BOOL)value_ {
	[self setPrimitiveAccepted:[NSNumber numberWithBool:value_]];
}





@dynamic created_at;






@dynamic id;



- (int32_t)idValue {
	NSNumber *result = [self id];
	return [result intValue];
}

- (void)setIdValue:(int32_t)value_ {
	[self setId:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveIdValue {
	NSNumber *result = [self primitiveId];
	return [result intValue];
}

- (void)setPrimitiveIdValue:(int32_t)value_ {
	[self setPrimitiveId:[NSNumber numberWithInt:value_]];
}





@dynamic name;






@dynamic record_id;



- (int16_t)record_idValue {
	NSNumber *result = [self record_id];
	return [result shortValue];
}

- (void)setRecord_idValue:(int16_t)value_ {
	[self setRecord_id:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveRecord_idValue {
	NSNumber *result = [self primitiveRecord_id];
	return [result shortValue];
}

- (void)setPrimitiveRecord_idValue:(int16_t)value_ {
	[self setPrimitiveRecord_id:[NSNumber numberWithShort:value_]];
}





@dynamic token;






@dynamic account;

	






@end
