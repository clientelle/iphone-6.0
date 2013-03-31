//
//  NSDate+CTLDate.h
//  Clientelle
//
//  Created by Kevin Liu on 9/21/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(CTLDate)

+ (NSDate *)hoursFrom:(NSDate *)date numberOfHours:(NSInteger)hours;
+ (NSDate *)hoursBefore:(NSDate *)date numberOfHours:(NSInteger)hours;
+ (NSDate *)nextMonth;
+ (NSDate *)monthsAgo:(int)num;
+ (NSDate *)monthsFromNow:(int)num;

+ (NSDate *)firstDayOfCurrentWeek;
+ (NSDate *)lastDayOfCurrentWeek;
+ (NSDate *)firstDateOfCurrentMonth;
+ (NSDate *)lastDateOfCurrentMonth;

+ (NSDate *)zeroHour:(NSCalendar *)calendar date:(NSDate *)date;
+ (NSDate *)today;
+ (NSDate *)tomorrow;

+ (NSDateFormatter *)dateFormatter;

+ (NSString *)dateShortToString:(NSDate *)date;
+ (NSString *)formatShortTimeOnly:(NSDate *)date;
+ (NSString *)formatShortDateOnly:(NSDate *)date;
+ (NSString *)dateToString:(NSDate *)date;
+ (NSDateFormatter *)dateStyleFormatter;
+ (NSDate *)fromComponents:(NSDateComponents *)components;

+ (NSDateFormatter *)dateOnlyFormat;

@end
