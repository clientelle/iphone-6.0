//
//  CTLReminder.h
//  Clientelle
//
//  Created by Kevin Liu on 4/25/12.
//  Copyright (c) 2012 Clientelle Ltd. All rights reserved.
//
#import <EventKit/EventKit.h>
extern NSString *const CTLCalendarIDKey;

typedef void (^CTLVoidBlock)(void);

@interface CTLEvent : NSObject {
    EKEventStore *_store;
    EKCalendar *_calendar;
}

@property (nonatomic, strong) EKEventStore *store;
@property (nonatomic, strong) EKCalendar *calendar;

//- (id)initWithForReminders;
- (id)initForEvents;

//+ (void)performBlockAndWait:(CTLVoidBlock)block withErrorHandler:(void(^)(NSError *))errorCallback;

@end
