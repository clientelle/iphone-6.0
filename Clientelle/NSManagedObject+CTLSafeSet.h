//
//  NSManagedObject+CTLSafeSet.h
//  Clientelle
//
//  Created by Kevin Liu on 5/6/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (CTLSafeSet)
- (void)safeSetValue:(id)value forKey:(NSString *)key;
@end