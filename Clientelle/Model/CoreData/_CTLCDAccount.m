// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDAccount.m instead.

#import "_CTLCDAccount.h"

const struct CTLCDAccountAttributes CTLCDAccountAttributes = {
	.auth_token = @"auth_token",
	.company = @"company",
	.company_id = @"company_id",
	.created_at = @"created_at",
	.email = @"email",
	.first_name = @"first_name",
	.has_inbox = @"has_inbox",
	.industry = @"industry",
	.industry_id = @"industry_id",
	.is_pro = @"is_pro",
	.last_name = @"last_name",
	.password = @"password",
	.updated_at = @"updated_at",
	.user_id = @"user_id",
};

const struct CTLCDAccountRelationships CTLCDAccountRelationships = {
	.contacts = @"contacts",
	.conversation = @"conversation",
	.inbox = @"inbox",
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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"company_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"company_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"has_inboxValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"has_inbox"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"industry_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"industry_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"is_proValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_pro"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"user_idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"user_id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic auth_token;






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





@dynamic created_at;






@dynamic email;






@dynamic first_name;






@dynamic has_inbox;



- (BOOL)has_inboxValue {
	NSNumber *result = [self has_inbox];
	return [result boolValue];
}

- (void)setHas_inboxValue:(BOOL)value_ {
	[self setHas_inbox:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveHas_inboxValue {
	NSNumber *result = [self primitiveHas_inbox];
	return [result boolValue];
}

- (void)setPrimitiveHas_inboxValue:(BOOL)value_ {
	[self setPrimitiveHas_inbox:[NSNumber numberWithBool:value_]];
}





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





@dynamic is_pro;



- (BOOL)is_proValue {
	NSNumber *result = [self is_pro];
	return [result boolValue];
}

- (void)setIs_proValue:(BOOL)value_ {
	[self setIs_pro:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_proValue {
	NSNumber *result = [self primitiveIs_pro];
	return [result boolValue];
}

- (void)setPrimitiveIs_proValue:(BOOL)value_ {
	[self setPrimitiveIs_pro:[NSNumber numberWithBool:value_]];
}





@dynamic last_name;






@dynamic password;






@dynamic updated_at;






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





@dynamic contacts;

	
- (NSMutableSet*)contactsSet {
	[self willAccessValueForKey:@"contacts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"contacts"];
  
	[self didAccessValueForKey:@"contacts"];
	return result;
}
	

@dynamic conversation;

	
- (NSMutableSet*)conversationSet {
	[self willAccessValueForKey:@"conversation"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"conversation"];
  
	[self didAccessValueForKey:@"conversation"];
	return result;
}
	

@dynamic inbox;

	
- (NSMutableSet*)inboxSet {
	[self willAccessValueForKey:@"inbox"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"inbox"];
  
	[self didAccessValueForKey:@"inbox"];
	return result;
}
	






@end
