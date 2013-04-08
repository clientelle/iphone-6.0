// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDReminder.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDReminderAttributes {
	__unsafe_unretained NSString *compeleted;
	__unsafe_unretained NSString *completedDate;
	__unsafe_unretained NSString *dueDate;
	__unsafe_unretained NSString *eventID;
	__unsafe_unretained NSString *title;
} CTLCDReminderAttributes;

extern const struct CTLCDReminderRelationships {
} CTLCDReminderRelationships;

extern const struct CTLCDReminderFetchedProperties {
} CTLCDReminderFetchedProperties;








@interface CTLCDReminderID : NSManagedObjectID {}
@end

@interface _CTLCDReminder : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDReminderID*)objectID;




@property (nonatomic, strong) NSNumber* compeleted;


@property BOOL compeletedValue;
- (BOOL)compeletedValue;
- (void)setCompeletedValue:(BOOL)value_;

//- (BOOL)validateCompeleted:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* completedDate;


//- (BOOL)validateCompletedDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* dueDate;


//- (BOOL)validateDueDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* eventID;


//- (BOOL)validateEventID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;






@end

@interface _CTLCDReminder (CoreDataGeneratedAccessors)

@end

@interface _CTLCDReminder (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCompeleted;
- (void)setPrimitiveCompeleted:(NSNumber*)value;

- (BOOL)primitiveCompeletedValue;
- (void)setPrimitiveCompeletedValue:(BOOL)value_;




- (NSDate*)primitiveCompletedDate;
- (void)setPrimitiveCompletedDate:(NSDate*)value;




- (NSDate*)primitiveDueDate;
- (void)setPrimitiveDueDate:(NSDate*)value;




- (NSString*)primitiveEventID;
- (void)setPrimitiveEventID:(NSString*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




@end
