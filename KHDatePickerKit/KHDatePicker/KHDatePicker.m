//
//  KHDatePicker.m
//  KHDatePickerKit
//
//  Created by He Kerous on 2019/8/8.
//  Copyright © 2019 He Kerous. All rights reserved.
//

#import "KHDatePicker.h"

@interface KHDatePicker ()<UIPickerViewDelegate,UIPickerViewDataSource,UIGestureRecognizerDelegate>

// 日期记录数组
@property (nonatomic, strong) NSMutableArray<NSString *> *yearArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *monthArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *dayArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *weekArray;
@property (nonatomic, copy) NSString *dateFormatter;
@property (nonatomic, strong) NSMutableArray<NSString *> *weekResultArray;
// 记录位置
@property (nonatomic, assign) NSInteger yearIndex;
@property (nonatomic, assign) NSInteger monthIndex;
@property (nonatomic, assign) NSInteger dayIndex;
@property (nonatomic, assign) NSInteger weekIndex;
// UI
@property (nonatomic, strong) UIView *bakClearView;
@property (nonatomic, strong) UIView *whiteContentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *enterBtn;
@property (nonatomic, strong) UIImageView *centerBakView;
@property (nonatomic, strong) UIPickerView *datePicker;
//@property (nonatomic, strong) UIImageView *toplineIV;
//@property (nonatomic, strong) UIImageView *buttomlineIV;
// 初始化变量
@property (nonatomic, copy) void(^doneCompletion)(NSDate *date, NSString *dateStr);

/** 视图宽高 */
@property (nonatomic, assign) CGFloat viewWidth;
@property (nonatomic, assign) CGFloat viewHeight;

@end

@implementation KHDatePicker

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken = 0;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self commonInit];
}

- (void)defaultConfig
{
    _cancelTextColor = [UIColor colorWithRed:(0x33 / 255.0) green:(0x33 / 255.0) blue:(0x33 / 255.0) alpha:1.0f];
    _enterTextColor = [UIColor colorWithRed:(0x33 / 255.0) green:(0x33 / 255.0) blue:(0x33 / 255.0) alpha:1.0f];
    _datePickerColor = [UIColor colorWithRed:(0x66 / 255.0) green:(0x66 / 255.0) blue:(0x66 / 255.0) alpha:1.0f];
    _nowdate = [NSDate date];
    _minimumDate = [NSDate date:@"1900-01-01 00:00" WithFormat:@"yyyy-MM-dd HH:mm"];
    //    _maximumDate = [NSDate date:@"2099-12-31 23:59" WithFormat:@"yyyy-MM-dd HH:mm"];
    _maximumDate = [NSDate date];
    
    _yearArray = [NSMutableArray new];
    NSInteger minyear = [_minimumDate year];
    NSInteger maxyear = [_maximumDate year];
    for (NSInteger i = minyear; i <= maxyear; i++)
    {
        [_yearArray addObject:[NSString stringWithFormat:@"%ld",(long)i]];
    }
    _monthArray = [NSMutableArray new];
    for (int i = 1; i <= 12; i++)
    {
        [_monthArray addObject:[NSString stringWithFormat:@"%ld",(long)i]];
    }
    _dayArray = [NSMutableArray new];
    _weekArray = [NSMutableArray new];
}

