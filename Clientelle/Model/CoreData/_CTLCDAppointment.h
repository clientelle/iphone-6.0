// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDAppointment.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDAppointmentAttributes {
	__unsafe_unretained NSString *address;
	__unsafe_unretained NSString *address2;
	__unsafe_unretained NSString *completed;
	__unsafe_unretained NSString *endDate;
	__unsafe_unretained NSString *eventID;
	__unsafe_unretained NSString *fee;
	__unsafe_unretained NSString *notes;
	__unsafe_unretained NSString *paid;
	__unsafe_unretained NSString *private;
	__unsafe_unretained NSString *startDate;
	__unsafe_unretained NSString *title;
} CTLCDAppointmentAttributes;

extern const struct CTLCDAppointmentRelationships {
	__unsafe_unretained NSString *contact;
} CTLCDAppointmentRelationships;

extern const struct CTLCDAppointmentFetchedProperties {
} CTLCDAppointmentFetchedProperties;

@class CTLCDPerson;













@interface CTLCDAppointmentID : NSManagedObjectID {}
@end

@interface _CTLCDAppointment : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDAppointmentID*)objectID;




@property (nonatomic, strong) NSString* address;


//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* address2;


//- (BOOL)validateAddress2:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* completed;


@property BOOL completedValue;
- (BOOL)completedValue;
- (void)setCompletedValue:(BOOL)value_;

//- (BOOL)validateCompleted:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* endDate;


//- (BOOL)validateEndDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* eventID;


//- (BOOL)validateEventID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDecimalNumber* fee;


//- (BOOL)validateFee:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* notes;


//- (BOOL)validateNotes:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* paid;


@property BOOL paidValue;
- (BOOL)paidValue;
- (void)setPaidValue:(BOOL)value_;

//- (BOOL)validatePaid:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* private;


@property BOOL privateValue;
- (BOOL)privateValue;
- (void)setPrivateValue:(BOOL)value_;

//- (BOOL)validatePrivate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* startDate;


//- (BOOL)validateStartDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* title;


//- (BOOL)validateTitle:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) CTLCDPerson* contact;

//- (BOOL)validateContact:(id*)value_ error:(NSError**)error_;





@end

@interface _CTLCDAppointment (CoreDataGeneratedAccessors)

@end

@interface _CTLCDAppointment (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;




- (NSString*)primitiveAddress2;
- (void)setPrimitiveAddress2:(NSString*)value;




- (NSNumber*)primitiveCompleted;
- (void)setPrimitiveCompleted:(NSNumber*)value;

- (BOOL)primitiveCompletedValue;
- (void)setPrimitiveCompletedValue:(BOOL)value_;




- (NSDate*)primitiveEndDate;
- (void)setPrimitiveEndDate:(NSDate*)value;




- (NSString*)primitiveEventID;
- (void)setPrimitiveEventID:(NSString*)value;




- (NSDecimalNumber*)primitiveFee;
- (void)setPrimitiveFee:(NSDecimalNumber*)value;




- (NSString*)primitiveNotes;
- (void)setPrimitiveNotes:(NSString*)value;




- (NSNumber*)primitivePaid;
- (void)setPrimitivePaid:(NSNumber*)value;

- (BOOL)primitivePaidValue;
- (void)setPrimitivePaidValue:(BOOL)value_;




- (NSNumber*)primitivePrivate;
- (void)setPrimitivePrivate:(NSNumber*)value;

- (BOOL)primitivePrivateValue;
- (void)setPrimitivePrivateValue:(BOOL)value_;




- (NSDate*)primitiveStartDate;
- (void)setPrimitiveStartDate:(NSDate*)value;




- (NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(NSString*)value;





- (CTLCDPerson*)primitiveContact;
- (void)setPrimitiveContact:(CTLCDPerson*)value;


@end
