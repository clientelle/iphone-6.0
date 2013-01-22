//
//  NSDate+CTLDate.m
//  Clientelle
//
//  Created by Kevin Liu on 9/21/12.
//  Copyright (c) 2012 Clientelle Leads LLC. All rights reserved.
//

#import "NSDate+CTLDate.h"

@implementation NSDate(CTLDate)

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:usLocale];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    
    return formatter;
}

+ (NSDateFormatter *)dateShortFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:usLocale];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    
    return formatter;
}

+ (NSDateFormatter *)dateStyleFormatter
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:usLocale];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    });
    
    return formatter;
}

+ (NSString *)dateShortToString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [NSDate dateShortFormatter];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)dateToString:(NSDate *)date {
    NSDateFormatter *dateFormatter = [NSDate dateFormatter];
    return [dateFormatter stringFromDate:date];
}

+ (NSPredicate *)predicateFromDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currDate = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDate *mdy = [calendar dateFromComponents:currDate];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"dueDate>=%@", mdy];
    return predicate;
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

+ (NSDate *)nextMonth {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currDate = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:[currDate month] + 1];
    [comps setDay:[currDate day]];
    [comps setYear:[currDate year]];
    return [calendar dateFromComponents:comps];
}

+ (NSDate *)threeMonthsAgo {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currDate = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:[currDate month] - 3];
    [comps setDay:[currDate day]];
    [comps setYear:[currDate year]];
    return [calendar dateFromComponents:comps];
}
+ (NSDate *)threeMonthsFromNow {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *currDate = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:[currDate month] + 3];
    [comps setDay:[currDate day]];
    [comps setYear:[currDate year]];
    return [calendar dateFromComponents:comps];
}

+ (NSDate *)fromComponents:(NSDateComponents *)components {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [calendar dateFromComponents:components];
}

@end