- (void)commonInit
{
    _viewWidth = self.bounds.size.width;
    _viewHeight = self.bounds.size.height;
    
    [self defaultConfig];
    
    // UI
    _bakClearView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _viewWidth, _viewHeight)];
    _bakClearView.backgroundColor = [UIColor colorWithRed:(0 / 255.0) green:(0 / 255.0) blue:(0 / 255.0) alpha:0.3f];
    [self addSubview:_bakClearView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bakTapGesture:)];
    tap.delegate = self;
    [_bakClearView addGestureRecognizer:tap];
    
    _whiteContentView = [[UIView alloc] initWithFrame:CGRectMake(MAX(0, (_viewWidth - 300)/2), MAX(0, (_viewHeight - 240)/2), 300, 240)];
    _whiteContentView.backgroundColor = [UIColor colorWithRed:0xe8/255.0f green:0xe8/255.0f blue:0xe8/255.0f alpha:1.0f];
    _whiteContentView.layer.cornerRadius = 10;
    _whiteContentView.layer.masksToBounds = YES;
    [self addSubview:_whiteContentView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _whiteContentView.bounds.size.width, 40)];
    _titleLabel.textColor = [UIColor colorWithRed:0x33/255.0f green:0x33/255.0f blue:0x33/255.0f alpha:1.0f];
    _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.backgroundColor = [UIColor whiteColor];
    _titleLabel.text = @"选择时间";
    [_whiteContentView addSubview:_titleLabel];
    
    CGFloat btnWidth = (_whiteContentView.bounds.size.width - 1)/2;
    CGFloat btnHeight = 44;
    _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelBtn.frame = CGRectMake(0, MAX(0, _whiteContentView.bounds.size.height - btnHeight), btnWidth, btnHeight);
    [_cancelBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:@"取消" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18], NSForegroundColorAttributeName:_cancelTextColor}] forState:UIControlStateNormal];
    _cancelBtn.backgroundColor = [UIColor whiteColor];
    [_cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_whiteContentView addSubview:_cancelBtn];
    
    _enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _enterBtn.frame = CGRectMake(btnWidth+1, _cancelBtn.frame.origin.y, btnWidth, btnHeight);
    [_enterBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:@"确定" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18], NSForegroundColorAttributeName:_enterTextColor}] forState:UIControlStateNormal];
    _enterBtn.backgroundColor = [UIColor whiteColor];
    [_enterBtn addTarget:self action:@selector(enterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_whiteContentView addSubview:_enterBtn];
    
    _centerBakView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), _whiteContentView.bounds.size.width, MAX(1, CGRectGetMinY(_enterBtn.frame) - CGRectGetMaxY(_titleLabel.frame) - 1))];
    _centerBakView.backgroundColor = [UIColor whiteColor];
    [_whiteContentView addSubview:_centerBakView];
    
    _datePicker = [[UIPickerView alloc] initWithFrame:_centerBakView.frame];
    _datePicker.delegate = self;
    _datePicker.dataSource = self;
    [_whiteContentView addSubview:_datePicker];
    for (UIView *subView in [_datePicker subviews])
    {
        if ([subView isKindOfClass:[UIImageView class]])
        {
            subView.hidden = YES;
        }
    }
    
    // 添加两条线条
    //    _toplineIV = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, MAX(10, _datePicker.bounds.size.width - 30 * 2), 2)];
    //    _toplineIV.center = CGPointMake(_toplineIV.center.x, _datePicker.bounds.size.height/3+PICKER_LINE_FIX_HEIGHT);
    //    _toplineIV.backgroundColor = [UIColor colorWithRed:(0xd7 / 255.0) green:(0xd7 / 255.0) blue:(0xd7 / 255.0) alpha:1.0f];
    //    [_datePicker addSubview:_toplineIV];
    //    _buttomlineIV = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, MAX(10, _datePicker.bounds.size.width - 30 * 2), 2)];
    //    _buttomlineIV.center = CGPointMake(_toplineIV.center.x, _datePicker.bounds.size.height*2/3-PICKER_LINE_FIX_HEIGHT);
    //    _buttomlineIV.backgroundColor = [UIColor colorWithRed:(0xd7 / 255.0) green:(0xd7 / 255.0) blue:(0xd7 / 255.0) alpha:1.0f];
    //    [_datePicker addSubview:_buttomlineIV];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ((_viewWidth != self.bounds.size.width) ||
        (_viewHeight != self.bounds.size.height))
    {
        _viewWidth = self.bounds.size.width;
        _viewHeight = self.bounds.size.height;
        CGFloat btnWidth = (_whiteContentView.bounds.size.width - 1)/2;
        CGFloat btnHeight = 44;
        
        _bakClearView.frame = CGRectMake(0, 0, _viewWidth, _viewHeight);
        _whiteContentView.frame = CGRectMake(MAX(0, (_viewWidth - 300)/2), MAX(0, (_viewHeight - 240)/2), 300, 240);
        _titleLabel.frame = CGRectMake(0, 0, _whiteContentView.bounds.size.width, 40);
        _cancelBtn.frame = CGRectMake(0, MAX(0, _whiteContentView.bounds.size.height - btnHeight), btnWidth, btnHeight);
        _enterBtn.frame = CGRectMake(btnWidth+1, _cancelBtn.frame.origin.y, btnWidth, btnHeight);
        _centerBakView.frame = CGRectMake(0, CGRectGetMaxY(_titleLabel.frame), _whiteContentView.bounds.size.width, MAX(1, CGRectGetMinY(_enterBtn.frame) - CGRectGetMaxY(_titleLabel.frame) - 1));
        _datePicker.frame = _centerBakView.frame;
        //        _toplineIV.frame = CGRectMake(30, 0, MAX(10, _datePicker.bounds.size.width - 30 * 2), 2);
        //        _toplineIV.center = CGPointMake(_toplineIV.center.x, _datePicker.bounds.size.height/3+PICKER_LINE_FIX_HEIGHT);
        //        _buttomlineIV.frame = CGRectMake(30, 0, MAX(10, _datePicker.bounds.size.width - 30 * 2), 2);
        //        _buttomlineIV.center = CGPointMake(_toplineIV.center.x, _datePicker.bounds.size.height*2/3-PICKER_LINE_FIX_HEIGHT);
    }
}

