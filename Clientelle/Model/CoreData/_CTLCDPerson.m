// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDPerson.m instead.

#import "_CTLCDPerson.h"

const struct CTLCDPersonAttributes CTLCDPersonAttributes = {
	.address = @"address",
	.city = @"city",
	.email = @"email",
	.firstName = @"firstName",
	.jobTitle = @"jobTitle",
	.lastAccessed = @"lastAccessed",
	.lastName = @"lastName",
	.note = @"note",
	.organization = @"organization",
	.phone = @"phone",
	.rating = @"rating",
	.recordID = @"recordID",
	.state = @"state",
	.zip = @"zip",
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






@dynamic city;






@dynamic email;






@dynamic firstName;






@dynamic jobTitle;






@dynamic lastAccessed;






@dynamic lastName;






@dynamic note;






@dynamic organization;






@dynamic phone;






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





@dynamic state;






@dynamic zip;











@end
