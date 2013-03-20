//
//  CTLFactoryAppointment.m
//  Clientelle
//
//  Created by Kevin Liu on 3/18/13.
//  Copyright (c) 2013 Kevin Liu. All rights reserved.
//

#import "CTLFactoryAppointment.h"
#import "CTLCDAppointment.h"

@implementation CTLFactoryAppointment

- (void)createAppointmentsForMonth:(NSDate *)date
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSRange daysRange = [currentCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    
    for(NSInteger i=0;i<daysRange.length;i++){
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate: date];
        
        [comps setHour: [comps hour]];
        [comps setDay:[comps day] + i];
        NSDate *date = [calendar dateFromComponents:comps];
        
        [self createAppointments:date];
    }
}

- (void)createAppointments:(NSDate *)date
{
    int r = arc4random() % 4;
    
    for(NSInteger i=0;i< r;i++){
        
        CTLCDAppointment *appointment = [CTLCDAppointment MR_createEntity];
        appointment.eventID = @"abc";
        appointment.title = [self withRandomPerson];
        appointment.startDate = date;
        appointment.endDate = date;
        appointment.location = [self randomLocation];
        
        [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    }
}

- (NSString *)withRandomPerson{
    
    int rV = arc4random() % 3;
    int rF = arc4random() % 10;
    int rL = arc4random() % 10;
    
    NSArray *verbs = @[@"Meeting", @"Interview", @"Lunch", @"Call"];
    NSArray *firstNames = @[@"Jessica", @"Mike", @"Henry", @"Clive", @"Rachel", @"Chance", @"Jeremy", @"Ross", @"Erica", @"Mace", @"David"];
    NSArray *lastNames = @[@"Simpson", @"Bower", @"Etta", @"Owens", @"McGee", @"Lee", @"Oswald", @"Lerner", @"Loeb", @"Smith", @"Harden"];
    
    return [NSString stringWithFormat:@"%@ with %@ %@", verbs[rV], firstNames[rF], lastNames[rL]];
}

- (NSString *)randomLocation{
    int rP = arc4random() % 10;
    NSArray *places = @[@"Starbucks", @"Los Angeles", @"Cerritos Mall", @"Chili's, Chino Hills", @"Swap Meet", @"Olive Garden", @"My Office", @"Vendor's Site", @"GooglePlex", @"South Bay", @"Heroku Center"];
    return places[rP];
}


@end