- (void)bakTapGesture:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self dismiss];
    }
}

- (void)cancelBtnClick:(UIButton *)sender
{
    [self dismiss];
}

- (void)enterBtnClick:(UIButton *)sender
{
    switch (_pickerStyle) {
        case DateStyleShowYearMonthWeek:
        {
            if (_weekIndex < _weekResultArray.count)
            {
                NSString *dateStr = _weekResultArray[_weekIndex];
                if (_doneCompletion) {
                    _doneCompletion(_nowdate, dateStr);
                }
                
                [self dismiss];
            }
            break;
        }
        case DateStyleShowYear:
        case DateStyleShowYearMonth:
        case DateStyleShowYearMonthDay:
        default:{
            if (_doneCompletion) {
                _doneCompletion(_nowdate, [_nowdate stringWithFormat:_dateFormatter]);
            }
            
            [self dismiss];
            break;
        }
    }
}

+ (void)showWithDateStyle:(SCDateStyle)pickerStyle nowDate:(NSDate *)nowDate minimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate completion:(void(^)(NSDate *date, NSString *dateStr))completion
{
    [[[self class] shareInstance] showViewWithDateStyle:pickerStyle nowDate:nowDate minimumDate:minimumDate maximumDate:maximumDate completion:completion];
}

- (void)showViewWithDateStyle:(SCDateStyle)pickerStyle nowDate:(NSDate *)nowDate minimumDate:(NSDate *)minimumDate maximumDate:(NSDate *)maximumDate completion:(void(^)(NSDate *date, NSString *dateStr))completion
{
    self.nowdate = nowDate ? : [NSDate date];
    self.minimumDate = minimumDate ? : [NSDate date:@"1900-01-01 00:00" WithFormat:@"yyyy-MM-dd HH:mm"];
    self.maximumDate = maximumDate ? : [NSDate date];
    self.doneCompletion = completion;
    self.pickerStyle = pickerStyle;
    
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)dismiss
{
    [self removeFromSuperview];
}

#pragma mark - setter属性
- (void)setCancelTextColor:(UIColor *)cancelTextColor
{
    _cancelTextColor = cancelTextColor;
    if (_cancelTextColor)
    {
        [_cancelBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:@"取消" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18], NSForegroundColorAttributeName:_cancelTextColor}] forState:UIControlStateNormal];
    }
}

- (void)setEnterTextColor:(UIColor *)enterTextColor
{
    _enterTextColor = enterTextColor;
    if (_enterTextColor)
    {
        [_enterBtn setAttributedTitle:[[NSAttributedString alloc] initWithString:@"确定" attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18], NSForegroundColorAttributeName:_enterTextColor}] forState:UIControlStateNormal];
    }
}

