//
//  CTLPersonRecord.h
//  Clientelle
//
//  Created by Kevin Liu on 4/25/12.
//  Copyright (c) 2012 Clientelle Ltd. All rights reserved.
//

#import "CTLEvent.h"

NSString *const CTLCalendarIDKey = @"com.clientelle.com.userDefaultsKey.calendarName";

@implementation CTLEvent

- (id)initForEvents
{
	self = [super init];
	if(self != nil){
		_store = [[EKEventStore alloc] init];
        [_store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if(granted){
                NSLog(@"Granted");
            }else{
                NSLog(@"Not granted");
            }
        }];
    }
	return self;
}

/*
- (id)initWithForReminders
{
	self = [super init];
	if(self != nil){
		_store = [[EKEventStore alloc] init];
        [_store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
            if(granted){
                NSString *calendarID = [[NSUserDefaults standardUserDefaults] stringForKey:CTLCalendarIDKey];
                if(!calendarID){
                    _calendar = [self createCalendar];
                }else{
                    _calendar = [_store calendarWithIdentifier:calendarID];
                }
            }else{
                NSLog(@"Not granted");
            }
        }];
    }
	return self;
}*/

- (EKCalendar *)createCalendar {
    //get local calendar source (device calendar. not imap)
    EKSource *localSource = nil;
    for (EKSource *source in _store.sources) {
        if (source.sourceType == EKSourceTypeLocal) {
            localSource = source;
            break;
        }
    }
    //create a calendar to store app-created reminders
    EKCalendar *localCalendar = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:_store];
    localCalendar.title = @"Clientelle Reminders";
    localCalendar.source = localSource;
    [_store saveCalendar:localCalendar commit:YES error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:localCalendar.calendarIdentifier forKey:CTLCalendarIDKey];
    
    return localCalendar;
}

/*

+ (void)performBlockAndWait:(CTLVoidBlock)block withErrorHandler:(void(^)(NSError *))errorCallback
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        if(granted){
            dispatch_sync(dispatch_get_main_queue(), ^{
                block();
                dispatch_semaphore_signal(semaphore);
            });
        }else{
            if(errorCallback){
                errorCallback(error);
            }
            dispatch_semaphore_signal(semaphore);
        }
    }];
     
    while(dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)){
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}
 
 */

@end
