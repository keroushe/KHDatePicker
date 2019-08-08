//
//  KHCalendarUtil.m
//  KHDatePickerKit
//
//  Created by He Kerous on 2019/8/8.
//  Copyright © 2019 He Kerous. All rights reserved.
//

#import "KHCalendarUtil.h"

@implementation KHCalendarUtil

/**
 计算出当前日期对应周的开始结束时间
 
 @param dateString yyyy-MM-dd
 @return [@"yyyy-MM-dd", @"yyyy-MM-dd"]
 */
+ (NSMutableArray<NSString *> *)getFirstDayFromWeek:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSMutableArray<NSString *> *dateArr = [NSMutableArray new];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 设置一周的第一天是周日
    //    calendar.firstWeekday = 1;
    // 设置一周的第一天是周一
    calendar.firstWeekday = 2;
    
    // 获取本周的第一天
    NSDate *beginOfWeekDate = nil;
    NSTimeInterval interval01 = 0;
    BOOL ok01 = [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth startDate:&beginOfWeekDate interval:&interval01 forDate:date];
    // 获取本周最后一天
    if (ok01)
    {
        NSDate *endOfWeekDate = [beginOfWeekDate dateByAddingTimeInterval:(interval01 - 1)];
        // 格式化输出
        NSString *beginOfWeekStr = [dateFormatter stringFromDate:beginOfWeekDate];
        NSString *endOfWeekStr = [dateFormatter stringFromDate:endOfWeekDate];
        
        [dateArr addObject:beginOfWeekStr];
        [dateArr addObject:endOfWeekStr];
    }
    else
    {
        [dateArr addObject:@""];
        [dateArr addObject:@""];
    }
    
    return dateArr;
}

/**
 获取当月的天数
 
 @param dateString yyyy-MM/yyyy-MM-dd
 @return num
 */
+ (int)getAllDaysWithCalender:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = ([dateString componentsSeparatedByString:@"-"].count >= 3) ? @"yyyy-MM-dd" : @"yyyy-MM";
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSRange range = [calender rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    
    return (int)range.length;
}

/**
 获取今天的年月日
 
 @return yyyy-MM-dd
 */
+ (NSString *)getYearMonthDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSString *dateS = [dateFormatter stringFromDate:[NSDate date]];
    return dateS;
}

/**
 获取前/后一年(yyyy)
 获取前/后一月(yyyy-MM)
 获取前/后一日(yyyy-MM-dd)
 获取前/后一周(yyyy-MM-dd~yyyy-MM-dd)
 
 @param current 当前格式日期  这里传进来的格式是yyyy-MM-dd, 如果是周，则是yyyy-MM-dd~yyyy-MM-dd
 @param pickMode 类型 年，月，日 ，周
 @param isYester YES:上一个 NO:下一个
 @return 结果格式日期
 */