- (void)setDatePickerColor:(UIColor *)datePickerColor
{
    _datePickerColor = datePickerColor;
    [self.datePicker reloadAllComponents];
}

- (void)setPickerStyle:(SCDateStyle)pickerStyle
{
    _pickerStyle = pickerStyle;
    switch (pickerStyle)
    {
        case DateStyleShowYear:{
            _dateFormatter = @"yyyy";
            break;
        }
        case DateStyleShowYearMonth:{
            _dateFormatter = @"yyyy-MM";
            break;
        }
        case DateStyleShowYearMonthDay:{
            _dateFormatter = @"yyyy-MM-dd";
            break;
        }
        case DateStyleShowYearMonthWeek:{
            _dateFormatter = @"yyyy-MM-dd";
            break;
        }
        default:
            _dateFormatter = @"yyyy-MM-dd";
            break;
    }
    
    if (!_nowdate) _nowdate = [NSDate date];
    [self scrollToDate:_nowdate animated:YES];
}

#pragma mark - UIPickerViewDataSource(数据源)
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch (_pickerStyle)
    {
        case DateStyleShowYear:{
            return 1;
            break;
        }
        case DateStyleShowYearMonth:{
            return 2;
            break;
        }
        case DateStyleShowYearMonthDay:{
            return 3;
            break;
        }
        case DateStyleShowYearMonthWeek:{
            return 3;
            break;
        }
        default:
            return 0;
            break;
    }
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self getNumberOfRowsInComponent:component];
}

#pragma mark - UIPickerViewDelegate(视图代理)
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    NSInteger columns = [self numberOfComponentsInPickerView:self.datePicker];
    if (0 == columns)
    {
        return _datePicker.bounds.size.width;
    }
    if (_pickerStyle == DateStyleShowYearMonth)
    {
        return (_datePicker.bounds.size.width - 80 * 2)/columns;
    }
    return (_datePicker.bounds.size.width - 20 * 2)/columns;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel)
    {
        customLabel = [[UILabel alloc] init];
        customLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        customLabel.textAlignment = NSTextAlignmentCenter;
    }
    NSString *title;
    switch (_pickerStyle)
    {
        case DateStyleShowYear:{
            if (component==0){
                title = _yearArray[row];
            }
            break;
        }
        case DateStyleShowYearMonth:{
            if (component==0){
                title = _yearArray[row];
            }
            if (component==1){
                title = _monthArray[row];
            }
            break;
        }
        case DateStyleShowYearMonthDay:{
            if (component==0) {
                title = _yearArray[row];
            }
            if (component==1) {
                title = _monthArray[row];
            }
            if (component==2) {
                title = _dayArray[row];
            }
            break;
        }
        case DateStyleShowYearMonthWeek:{
            if (component == 0) {
                title = _yearArray[row];
            }
            if (component == 1) {
                title = _monthArray[row];
            }
            if (component == 2) {
                // 周数组
                title = _weekArray[row];
            }
            break;
        }
        default:
            title = @"";
            break;
    }
    
    customLabel.text = title;
    customLabel.textColor = _datePickerColor;
    return customLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *dateStr = nil;
    switch (_pickerStyle)
    {
        case DateStyleShowYear:{
            if (component == 0)
            {
                _yearIndex = row;
                dateStr = [NSString stringWithFormat:@"%@",_yearArray[_yearIndex]];
            }
            break;
        }
        case DateStyleShowYearMonth:{
            if (component == 0)
            {
                _yearIndex = row;
            }
            if (component == 1)
            {
                _monthIndex = row;
            }
            dateStr = [NSString stringWithFormat:@"%@-%@",_yearArray[_yearIndex],_monthArray[_monthIndex]];
            break;
        }
        case DateStyleShowYearMonthDay:{
            if (component == 0)
            {
                _yearIndex = row;
            }
            if (component == 1)
            {
                _monthIndex = row;
            }
            if (component == 2)
            {
                _dayIndex = row;
            }
            if (component == 0 || component == 1)
            {
                [self reloadDaysOfMonthDataWithyear:[_yearArray[_yearIndex] integerValue] month:[_monthArray[_monthIndex] integerValue]];
                [self.datePicker reloadAllComponents];
                if (_dayIndex > (_dayArray.count-1))
                {
                    _dayIndex = _dayArray.count-1;
                }
            }
            dateStr = [NSString stringWithFormat:@"%@-%@-%@", _yearArray[_yearIndex], _monthArray[_monthIndex], _dayArray[_dayIndex]];
            break;
        }
        case DateStyleShowYearMonthWeek:{
            if (component == 0)
            {
                _yearIndex = row;
            }
            if (component == 1)
            {
                _monthIndex = row;
            }
            if (component == 2)
            {
                _weekIndex = row;
            }
            if (component == 0 || component == 1)
            {
                [self reloadWeeksOfMonthDataWithyear:[_yearArray[_yearIndex] integerValue] month:[_monthArray[_monthIndex] integerValue]];
                [self.datePicker reloadAllComponents];
                if (_weekIndex > (_weekArray.count-1))
                {
                    _weekIndex = _weekArray.count-1;
                }
            }
            NSString *text = _weekArray[_weekIndex];
            NSArray<NSString *> *textArr = [text componentsSeparatedByString:@"~"];
            if (textArr.count < 2)
            {
                dateStr = [NSString stringWithFormat:@"%@-%@-01", _yearArray[_yearIndex], _monthArray[_monthIndex]];
            }
            else
            {
                dateStr = [NSString stringWithFormat:@"%@-%@-%02d", _yearArray[_yearIndex], _monthArray[_monthIndex], [textArr[0] intValue]];
            }
            break;
        }
        default:
            break;
    }
    _nowdate = [[NSDate date:dateStr WithFormat:_dateFormatter] dateWithFormatter:_dateFormatter];
    
    if ([_nowdate compare:_minimumDate] == NSOrderedAscending)
    {
        _nowdate = _minimumDate;
        [self scrollToDate:_nowdate animated:NO];
    }
    else if ([_nowdate compare:_maximumDate] == NSOrderedDescending)
    {
        _nowdate = _maximumDate;
        [self scrollToDate:_nowdate animated:NO];
    }
}

