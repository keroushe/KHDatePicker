//
//  ViewController.m
//  KHDatePickerDemo
//
//  Created by He Kerous on 2019/8/9.
//  Copyright © 2019 He Kerous. All rights reserved.
//

#import "ViewController.h"
#import <KHDatePickerKit/KHDatePickerKit.h>

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UIButton *yearBtn;
@property (nonatomic, weak) IBOutlet UIButton *monthBtn;
@property (nonatomic, weak) IBOutlet UIButton *dayBtn;
@property (nonatomic, weak) IBOutlet UIButton *weekBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)yearChooseBtn:(UIButton *)sender
{
    [KHDatePicker showWithDateStyle:DateStyleShowYear nowDate:[NSDate date] minimumDate:nil maximumDate:[NSDate date] completion:^(NSDate *date, NSString *dateStr) {
        
        [sender setTitle:dateStr forState:UIControlStateNormal];
    }];
}

- (IBAction)monthChooseBtn:(UIButton *)sender
{
    [KHDatePicker showWithDateStyle:DateStyleShowYearMonth nowDate:[NSDate date] minimumDate:nil maximumDate:[NSDate date] completion:^(NSDate *date, NSString *dateStr) {
        
        [sender setTitle:dateStr forState:UIControlStateNormal];
    }];
}

- (IBAction)dayChooseBtn:(UIButton *)sender
{
    [KHDatePicker showWithDateStyle:DateStyleShowYearMonthDay nowDate:[NSDate date] minimumDate:nil maximumDate:[NSDate date] completion:^(NSDate *date, NSString *dateStr) {
        
        [sender setTitle:dateStr forState:UIControlStateNormal];
    }];
}

- (IBAction)weekChooseBtn:(UIButton *)sender
{
    [KHDatePicker showWithDateStyle:DateStyleShowYearMonthWeek nowDate:nil minimumDate:nil maximumDate:nil completion:^(NSDate *date, NSString *dateStr) {
        
        [sender setTitle:dateStr forState:UIControlStateNormal];
    }];
}

@end