+ (NSString *)getYesterDateWithcurrent:(NSString *)current pickMode:(SCDateStyle)pickMode isYester:(BOOL)isYester
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *lastDateCom = [[NSDateComponents alloc] init];
    
    switch (pickMode)
    {
        case DateStyleShowYear:{
            dateFormatter.dateFormat = @"yyyy";
            if (isYester)
            {
                [lastDateCom setValue:-1 forComponent:NSCalendarUnitYear];
            }
            else
            {
                [lastDateCom setValue:1 forComponent:NSCalendarUnitYear];
            }
            NSDate *date = [dateFormatter dateFromString:current];
            NSDate *newDate = [calender dateByAddingComponents:lastDateCom toDate:date options:0];
            NSString *newDateStr = [dateFormatter stringFromDate:newDate];
            
            return newDateStr;
            break;
        }
        case DateStyleShowYearMonth:{
            dateFormatter.dateFormat = @"yyyy-MM";
            if (isYester)
            {
                [lastDateCom setValue:-1 forComponent:NSCalendarUnitMonth];
            }
            else
            {
                [lastDateCom setValue:1 forComponent:NSCalendarUnitMonth];
            }
            NSDate *date = [dateFormatter dateFromString:current];
            NSDate *newDate = [calender dateByAddingComponents:lastDateCom toDate:date options:0];
            NSString *newDateStr = [dateFormatter stringFromDate:newDate];
            
            return newDateStr;
            break;
        }
        case DateStyleShowYearMonthDay:{
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            if (isYester)
            {
                [lastDateCom setValue:-1 forComponent:NSCalendarUnitDay];
            }
            else
            {
                [lastDateCom setValue:1 forComponent:NSCalendarUnitDay];
            }
            NSDate *date = [dateFormatter dateFromString:current];
            NSDate *newDate = [calender dateByAddingComponents:lastDateCom toDate:date options:0];
            NSString *newDateStr = [dateFormatter stringFromDate:newDate];
            
            return newDateStr;
            break;
        }
        case DateStyleShowYearMonthWeek:{
            NSString *newDateStr = [self getTouchLastOrNextWeekWithdateArray:[current componentsSeparatedByString:@"~"] isYester:isYester];
            return newDateStr;
            break;
        }
        default:
            return nil;
            break;
    }
}

/**
 获取当前日期所有月所有的的周 及其 对应的开始结束日期
 
 @param dateStr yyyy-MM
 @return @[@"yyyy-MM-dd~yyyy-MM-dd", @"yyyy-MM-dd~yyyy-MM-dd"]
 */
+ (NSMutableArray<NSString *> *)getAllWeeksOfMonthWithdate:(NSString *)dateStr
{
    // 1.获取当月有多少周
    int weekOfMonth = [self getWeekNumOfMonth:dateStr];
    // 2.分别获取对应周的开始结束日期
    NSMutableArray<NSString *> *weekStrArray = [NSMutableArray new];
    NSString *weekStr = nil;
    for (int index = 1; index <= weekOfMonth; ++index)
    {
        weekStr = [self getLastOrNextWeekcurrentDate:dateStr weekNum:index];
        // 第一条记录，判断是否有跨月，如果跨月，则忽略掉
        if ((1 == index) && [self isRecordBetweenTwoMonthWithstr:weekStr])
        {
            // 过滤掉上月的第一条记录
            continue;
        }
        if (weekStr)
        {
            [weekStrArray addObject:weekStr];
        }
    }
    
    return weekStrArray;
}

/**
 获取指定年月的天数
 
 @param year 年
 @param month 月
 @return 天数
 */