#pragma mark - private method
- (NSInteger)getNumberOfRowsInComponent:(NSInteger)component
{
    NSInteger numOfRows = 0;
    switch (_pickerStyle)
    {
        case DateStyleShowYear:{
            if (0 == component) numOfRows = _yearArray.count;
            break;
        }
        case DateStyleShowYearMonth:{
            if (0 == component) numOfRows = _yearArray.count;
            if (1 == component) numOfRows = _monthArray.count;
            break;
        }
        case DateStyleShowYearMonthDay:{
            if (0 == component) numOfRows = _yearArray.count;
            if (1 == component) numOfRows = _monthArray.count;
            if (2 == component) numOfRows = [KHCalendarUtil dayOfYear:[_yearArray[_yearIndex] intValue] andMonth:[_monthArray[_monthIndex] intValue]];
            break;
        }
        case DateStyleShowYearMonthWeek:{
            if (0 == component) numOfRows = _yearArray.count;
            if (1 == component) numOfRows = _monthArray.count;
            if (2 == component)
            {
                NSMutableArray<NSString *> *weekArray = [KHCalendarUtil getAllWeeksOfMonthWithdate:[NSString stringWithFormat:@"%04d-%02d", [_yearArray[_yearIndex] intValue], [_monthArray[_monthIndex] intValue]]];
                numOfRows = weekArray.count;
            }
            break;
        }
        default:
            numOfRows = 0;
            break;
    }
    return numOfRows;
}

