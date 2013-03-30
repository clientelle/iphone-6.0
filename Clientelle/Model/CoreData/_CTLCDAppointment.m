// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDAppointment.m instead.

#import "_CTLCDAppointment.h"

const struct CTLCDAppointmentAttributes CTLCDAppointmentAttributes = {
	.address = @"address",
	.city = @"city",
	.endDate = @"endDate",
	.eventID = @"eventID",
	.hasAddress = @"hasAddress",
	.location = @"location",
	.notes = @"notes",
	.startDate = @"startDate",
	.state = @"state",
	.title = @"title",
	.zip = @"zip",
};

const struct CTLCDAppointmentRelationships CTLCDAppointmentRelationships = {
};

const struct CTLCDAppointmentFetchedProperties CTLCDAppointmentFetchedProperties = {
};

@implementation CTLCDAppointmentID
@end

@implementation _CTLCDAppointment

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Appointment";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:moc_];
}

- (CTLCDAppointmentID*)objectID {
	return (CTLCDAppointmentID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"hasAddressValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hasAddress"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic address;






@dynamic city;






@dynamic endDate;






@dynamic eventID;






@dynamic hasAddress;



- (BOOL)hasAddressValue {
	NSNumber *result = [self hasAddress];
	return [result boolValue];
}

- (void)setHasAddressValue:(BOOL)value_ {
	[self setHasAddress:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHasAddressValue {
	NSNumber *result = [self primitiveHasAddress];
	return [result boolValue];
}

- (void)setPrimitiveHasAddressValue:(BOOL)value_ {
	[self setPrimitiveHasAddress:[NSNumber numberWithBool:value_]];
}





@dynamic location;






@dynamic notes;






@dynamic startDate;






@dynamic state;






@dynamic title;






@dynamic zip;











@end
