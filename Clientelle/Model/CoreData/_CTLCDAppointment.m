// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDAppointment.m instead.

#import "_CTLCDAppointment.h"

const struct CTLCDAppointmentAttributes CTLCDAppointmentAttributes = {
	.endDate = @"endDate",
	.eventID = @"eventID",
	.location = @"location",
	.note = @"note",
	.startDate = @"startDate",
	.title = @"title",
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
	

	return keyPaths;
}




@dynamic endDate;






@dynamic eventID;






@dynamic location;






@dynamic note;






@dynamic startDate;






@dynamic title;











@end