// 更新天数组数据
- (void)reloadDaysOfMonthDataWithyear:(NSInteger)year month:(NSInteger)month
{
    NSInteger daysOfMonth = [KHCalendarUtil dayOfYear:year andMonth:month];
    
    [_dayArray removeAllObjects];
    for (int i = 1; i <= daysOfMonth; i++)
    {
        [_dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
}

// 更新周数组数据
- (void)reloadWeeksOfMonthDataWithyear:(NSInteger)year month:(NSInteger)month
{
    [_weekArray removeAllObjects];
    
    NSMutableArray<NSString *> *weekArray = [KHCalendarUtil getAllWeeksOfMonthWithdate:[NSString stringWithFormat:@"%04ld-%02ld", (long)year, (long)month]];
    self.weekResultArray = weekArray;
    NSArray<NSString *> *days = nil;
    NSString *beginDayStr = nil;
    NSString *endDayStr = nil;
    NSArray<NSString *> *beginDayUnits = nil;
    NSArray<NSString *> *endDayUnits = nil;
    NSString *showText = nil;
    for (NSString *weekStr in weekArray)
    {
        days = [weekStr componentsSeparatedByString:@"~"];
        NSAssert(days.count >= 2, @"weekStr format error !");
        beginDayStr = days[0];
        endDayStr = days[1];
        beginDayUnits = [beginDayStr componentsSeparatedByString:@"-"];
        endDayUnits = [endDayStr componentsSeparatedByString:@"-"];
        NSAssert(beginDayUnits.count >= 3, @"beginDayStr format error !");
        NSAssert(endDayUnits.count >= 3, @"endDayStr format error !");
        
        showText = [NSString stringWithFormat:@"%02d~%02d", [beginDayUnits[2] intValue], [endDayUnits[2] intValue]];
        [_weekArray addObject:showText];
    }
}

// 滚动到指定的时间位置
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    // 更新显示数据
    if (_pickerStyle == DateStyleShowYearMonthDay)
    {
        [self reloadDaysOfMonthDataWithyear:date.year month:date.month];
    }
    else if (_pickerStyle == DateStyleShowYearMonthWeek)
    {
        [self reloadWeeksOfMonthDataWithyear:date.year month:date.month];
    }
    
    // 滑动到指定位置
    _yearIndex = date.year-_minimumDate.year;
    _monthIndex = date.month-1;
    _dayIndex = date.day-1;
    _weekIndex = [self getIndexOfWeekWithday:(int)date.day weekShowArray:_weekArray];
    
    NSArray *indexArray;
    switch (_pickerStyle)
    {
        case DateStyleShowYear:{
            indexArray = @[@(_yearIndex)];
            break;
        }
        case DateStyleShowYearMonth:{
            indexArray = @[@(_yearIndex),@(_monthIndex)];
            break;
        }
        case DateStyleShowYearMonthDay:{
            indexArray = @[@(_yearIndex),@(_monthIndex),@(_dayIndex)];
            break;
        }
        case DateStyleShowYearMonthWeek:{
            indexArray = @[@(_yearIndex),@(_monthIndex),@(_weekIndex)];
            break;
        }
        default:
            break;
    }
    [self.datePicker reloadAllComponents];
    
    for (int i = 0; i < indexArray.count; i++)
    {
        [self.datePicker selectRow:[indexArray[i] integerValue] inComponent:i animated:animated];
    }
}

/**
 判断指定日期是哪个周
 
 @param day day
 @param weekShowArray [@"01~07", @"08~15"]
 @return 下标
 */
- (int)getIndexOfWeekWithday:(int)day weekShowArray:(NSArray<NSString *> *)weekShowArray
{
    int indexOfArray = 0;
    NSString *showText = nil;
    NSArray<NSString *> *showTextArr = nil;
    NSString *beginday = nil;
    NSString *endday = nil;
    for (int i = 0; i < weekShowArray.count; ++i)
    {
        showText = weekShowArray[i];
        showTextArr = [showText componentsSeparatedByString:@"~"];
        if (showTextArr.count < 2) continue;
        beginday = showTextArr[0];
        endday = showTextArr[1];
        
        if (day >= [beginday intValue] && day <= [endday intValue])
        {
            indexOfArray = i;
            break;
        }
    }
    
    return indexOfArray;
}

@end
