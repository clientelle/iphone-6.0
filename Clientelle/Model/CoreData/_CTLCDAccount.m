// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDAccount.m instead.

#import "_CTLCDAccount.h"

const struct CTLCDAccountAttributes CTLCDAccountAttributes = {
	.access_token = @"access_token",
	.company = @"company",
	.company_id = @"company_id",
	.dateCreated = @"dateCreated",
	.email = @"email",
	.first_name = @"first_name",
	.industry = @"industry",
	.industry_id = @"industry_id",
	.last_name = @"last_name",
	.password = @"password",
	.user_id = @"user_id",
};

const struct CTLCDAccountRelationships CTLCDAccountRelationships = {
};

const struct CTLCDAccountFetchedProperties CTLCDAccountFetchedProperties = {
};

@implementation CTLCDAccountID
@end

@implementation _CTLCDAccount

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Account" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Account";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Account" inManagedObjectContext:moc_];
}

- (CTLCDAccountID*)objectID {
	return (CTLCDAccountID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"company_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"company_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"industry_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"industry_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"user_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"user_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic access_token;






@dynamic company;






@dynamic company_id;



- (int16_t)company_idValue {
	NSNumber *result = [self company_id];
	return [result shortValue];
}

- (void)setCompany_idValue:(int16_t)value_ {
	[self setCompany_id:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveCompany_idValue {
	NSNumber *result = [self primitiveCompany_id];
	return [result shortValue];
}

- (void)setPrimitiveCompany_idValue:(int16_t)value_ {
	[self setPrimitiveCompany_id:[NSNumber numberWithShort:value_]];
}





@dynamic dateCreated;






@dynamic email;






@dynamic first_name;






@dynamic industry;






@dynamic industry_id;



- (int16_t)industry_idValue {
	NSNumber *result = [self industry_id];
	return [result shortValue];
}

- (void)setIndustry_idValue:(int16_t)value_ {
	[self setIndustry_id:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveIndustry_idValue {
	NSNumber *result = [self primitiveIndustry_id];
	return [result shortValue];
}

- (void)setPrimitiveIndustry_idValue:(int16_t)value_ {
	[self setPrimitiveIndustry_id:[NSNumber numberWithShort:value_]];
}





@dynamic last_name;






@dynamic password;






@dynamic user_id;



- (int16_t)user_idValue {
	NSNumber *result = [self user_id];
	return [result shortValue];
}

- (void)setUser_idValue:(int16_t)value_ {
	[self setUser_id:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveUser_idValue {
	NSNumber *result = [self primitiveUser_id];
	return [result shortValue];
}

- (void)setPrimitiveUser_idValue:(int16_t)value_ {
	[self setPrimitiveUser_id:[NSNumber numberWithShort:value_]];
}










@end