+ (NSInteger)dayOfYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month)
    {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:{
            return 31;
        }
        case 4:
        case 6:
        case 9:
        case 11:{
            return 30;
        }
        case 2:{
            if (isrunNian) {
                return 29;
            } else {
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}

+ (NSString *)getFormatDateStrWithpickMode:(SCDateStyle)pickMode year:(int)year month:(int)month day:(int)day startyear:(int)startyear startmonth:(int)startmonth startday:(int)startday endyear:(int)endyear endmonth:(int)endmonth endday:(int)endday
{
    NSString *currentFormatDateStr = nil;
    switch (pickMode) {
        case DateStyleShowYear:{
            currentFormatDateStr = [NSString stringWithFormat:@"%04d", year];
            break;
        }
        case DateStyleShowYearMonth:{
            currentFormatDateStr = [NSString stringWithFormat:@"%04d-%02d", year, month];
            break;
        }
        case DateStyleShowYearMonthWeek:{
            currentFormatDateStr = [NSString stringWithFormat:@"%04d-%02d-%02d~%04d-%02d-%02d", startyear, startmonth, startday, endyear, endmonth, endday];
            break;
        }
        case DateStyleShowYearMonthDay:
        default:{
            currentFormatDateStr = [NSString stringWithFormat:@"%04d-%02d-%02d", year, month, day];
            break;
        }
    }
    
    return currentFormatDateStr;
}

#pragma mark - private method
/**
 切换到上一周/下一周
 
 @param dateArr [@"yyyy-MM-dd",@"yyyy-MM-dd"]
 @param isYester YES:上一周 NO:下一周
 @return @"yyyy-MM-dd~yyyy-MM-dd"
 */
+ (NSString *)getTouchLastOrNextWeekWithdateArray:(NSArray<NSString *> *)dateArr isYester:(BOOL)isYester
{
    NSString *dateString = isYester ? dateArr[0] : dateArr[1];
    NSMutableArray<NSString *> *array = [self getFirstDayFromWeek:dateString];
    // 获取当月所以天数
    int monthDay = [self getAllDaysWithCalender:dateString];
    if (array.count < 1)
    {
        return @"";
    }
    if (isYester)
    {
        NSString *firstDay = array[0];
        NSArray<NSString *> *strA = [firstDay componentsSeparatedByString:@"-"];
        // 判断是否是1号
        if ([strA[2] intValue] <= 1)
        {
            // 判断是否为1月
            if ([strA[1] intValue] <= 1)
            {
                int newYear = [strA[0] intValue] - 1;
                NSString *lastWeekDay = [NSString stringWithFormat:@"%04d-12-28", newYear];
                NSMutableArray<NSString *> *newArray = [self getFirstDayFromWeek:lastWeekDay];
                return [NSString stringWithFormat:@"%@~%@", newArray[0], newArray[1]];
            }
            else
            {
                int newMonth = [strA[1] intValue] - 1;
                NSString *lastWeekDay = [NSString stringWithFormat:@"%@-%02d-28", strA[0], newMonth];
                NSMutableArray<NSString *> *newArray = [self getFirstDayFromWeek:lastWeekDay];
                return [NSString stringWithFormat:@"%@~%@", newArray[0], newArray[1]];
            }
        }
        else
        {
            // 不是1号，可以直接获取到上一周
            int newDay = [strA[2] intValue] - 1;
            NSString *lastWeekDay = [NSString stringWithFormat:@"%@-%@-%02d", strA[0], strA[1], newDay];
            NSMutableArray<NSString *> *newArray = [self getFirstDayFromWeek:lastWeekDay];
            return [NSString stringWithFormat:@"%@~%@", newArray[0], newArray[1]];
        }
    }
    else
    {
        NSString *nextDay = array[1];
        NSArray<NSString *> *strA = [nextDay componentsSeparatedByString:@"-"];
        // 判断是否是当月最后一天
        if ([strA[2] intValue] >= monthDay)
        {
            // 判断是否是最后一个月
            if ([strA[1] intValue] >= 12)
            {
                int newYear = [strA[0] intValue] + 1;
                NSString *nextWeekDay = [NSString stringWithFormat:@"%04d-01-01", newYear];
                NSMutableArray<NSString *> *newArray = [self getFirstDayFromWeek:nextWeekDay];
                return [NSString stringWithFormat:@"%@~%@", newArray[0], newArray[1]];
            }
            else
            {
                int newMonth = [strA[1] intValue] + 1;
                NSString *nextWeekDay = [NSString stringWithFormat:@"%@-%02d-01", strA[0], newMonth];
                NSMutableArray<NSString *> *newArray = [self getFirstDayFromWeek:nextWeekDay];
                return [NSString stringWithFormat:@"%@~%@", newArray[0], newArray[1]];
            }
        }
        else
        {
            // 不是最后一天，可以直接获取到下一周
            int newDay = [strA[2] intValue] + 1;
            NSString *nextWeekDay = [NSString stringWithFormat:@"%@-%@-%02d", strA[0], strA[1], newDay];
            NSMutableArray<NSString *> *newArray = [self getFirstDayFromWeek:nextWeekDay];
            return [NSString stringWithFormat:@"%@~%@", newArray[0], newArray[1]];
        }
    }
}

/**
 获取当前日期对应的月有多少周
 
 @param dateStr yyyy-MM
 @return 多少周
 */
+ (int)getWeekNumOfMonth:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSString *dateFirst = [NSString stringWithFormat:@"%@-01", dateStr];
    NSDate *weekdate = [dateFormatter dateFromString:dateFirst];
    
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSRange range = [calender rangeOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:weekdate];
    
    return (int)range.length;
}

/**
 获取当前日期对应月第几周的开始~结束日期
 
 @param dateStr yyyy-MM
 @param weekNum 第几周(1...<=6)
 @return @"yyyy-MM-dd~yyyy-MM-dd"
 */
+ (NSString *)getLastOrNextWeekcurrentDate:(NSString *)dateStr weekNum:(int)weekNum
{
    NSString *selectDate = @"";
    switch (weekNum)
    {
        case 1:{
            NSString *str = [NSString stringWithFormat:@"%@-01", dateStr];
            NSMutableArray<NSString *> *array = [[self class] getFirstDayFromWeek:str];
            selectDate = [NSString stringWithFormat:@"%@~%@", array[0], array[1]];
            break;
        }
        case 2:{
            NSString *str = [NSString stringWithFormat:@"%@-08", dateStr];
            NSMutableArray<NSString *> *array = [[self class] getFirstDayFromWeek:str];
            selectDate = [NSString stringWithFormat:@"%@~%@", array[0], array[1]];
            break;
        }
        case 3:{
            NSString *str = [NSString stringWithFormat:@"%@-15", dateStr];
            NSMutableArray<NSString *> *array = [[self class] getFirstDayFromWeek:str];
            selectDate = [NSString stringWithFormat:@"%@~%@", array[0], array[1]];
            break;
        }
        case 4:{
            NSString *str = [NSString stringWithFormat:@"%@-22", dateStr];
            NSMutableArray<NSString *> *array = [[self class] getFirstDayFromWeek:str];
            selectDate = [NSString stringWithFormat:@"%@~%@", array[0], array[1]];
            break;
        }
        case 5:{
            int daynum = [self getAllDaysWithCalender:dateStr];
            NSString *str = daynum > 28 ? [NSString stringWithFormat:@"%@-29", dateStr] : [NSString stringWithFormat:@"%@-28", dateStr];
            NSMutableArray<NSString *> *array = [[self class] getFirstDayFromWeek:str];
            selectDate = [NSString stringWithFormat:@"%@~%@", array[0], array[1]];
            break;
        }
        case 6:{
            int daynum = [self getAllDaysWithCalender:dateStr];
            NSString *str = daynum > 30 ? [NSString stringWithFormat:@"%@-31", dateStr] : [NSString stringWithFormat:@"%@-30", dateStr];
            NSMutableArray<NSString *> *array = [[self class] getFirstDayFromWeek:str];
            selectDate = [NSString stringWithFormat:@"%@~%@", array[0], array[1]];
            break;
        }
        default:
            break;
    }
    return selectDate;
}

/**
 第一条记录，判断是否有跨月，如果跨月，则忽略掉
 
 @param str @"yyyy-MM-dd~yyyy-MM-dd"
 */
+ (BOOL)isRecordBetweenTwoMonthWithstr:(NSString *)str
{
    NSArray<NSString *> *dateStrArr = [str componentsSeparatedByString:@"~"];
    if (dateStrArr.count < 2)
    {
        return NO;
    }
    NSString *beginStr = dateStrArr[0];
    NSString *endStr = dateStrArr[1];
    NSString *beginday = nil;
    NSString *endday = nil;
    
    NSArray<NSString *> *strArr = [beginStr componentsSeparatedByString:@"-"];
    if (strArr.count < 3) return NO;
    beginday = strArr[2];
    
    strArr = [endStr componentsSeparatedByString:@"-"];
    if (strArr.count < 3) return NO;
    endday = strArr[2];
    
    if ([beginday intValue] > [endday intValue])
    {
        return YES;
    }
    return NO;
}

@end
