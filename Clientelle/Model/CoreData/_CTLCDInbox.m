// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDInbox.m instead.

#import "_CTLCDInbox.h"

const struct CTLCDInboxAttributes CTLCDInboxAttributes = {
	.dateCreated = @"dateCreated",
	.form_id = @"form_id",
	.install_code = @"install_code",
	.schema = @"schema",
};

const struct CTLCDInboxRelationships CTLCDInboxRelationships = {
};

const struct CTLCDInboxFetchedProperties CTLCDInboxFetchedProperties = {
};

@implementation CTLCDInboxID
@end

@implementation _CTLCDInbox

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Inbox" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Inbox";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Inbox" inManagedObjectContext:moc_];
}

- (CTLCDInboxID*)objectID {
	return (CTLCDInboxID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic dateCreated;






@dynamic form_id;






@dynamic install_code;






@dynamic schema;











@end
