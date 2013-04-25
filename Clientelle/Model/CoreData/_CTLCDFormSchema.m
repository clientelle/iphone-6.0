// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDFormSchema.m instead.

#import "_CTLCDFormSchema.h"

const struct CTLCDFormSchemaAttributes CTLCDFormSchemaAttributes = {
	.address = @"address",
	.email = @"email",
	.firstName = @"firstName",
	.jobTitle = @"jobTitle",
	.lastName = @"lastName",
	.note = @"note",
	.organization = @"organization",
	.phone = @"phone",
};

const struct CTLCDFormSchemaRelationships CTLCDFormSchemaRelationships = {
};

const struct CTLCDFormSchemaFetchedProperties CTLCDFormSchemaFetchedProperties = {
};

@implementation CTLCDFormSchemaID
@end

@implementation _CTLCDFormSchema

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FormSchema" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FormSchema";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FormSchema" inManagedObjectContext:moc_];
}

- (CTLCDFormSchemaID*)objectID {
	return (CTLCDFormSchemaID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"addressValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"address"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"emailValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"email"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"firstNameValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"firstName"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"jobTitleValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"jobTitle"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"lastNameValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lastName"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"noteValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"note"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"organizationValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"organization"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"phoneValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"phone"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic address;



- (BOOL)addressValue {
	NSNumber *result = [self address];
	return [result boolValue];
}

- (void)setAddressValue:(BOOL)value_ {
	[self setAddress:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAddressValue {
	NSNumber *result = [self primitiveAddress];
	return [result boolValue];
}

- (void)setPrimitiveAddressValue:(BOOL)value_ {
	[self setPrimitiveAddress:[NSNumber numberWithBool:value_]];
}





@dynamic email;



- (BOOL)emailValue {
	NSNumber *result = [self email];
	return [result boolValue];
}

- (void)setEmailValue:(BOOL)value_ {
	[self setEmail:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveEmailValue {
	NSNumber *result = [self primitiveEmail];
	return [result boolValue];
}

- (void)setPrimitiveEmailValue:(BOOL)value_ {
	[self setPrimitiveEmail:[NSNumber numberWithBool:value_]];
}





@dynamic firstName;



- (BOOL)firstNameValue {
	NSNumber *result = [self firstName];
	return [result boolValue];
}

- (void)setFirstNameValue:(BOOL)value_ {
	[self setFirstName:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFirstNameValue {
	NSNumber *result = [self primitiveFirstName];
	return [result boolValue];
}

- (void)setPrimitiveFirstNameValue:(BOOL)value_ {
	[self setPrimitiveFirstName:[NSNumber numberWithBool:value_]];
}





@dynamic jobTitle;



- (BOOL)jobTitleValue {
	NSNumber *result = [self jobTitle];
	return [result boolValue];
}

- (void)setJobTitleValue:(BOOL)value_ {
	[self setJobTitle:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveJobTitleValue {
	NSNumber *result = [self primitiveJobTitle];
	return [result boolValue];
}

- (void)setPrimitiveJobTitleValue:(BOOL)value_ {
	[self setPrimitiveJobTitle:[NSNumber numberWithBool:value_]];
}





@dynamic lastName;



- (BOOL)lastNameValue {
	NSNumber *result = [self lastName];
	return [result boolValue];
}

- (void)setLastNameValue:(BOOL)value_ {
	[self setLastName:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveLastNameValue {
	NSNumber *result = [self primitiveLastName];
	return [result boolValue];
}

- (void)setPrimitiveLastNameValue:(BOOL)value_ {
	[self setPrimitiveLastName:[NSNumber numberWithBool:value_]];
}





@dynamic note;



- (BOOL)noteValue {
	NSNumber *result = [self note];
	return [result boolValue];
}

- (void)setNoteValue:(BOOL)value_ {
	[self setNote:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNoteValue {
	NSNumber *result = [self primitiveNote];
	return [result boolValue];
}

- (void)setPrimitiveNoteValue:(BOOL)value_ {
	[self setPrimitiveNote:[NSNumber numberWithBool:value_]];
}





@dynamic organization;



- (BOOL)organizationValue {
	NSNumber *result = [self organization];
	return [result boolValue];
}

- (void)setOrganizationValue:(BOOL)value_ {
	[self setOrganization:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveOrganizationValue {
	NSNumber *result = [self primitiveOrganization];
	return [result boolValue];
}

- (void)setPrimitiveOrganizationValue:(BOOL)value_ {
	[self setPrimitiveOrganization:[NSNumber numberWithBool:value_]];
}





@dynamic phone;



- (BOOL)phoneValue {
	NSNumber *result = [self phone];
	return [result boolValue];
}

- (void)setPhoneValue:(BOOL)value_ {
	[self setPhone:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePhoneValue {
	NSNumber *result = [self primitivePhone];
	return [result boolValue];
}

- (void)setPrimitivePhoneValue:(BOOL)value_ {
	[self setPrimitivePhone:[NSNumber numberWithBool:value_]];
}










@end
