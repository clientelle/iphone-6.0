// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDContactField.m instead.

#import "_CTLCDContactField.h"

const struct CTLCDContactFieldAttributes CTLCDContactFieldAttributes = {
	.autocapitalizationType = @"autocapitalizationType",
	.autocorrectionType = @"autocorrectionType",
	.enabled = @"enabled",
	.field = @"field",
	.keyboardType = @"keyboardType",
	.sortOrder = @"sortOrder",
};

const struct CTLCDContactFieldRelationships CTLCDContactFieldRelationships = {
};

const struct CTLCDContactFieldFetchedProperties CTLCDContactFieldFetchedProperties = {
};

@implementation CTLCDContactFieldID
@end

@implementation _CTLCDContactField

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ContactField" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ContactField";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ContactField" inManagedObjectContext:moc_];
}

- (CTLCDContactFieldID*)objectID {
	return (CTLCDContactFieldID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"autocapitalizationTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"autocapitalizationType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"autocorrectionTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"autocorrectionType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"enabledValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"enabled"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"keyboardTypeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"keyboardType"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sortOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic autocapitalizationType;



- (int16_t)autocapitalizationTypeValue {
	NSNumber *result = [self autocapitalizationType];
	return [result shortValue];
}

- (void)setAutocapitalizationTypeValue:(int16_t)value_ {
	[self setAutocapitalizationType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveAutocapitalizationTypeValue {
	NSNumber *result = [self primitiveAutocapitalizationType];
	return [result shortValue];
}

- (void)setPrimitiveAutocapitalizationTypeValue:(int16_t)value_ {
	[self setPrimitiveAutocapitalizationType:[NSNumber numberWithShort:value_]];
}





@dynamic autocorrectionType;



- (int16_t)autocorrectionTypeValue {
	NSNumber *result = [self autocorrectionType];
	return [result shortValue];
}

- (void)setAutocorrectionTypeValue:(int16_t)value_ {
	[self setAutocorrectionType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveAutocorrectionTypeValue {
	NSNumber *result = [self primitiveAutocorrectionType];
	return [result shortValue];
}

- (void)setPrimitiveAutocorrectionTypeValue:(int16_t)value_ {
	[self setPrimitiveAutocorrectionType:[NSNumber numberWithShort:value_]];
}





@dynamic enabled;



- (BOOL)enabledValue {
	NSNumber *result = [self enabled];
	return [result boolValue];
}

- (void)setEnabledValue:(BOOL)value_ {
	[self setEnabled:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveEnabledValue {
	NSNumber *result = [self primitiveEnabled];
	return [result boolValue];
}

- (void)setPrimitiveEnabledValue:(BOOL)value_ {
	[self setPrimitiveEnabled:[NSNumber numberWithBool:value_]];
}





@dynamic field;






@dynamic keyboardType;



- (int16_t)keyboardTypeValue {
	NSNumber *result = [self keyboardType];
	return [result shortValue];
}

- (void)setKeyboardTypeValue:(int16_t)value_ {
	[self setKeyboardType:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveKeyboardTypeValue {
	NSNumber *result = [self primitiveKeyboardType];
	return [result shortValue];
}

- (void)setPrimitiveKeyboardTypeValue:(int16_t)value_ {
	[self setPrimitiveKeyboardType:[NSNumber numberWithShort:value_]];
}





@dynamic sortOrder;



- (int16_t)sortOrderValue {
	NSNumber *result = [self sortOrder];
	return [result shortValue];
}

- (void)setSortOrderValue:(int16_t)value_ {
	[self setSortOrder:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSortOrderValue {
	NSNumber *result = [self primitiveSortOrder];
	return [result shortValue];
}

- (void)setPrimitiveSortOrderValue:(int16_t)value_ {
	[self setPrimitiveSortOrder:[NSNumber numberWithShort:value_]];
}










@end
