// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDInbox.m instead.

#import "_CTLCDInbox.h"

const struct CTLCDInboxAttributes CTLCDInboxAttributes = {
	.dateCreated = @"dateCreated",
	.formId = @"formId",
	.installCode = @"installCode",
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

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic dateCreated;






@dynamic formId;






@dynamic installCode;






@dynamic schema;











@end
