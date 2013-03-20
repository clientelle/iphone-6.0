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
            if(!granted){
                //TODO: Handel permission denied for calendars
                NSLog(@"Not granted");
            }
        }];
    }
	return self;
}

@end
