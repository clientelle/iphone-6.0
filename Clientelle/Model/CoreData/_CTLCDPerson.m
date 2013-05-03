// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDPerson.m instead.

#import "_CTLCDPerson.h"

const struct CTLCDPersonAttributes CTLCDPersonAttributes = {
	.address = @"address",
	.compositeName = @"compositeName",
	.email = @"email",
	.firstName = @"firstName",
	.isPrivate = @"isPrivate",
	.jobTitle = @"jobTitle",
	.lastAccessed = @"lastAccessed",
	.lastName = @"lastName",
	.note = @"note",
	.organization = @"organization",
	.phone = @"phone",
	.picture = @"picture",
	.rating = @"rating",
	.recordID = @"recordID",
};

const struct CTLCDPersonRelationships CTLCDPersonRelationships = {
};

const struct CTLCDPersonFetchedProperties CTLCDPersonFetchedProperties = {
};

@implementation CTLCDPersonID
@end

@implementation _CTLCDPerson

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Person";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Person" inManagedObjectContext:moc_];
}

- (CTLCDPersonID*)objectID {
	return (CTLCDPersonID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isPrivateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isPrivate"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"ratingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"rating"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"recordIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"recordID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic address;






@dynamic compositeName;






@dynamic email;






@dynamic firstName;






@dynamic isPrivate;



- (BOOL)isPrivateValue {
	NSNumber *result = [self isPrivate];
	return [result boolValue];
}

- (void)setIsPrivateValue:(BOOL)value_ {
	[self setIsPrivate:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsPrivateValue {
	NSNumber *result = [self primitiveIsPrivate];
	return [result boolValue];
}

- (void)setPrimitiveIsPrivateValue:(BOOL)value_ {
	[self setPrimitiveIsPrivate:[NSNumber numberWithBool:value_]];
}





@dynamic jobTitle;






@dynamic lastAccessed;






@dynamic lastName;






@dynamic note;






@dynamic organization;






@dynamic phone;






@dynamic picture;






@dynamic rating;



- (int16_t)ratingValue {
	NSNumber *result = [self rating];
	return [result shortValue];
}

- (void)setRatingValue:(int16_t)value_ {
	[self setRating:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveRatingValue {
	NSNumber *result = [self primitiveRating];
	return [result shortValue];
}

- (void)setPrimitiveRatingValue:(int16_t)value_ {
	[self setPrimitiveRating:[NSNumber numberWithShort:value_]];
}





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










@end
