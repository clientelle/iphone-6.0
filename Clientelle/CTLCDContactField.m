#import "CTLCDContactField.h"

NSString *const kCTLFieldName = @"field";
NSString *const kCTLFieldValue = @"value";
NSString *const kCTLFieldLabel = @"label";

NSString *const kCTLFieldEnabled = @"enabled";
NSString *const kCTLFieldPlaceholder = @"placeholder";
NSString *const kCTLFieldSortOrder = @"sortOrder";

NSString *const kCTLFieldKeyboardType = @"keyboardType";
NSString *const kCTLFieldAutoCapitalizeType = @"autocapitalizationType";
NSString *const kCTLFieldAutoCorrectionType = @"autocorrectionType";


@implementation CTLCDContactField

// Custom logic goes here.

- (NSString *)label
{
    NSString *label = [NSString stringWithFormat:@"CONTACT_LABEL_%@", self.field];
    return NSLocalizedString(label, nil);
}

- (NSString *)placeholder
{
    NSString *placeholder = [NSString stringWithFormat:@"CONTACT_PLACEHOLDER_%@", self.field];
    return NSLocalizedString(placeholder, nil);
}

+ (NSArray *)fetchAllFields
{
    return [CTLCDContactField MR_findAllSortedBy:kCTLFieldSortOrder ascending:YES withPredicate:nil];
}

+ (NSArray *)createFields
{
    //Default schema from Plist
    NSDictionary *fieldDefaults = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ContactFormDefaults" ofType:@"plist"]];

    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSString *key in fieldDefaults) {
        NSDictionary *defaults = fieldDefaults[key];
        CTLCDContactField *contactField = [CTLCDContactField MR_createEntity];
        //Set defaults based on ContactFormDefaults pList
        contactField.field = key;
        contactField.enabled = [defaults valueForKey:kCTLFieldEnabled];
        contactField.keyboardType = [defaults valueForKey:kCTLFieldKeyboardType];
        contactField.autocapitalizationType = [defaults valueForKey:kCTLFieldAutoCapitalizeType];
        contactField.autocorrectionType = [defaults valueForKey:kCTLFieldAutoCorrectionType];
        contactField.sortOrder = [defaults valueForKey:kCTLFieldSortOrder];
        //queue it up so we dont have to refetch
        [tempArray addObject:contactField];
    }
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_newMainQueueContext];
    [context  MR_saveToPersistentStoreAndWait];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:kCTLFieldSortOrder ascending:YES]];
    return [[NSArray arrayWithArray:tempArray] sortedArrayUsingDescriptors:sortDescriptors];
}

@end
