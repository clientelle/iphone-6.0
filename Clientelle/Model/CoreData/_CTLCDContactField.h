// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to CTLCDContactField.h instead.

#import <CoreData/CoreData.h>


extern const struct CTLCDContactFieldAttributes {
	__unsafe_unretained NSString *autocapitalizationType;
	__unsafe_unretained NSString *autocorrectionType;
	__unsafe_unretained NSString *enabled;
	__unsafe_unretained NSString *field;
	__unsafe_unretained NSString *keyboardType;
	__unsafe_unretained NSString *sortOrder;
} CTLCDContactFieldAttributes;

extern const struct CTLCDContactFieldRelationships {
} CTLCDContactFieldRelationships;

extern const struct CTLCDContactFieldFetchedProperties {
} CTLCDContactFieldFetchedProperties;









@interface CTLCDContactFieldID : NSManagedObjectID {}
@end

@interface _CTLCDContactField : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (CTLCDContactFieldID*)objectID;




@property (nonatomic, strong) NSNumber* autocapitalizationType;


@property int16_t autocapitalizationTypeValue;
- (int16_t)autocapitalizationTypeValue;
- (void)setAutocapitalizationTypeValue:(int16_t)value_;

//- (BOOL)validateAutocapitalizationType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* autocorrectionType;


@property int16_t autocorrectionTypeValue;
- (int16_t)autocorrectionTypeValue;
- (void)setAutocorrectionTypeValue:(int16_t)value_;

//- (BOOL)validateAutocorrectionType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* enabled;


@property BOOL enabledValue;
- (BOOL)enabledValue;
- (void)setEnabledValue:(BOOL)value_;

//- (BOOL)validateEnabled:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* field;


//- (BOOL)validateField:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* keyboardType;


@property int16_t keyboardTypeValue;
- (int16_t)keyboardTypeValue;
- (void)setKeyboardTypeValue:(int16_t)value_;

//- (BOOL)validateKeyboardType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* sortOrder;


@property int16_t sortOrderValue;
- (int16_t)sortOrderValue;
- (void)setSortOrderValue:(int16_t)value_;

//- (BOOL)validateSortOrder:(id*)value_ error:(NSError**)error_;






@end

@interface _CTLCDContactField (CoreDataGeneratedAccessors)

@end

@interface _CTLCDContactField (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAutocapitalizationType;
- (void)setPrimitiveAutocapitalizationType:(NSNumber*)value;

- (int16_t)primitiveAutocapitalizationTypeValue;
- (void)setPrimitiveAutocapitalizationTypeValue:(int16_t)value_;




- (NSNumber*)primitiveAutocorrectionType;
- (void)setPrimitiveAutocorrectionType:(NSNumber*)value;

- (int16_t)primitiveAutocorrectionTypeValue;
- (void)setPrimitiveAutocorrectionTypeValue:(int16_t)value_;




- (NSNumber*)primitiveEnabled;
- (void)setPrimitiveEnabled:(NSNumber*)value;

- (BOOL)primitiveEnabledValue;
- (void)setPrimitiveEnabledValue:(BOOL)value_;




- (NSString*)primitiveField;
- (void)setPrimitiveField:(NSString*)value;




- (NSNumber*)primitiveKeyboardType;
- (void)setPrimitiveKeyboardType:(NSNumber*)value;

- (int16_t)primitiveKeyboardTypeValue;
- (void)setPrimitiveKeyboardTypeValue:(int16_t)value_;




- (NSNumber*)primitiveSortOrder;
- (void)setPrimitiveSortOrder:(NSNumber*)value;

- (int16_t)primitiveSortOrderValue;
- (void)setPrimitiveSortOrderValue:(int16_t)value_;




@end
