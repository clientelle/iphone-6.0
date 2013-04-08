//
//  NSDate+CTLDate.m
//  Clientelle
//
//  Created by Kevin Liu on 9/21/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "NSDate+CTLDate.h"

@implementation NSDate(CTLDate)

+ (NSDateFormatter *)dateAndTimeFormat
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]]];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    return formatter;
}

+ (NSDateFormatter *)dateShortFormat
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]]];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    return formatter;
}

+ (NSDateFormatter *)dateOnlyFormat
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]]];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    return formatter;
}

+ (NSDateFormatter *)timeOnlyFormat
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] objectForKey:NSLocaleIdentifier]]];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    return formatter;
}

+ (NSString *)formatShortDateOnly:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDate dateOnlyFormat];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatShortTimeOnly:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDate timeOnlyFormat];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)formatDateAndTime:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDate dateAndTimeFormat];
    return [dateFormatter stringFromDate:date];
}

+ (NSPredicate *)predicateFromDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currDate = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDate *mdy = [calendar dateFromComponents:currDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"dueDate>=%@", mdy];
    return predicate;
}

+ (NSDate *)zeroHour:(NSCalendar *)calendar date:(NSDate *)date
{
    NSDateComponents *currentDateComp = [calendar components: NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
    NSDateComponents *zeroHourComp = [[NSDateComponents alloc] init];
    [zeroHourComp setMonth:[currentDateComp month]];
    [zeroHourComp setDay:[currentDateComp day]];
    [zeroHourComp setYear:[currentDateComp year]];
    [zeroHourComp setHour:0];
    [zeroHourComp setMinute:0];
    [zeroHourComp setSecond:0];
    
    return [calendar dateFromComponents:zeroHourComp];
}

+ (NSDate *)today
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [NSDate zeroHour:calendar date:[NSDate date]];
}

+ (NSDate *)tomorrow
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *today = [NSDate zeroHour:calendar date:[NSDate date]];
    
    NSDateComponents *currDate = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit  fromDate:today];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
        
    [comps setMonth:[currDate month]];
    [comps setDay:[currDate day]+1];
    [comps setYear:[currDate year]];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    
    return [calendar dateFromComponents:comps];
}

+ (NSDate *)firstDayOfCurrentWeek
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *today = [NSDate zeroHour:calendar date:[NSDate date]];
    
    //if today is sunday
    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:today];
    if([weekdayComponents weekday] == 2){
        return today;
    }

    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay: - ([weekdayComponents weekday] - ([calendar firstWeekday]+1))];
    NSDate *beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
    NSDateComponents *components = [calendar components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate: beginningOfWeek];
    return [calendar dateFromComponents: components];
}

+ (NSDate *)lastDayOfCurrentWeek
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *today = [NSDate zeroHour:calendar date:[NSDate date]];

    NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:today];
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    
    //if today is sunday
    if([weekdayComponents weekday] == 1){
        return today;
    }
    
    [componentsToAdd setDay: 7 - ([weekdayComponents weekday] - [calendar firstWeekday])];
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:today options:0];
    NSDateComponents *components = [calendar components: (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:endOfWeek];
    return [calendar dateFromComponents: components];
}

+ (NSDate *)firstDateOfCurrentMonth
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *today = [NSDate zeroHour:calendar date:[NSDate date]];
    NSDateComponents *comp = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
    [comp setDay:1];
    return [calendar dateFromComponents:comp];
}

+ (NSDate *)lastDateOfCurrentMonth
{
    NSDate *curDate = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSRange daysRange = [currentCalendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:curDate];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comp = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    [comp setDay:daysRange.length];
    return [gregorian dateFromComponents:comp];
}

+ (NSDate *)hoursFrom:(NSDate *)date numberOfHours:(NSInteger)hours
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate: date];
    [comps setHour: [comps hour]+hours];
    return [calendar dateFromComponents:comps];
}

+ (NSDate *)hoursBefore:(NSDate *)date numberOfHours:(NSInteger)hours
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components: NSEraCalendarUnit|NSYearCalendarUnit| NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit fromDate: date];
    [comps setHour: [comps hour]-hours];
    return [calendar dateFromComponents:comps];
}

+ (NSDate *)monthsAgo:(int)num
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currDate = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:[currDate month] - num];
    [comps setDay:[currDate day]];
    [comps setYear:[currDate year]];
    return [calendar dateFromComponents:comps];
}

+ (NSDate *)monthsFromNow:(int)num
{
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currDate = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:[currDate month] + num];
    [comps setDay:[currDate day]];
    [comps setYear:[currDate year]];
    return [calendar dateFromComponents:comps];
}

+ (NSDate *)dateFromComponents:(NSDateComponents *)components
{
     NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
     return [calendar dateFromComponents:components];
}

@end
