// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDReminder.m instead.

#import "_CTLCDReminder.h"

const struct CTLCDReminderAttributes CTLCDReminderAttributes = {
	.compeleted = @"compeleted",
	.completedDate = @"completedDate",
	.dueDate = @"dueDate",
	.eventID = @"eventID",
	.title = @"title",
};

const struct CTLCDReminderRelationships CTLCDReminderRelationships = {
};

const struct CTLCDReminderFetchedProperties CTLCDReminderFetchedProperties = {
};

@implementation CTLCDReminderID
@end

@implementation _CTLCDReminder

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Reminders" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Reminders";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Reminders" inManagedObjectContext:moc_];
}

- (CTLCDReminderID*)objectID {
	return (CTLCDReminderID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"compeletedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"compeleted"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic compeleted;



- (BOOL)compeletedValue {
	NSNumber *result = [self compeleted];
	return [result boolValue];
}

- (void)setCompeletedValue:(BOOL)value_ {
	[self setCompeleted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCompeletedValue {
	NSNumber *result = [self primitiveCompeleted];
	return [result boolValue];
}

- (void)setPrimitiveCompeletedValue:(BOOL)value_ {
	[self setPrimitiveCompeleted:[NSNumber numberWithBool:value_]];
}





@dynamic completedDate;






@dynamic dueDate;






@dynamic eventID;






@dynamic title;











@end
