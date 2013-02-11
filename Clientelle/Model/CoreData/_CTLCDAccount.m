// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDAccount.m instead.

#import "_CTLCDAccount.h"

const struct CTLCDAccountAttributes CTLCDAccountAttributes = {
	.access_token = @"access_token",
	.company = @"company",
	.dateCreated = @"dateCreated",
	.email = @"email",
	.industry = @"industry",
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
	
	if ([key isEqualToString:@"user_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"user_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic access_token;






@dynamic company;






@dynamic dateCreated;






@dynamic email;






@dynamic industry;






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
