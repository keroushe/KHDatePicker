//
//  KHDatePicker.h
//  KHDatePickerKit
//
//  Created by He Kerous on 2019/8/8.
//  Copyright © 2019 He Kerous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+Extension.h"
#import "KHCalendarUtil.h"

/**
 日期选择控件
 年/年月/年月日/年月周
 */
@interface KHDatePicker : UIView

// 取消按钮颜色
@property (nonatomic, strong) UIColor *cancelTextColor;
// 确定按钮颜色
@property (nonatomic, strong) UIColor *enterTextColor;
// 滚轮日期颜色(默认黑色)
@property (nonatomic, strong) UIColor *datePickerColor;
// 最小/最大日期
// 最小日期，默认为1900年
@property (nonatomic, strong) NSDate *minimumDate;
// 最大日期，默认为2099年
@property (nonatomic, strong) NSDate *maximumDate;
// 当前时间
@property (nonatomic, strong) NSDate *nowdate;
// 日期模式
@property (nonatomic, assign) SCDateStyle pickerStyle;

+ (instancetype)shareInstance;

/**
 获取前/后一年(yyyy)
 获取前/后一月(yyyy-MM)
 获取前/后一日(yyyy-MM-dd)
 获取前/后一周(yyyy-MM-dd~yyyy-MM-dd)
 */
+ (void)showWithDateStyle:(SCDateStyle)pickerStyle nowDate:(NSDate *)nowDate minimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate completion:(void(^)(NSDate *date, NSString *dateStr))completion;

@end
