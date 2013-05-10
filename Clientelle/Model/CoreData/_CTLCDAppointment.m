// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDAppointment.m instead.

#import "_CTLCDAppointment.h"

const struct CTLCDAppointmentAttributes CTLCDAppointmentAttributes = {
	.address = @"address",
	.address2 = @"address2",
	.completed = @"completed",
	.endDate = @"endDate",
	.eventID = @"eventID",
	.fee = @"fee",
	.notes = @"notes",
	.paid = @"paid",
	.startDate = @"startDate",
	.title = @"title",
};

const struct CTLCDAppointmentRelationships CTLCDAppointmentRelationships = {
	.contact = @"contact",
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
	
	if ([key isEqualToString:@"completedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"completed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"paidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"paid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic address;






@dynamic address2;






@dynamic completed;



- (BOOL)completedValue {
	NSNumber *result = [self completed];
	return [result boolValue];
}

- (void)setCompletedValue:(BOOL)value_ {
	[self setCompleted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCompletedValue {
	NSNumber *result = [self primitiveCompleted];
	return [result boolValue];
}

- (void)setPrimitiveCompletedValue:(BOOL)value_ {
	[self setPrimitiveCompleted:[NSNumber numberWithBool:value_]];
}





@dynamic endDate;






@dynamic eventID;






@dynamic fee;






@dynamic notes;






@dynamic paid;



- (BOOL)paidValue {
	NSNumber *result = [self paid];
	return [result boolValue];
}

- (void)setPaidValue:(BOOL)value_ {
	[self setPaid:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePaidValue {
	NSNumber *result = [self primitivePaid];
	return [result boolValue];
}

- (void)setPrimitivePaidValue:(BOOL)value_ {
	[self setPrimitivePaid:[NSNumber numberWithBool:value_]];
}





@dynamic startDate;






@dynamic title;






@dynamic contact;

	






@end
