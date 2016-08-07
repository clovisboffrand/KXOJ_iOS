//
//  AlarmViewController.m
//  KXOJ
//
//  Created by admin_user on 8/7/16.
//  Copyright © 2016 RadioServersLLC. All rights reserved.
//

#import "AlarmViewController.h"
#import "ClockViewController.h"
#import "header.h"

@interface AlarmViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
{
    IBOutlet UILabel *lblCurrentTime;
    IBOutlet UILabel *lblCurrentPeriod;
    
    IBOutlet UITextField *tfWakeUpHour;
    IBOutlet UITextField *tfWakeUpMin;
    IBOutlet UITextField *tfWakeUpPeriod;
    
    IBOutlet UIButton *btnSetAlarm;
}

@end

@implementation AlarmViewController
{
    NSInteger isAm;
    NSInteger wakeupHour;
    NSInteger wakeupMin;
    NSInteger wakeupAp;
    NSTimer *myTicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self runTimer];
    [self showActivity];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    int wakeUpHour, wakeUpMin;
    NSString *wakeUpTime = [[LocalStorage shared] defaultForKey:@"wakeup"];
    if (wakeUpTime) {
        [btnSetAlarm setTitle:@"Cancel Alarm" forState:UIControlStateNormal];
        
        NSArray *components = [wakeUpTime componentsSeparatedByString:@":"];
        wakeUpHour = [components[0] intValue];
        wakeUpMin = [components[1] intValue];
    } else {
        [btnSetAlarm setTitle:@"Set Alarm" forState:UIControlStateNormal];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        NSString *currentTime = [formatter stringFromDate:[NSDate date]];
        NSArray *components = [currentTime componentsSeparatedByString:@":"];
        wakeUpHour = [components[0] intValue];
        wakeUpMin = [components[1] intValue];
        if (wakeUpMin == 59) {
            wakeUpMin = 0;
            wakeUpHour += 1;
            if (wakeUpHour == 24) {
                wakeUpHour = 0;
            }
        } else {
            wakeUpMin += 1;
        }
    }
    BOOL isPM = NO;
    if (wakeUpHour >= 12) {
        isPM = YES;
        wakeUpHour -= 12;
    }
    if (wakeUpHour == 0) {
        wakeUpHour = 12;
    }
    tfWakeUpHour.text = wakeUpHour < 10 ? [NSString stringWithFormat:@"0%i", wakeUpHour] : [@(wakeUpHour) stringValue];
    tfWakeUpMin.text = wakeUpMin < 10 ? [NSString stringWithFormat:@"0%i", wakeUpMin] : [@(wakeUpMin) stringValue];
    tfWakeUpPeriod.text = isPM ? @"PM" : @"AM";
    
    UIPickerView *hourPicker = [[UIPickerView alloc] init];
    hourPicker.tag = 100;
    hourPicker.delegate = self;
    hourPicker.dataSource = self;
    tfWakeUpHour.inputView = hourPicker;
    
    UIPickerView *minPicker = [[UIPickerView alloc] init];
    minPicker.tag = 101;
    minPicker.delegate = self;
    minPicker.dataSource = self;
    tfWakeUpMin.inputView = minPicker;
    
    UIPickerView *periodPicker = [[UIPickerView alloc] init];
    periodPicker.tag = 102;
    periodPicker.delegate = self;
    periodPicker.dataSource = self;
    tfWakeUpPeriod.inputView = periodPicker;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - PickerView Delegate / DataSource Methods

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 100) {
        return 12;
    } else if (pickerView.tag == 101) {
        return 60;
    } else {
        return 2;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView.tag == 100) {
        return [@(row + 1) stringValue];
    } else if (pickerView.tag == 101) {
        return [@(row) stringValue];
    } else {
        return row == 0 ? @"AM" : @"PM";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == 100) {
        tfWakeUpHour.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    } else if (pickerView.tag == 101) {
        tfWakeUpMin.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    } else {
        tfWakeUpPeriod.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    }
    [tfWakeUpHour resignFirstResponder];
    [tfWakeUpMin resignFirstResponder];
    [tfWakeUpPeriod resignFirstResponder];
}

#pragma mark - Run Timer

- (void)runTimer {
    UIBackgroundTaskIdentifier bgTask;
    UIApplication *app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    myTicker = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(showActivity) userInfo:nil repeats:YES];
}

#pragma mark - Show Activity

- (void)showActivity {
    // Show current time.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:a"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    NSArray *components = [currentTime componentsSeparatedByString:@":"];
    lblCurrentTime.text = [NSString stringWithFormat:@"%@:%@", components[0], components[1]];
    lblCurrentPeriod.text = components[2];
    
    // Should update time of Clock Page.
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTime" object:self];
    
    // Check wake up time.
    NSString *wakeUpTime = [[LocalStorage shared] defaultForKey:@"wakeup"];
    if (wakeUpTime) {
        [formatter setDateFormat:@"HH:mm"];
        currentTime = [formatter stringFromDate:[NSDate date]];
        if ([wakeUpTime isEqualToString:currentTime]) {
            [[LocalStorage shared] removeDefaultForKey:@"wakeup"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didWakeup" object:self];
        }
    }
}

#pragma mark - Button Action Methods

- (IBAction)didTapSetAlarm:(id)sender {
    if ([btnSetAlarm.titleLabel.text isEqualToString:@"Set Alarm"]) {
        [self setAlarm];
    } else {
        [self cancelAlarm];
    }
}

#pragma mark - Setup/Cancel Alarm

- (void)cancelAlarm {
    [[LocalStorage shared] removeDefaultForKey:@"wakeup"];
    [btnSetAlarm setTitle:@"Set Alarm" forState:UIControlStateNormal];
}

- (void)setAlarm {
    int wakeUpHour = [tfWakeUpHour.text intValue];
    int wakeUpMin = [tfWakeUpMin.text intValue];
    BOOL isPM = [tfWakeUpPeriod.text isEqualToString:@"PM"];
    if (wakeUpHour == 12) {
        if (!isPM) {
            wakeUpHour = 0;
        }
    } else if (isPM) {
        wakeUpHour += 12;
    }
    NSString *hour = wakeUpHour < 10 ? [NSString stringWithFormat:@"0%i", wakeUpHour] : [@(wakeUpHour) stringValue];
    NSString *min = wakeUpMin < 10 ? [NSString stringWithFormat:@"0%i", wakeUpMin] : [@(wakeUpMin) stringValue];
    [[LocalStorage shared] setDefault:[NSString stringWithFormat:@"%@:%@", hour, min] forKey:@"wakeup"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setAlarm" object:self];
    [self goClock];
}

#pragma mark - Go to Clock Page

- (void)goClock {
    ClockViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClockViewController"];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end

