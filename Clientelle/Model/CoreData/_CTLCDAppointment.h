// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDAppointment.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDAppointmentAttributes {
	__unsafe_unretained NSString *endDate;
	__unsafe_unretained NSString *eventID;
	__unsafe_unretained NSString *location;
	__unsafe_unretained NSString *notes;
	__unsafe_unretained NSString *startDate;
	__unsafe_unretained NSString *title;
} CTLCDAppointmentAttributes;

extern const struct CTLCDAppointmentRelationships {
} CTLCDAppointmentRelationships;

extern const struct CTLCDAppointmentFetchedProperties {
} CTLCDAppointmentFetchedProperties;









@interface CTLCDAppointmentID : NSManagedObjectID {}
@end

@interface _CTLCDAppointment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDAppointmentID*)objectID;




@property (nonatomic, strong) NSDate* endDate;


//- (BOOL)validateEndDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* eventID;


//- (BOOL)validateEventID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* location;


//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* notes;


//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* startDate;


//- (BOOL)validateStartDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;






@end

@interface _CTLCDAppointment (CoreDataGeneratedAccessors)

@end

@interface _CTLCDAppointment (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveEndDate;
- (void)setPrimitiveEndDate:(NSDate*)value;




- (NSString*)primitiveEventID;
- (void)setPrimitiveEventID:(NSString*)value;




- (NSString*)primitiveLocation;
- (void)setPrimitiveLocation:(NSString*)value;




- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;




- (NSDate*)primitiveStartDate;
- (void)setPrimitiveStartDate:(NSDate*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;




@end
