//
//  NSManagedObject+CTLSafeSet.m
//  Clientelle
//
//  Created by Kevin Liu on 5/6/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "NSManagedObject+CTLSafeSet.h"

@implementation NSManagedObject (CTLSafeSet)

- (void)safeSetValue:(id)value forKey:(NSString *)key {
    
    if (!value || [value isKindOfClass:[NSNull class]]) {
        return;
    }
    
    NSDictionary *attributes = [[self entity] attributesByName];
    NSAttributeType attributeType = [attributes[key] attributeType];
    if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
        value = [value stringValue];
    } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([value isKindOfClass:[NSString class]])) {
        value = @([value integerValue]);
    } else if ((attributeType == NSFloatAttributeType || attributeType == NSDoubleAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
        value = @([value doubleValue]);
    } else if (attributeType == NSDateAttributeType) {
        value = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
    }
    
    if (![value isEqual:[self valueForKey:key]]) {
        [self setValue:value forKey:key];
    }
}

@end
