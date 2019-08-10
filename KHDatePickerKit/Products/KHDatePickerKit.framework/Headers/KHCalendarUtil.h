//
//  KHCalendarUtil.h
//  KHDatePickerKit
//
//  Created by He Kerous on 2019/8/8.
//  Copyright © 2019 He Kerous. All rights reserved.
//

#import <Foundation/Foundation.h>

// 日期选择类型
typedef enum
{
    DateStyleShowYear                 = 0, // 年
    DateStyleShowYearMonth            = 1, // 年月
    DateStyleShowYearMonthWeek        = 2, // 年月周
    DateStyleShowYearMonthDay         = 3, // 年月日
}SCDateStyle;

/**
 日期相关函数
 */
@interface KHCalendarUtil : NSObject

/**
 计算出当前日期对应周的开始结束时间
 
 @param dateString yyyy-MM-dd
 @return [@"yyyy-MM-dd", @"yyyy-MM-dd"]
 */
+ (NSMutableArray<NSString *> *)getFirstDayFromWeek:(NSString *)dateString;

/**
 获取当月的天数
 
 @param dateString yyyy-MM
 @return num
 */
+ (int)getAllDaysWithCalender:(NSString *)dateString;

/**
 获取今天的年月日
 
 @return yyyy-MM-dd
 */
+ (NSString *)getYearMonthDay;

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
+ (NSString *)getYesterDateWithcurrent:(NSString *)current pickMode:(SCDateStyle)pickMode isYester:(BOOL)isYester;

/**
 获取当前日期所有月所有的的周 及其 对应的开始结束日期
 
 @param dateStr yyyy-MM
 @return @[@"yyyy-MM-dd~yyyy-MM-dd", @"yyyy-MM-dd~yyyy-MM-dd" ...]
 */
+ (NSMutableArray<NSString *> *)getAllWeeksOfMonthWithdate:(NSString *)dateStr;

/**
 获取指定年月的天数
 
 @param year 年
 @param month 月
 @return 天数
 */
+ (NSInteger)dayOfYear:(NSInteger)year andMonth:(NSInteger)month;

/**
 将指定年月日转化为可识别格式
 年(yyyy)
 月(yyyy-MM)
 日(yyyy-MM-dd)
 周(yyyy-MM-dd~yyyy-MM-dd)
 
 @param pickMode pickMode @see SCDateStyle
 @param year year
 @param month month
 @param day day
 @param startyear startyear
 @param startmonth startmonth
 @param startday startday
 @param endyear endyear
 @param endmonth endmonth
 @param endday endday
 @return return value description
 */
+ (NSString *)getFormatDateStrWithpickMode:(SCDateStyle)pickMode year:(int)year month:(int)month day:(int)day startyear:(int)startyear startmonth:(int)startmonth startday:(int)startday endyear:(int)endyear endmonth:(int)endmonth endday:(int)endday;

@end
