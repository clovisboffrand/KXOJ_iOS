//
//  AlarmViewController.m
//  WJRS
//
//  Created by admin_user on 3/7/16.
//
//

#import "AlarmViewController.h"
#import "ClockViewController.h"
#import "header.h"

@interface AlarmViewController () <UIPickerViewDataSource, UIPickerViewDelegate> {
    IBOutlet UILabel *lblhour1;
    IBOutlet UILabel *lblhour2;
    IBOutlet UILabel *lblmin1;
    IBOutlet UILabel *lblmin2;
    IBOutlet UIButton *btnSet;
    IBOutlet UIPickerView *datePicker;
}

@end

@implementation AlarmViewController {
    NSDateFormatter *dateFormatter;
    NSInteger isAm;
    NSInteger islock;
    NSInteger wakeupHour;
    NSInteger wakeupMin;
    NSInteger wakeupAp;
    NSTimer *myTicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    
    [self showActivity];
    datePicker.frame = CGRectMake(datePicker.frame.origin.x, datePicker.frame.origin.y, datePicker.frame.size.width, 120);
    [self runTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *wakeuptime = [prefs objectForKey:@"wakeup"];
    
    if ((![wakeuptime length]) || ([wakeuptime isEqualToString:@"00:00"])) {
        [btnSet setTitle:@"Set Alarm" forState:UIControlStateNormal];
        int currentmin = [[NSString stringWithFormat:@"%@%@", lblmin1.text, lblmin2.text] intValue];
        int currenhour = [[NSString stringWithFormat:@"%@%@", lblhour1.text, lblhour2.text] intValue];
        
        if (currentmin < 59) {
            currentmin ++;
        } else {
            currentmin = 0;
            currenhour += 1;
        }
        
        if (currenhour == 12) {
            if (isAm) {
                currenhour = 24;
            } else {
                currenhour=12;
            }
        } else if (!isAm) {
            currenhour += 12;
        }
        
        wakeuptime = [NSString stringWithFormat:@"%i:%i", currenhour, currentmin];
    } else {
        [btnSet setTitle:@"Cancel Alarm" forState:UIControlStateNormal];
    }
    
    NSArray *timearray = [wakeuptime componentsSeparatedByString:@":"];
    int wakehour = [[timearray objectAtIndex:0] intValue];
    int wakemin = [[timearray objectAtIndex:1] intValue];
    [datePicker selectRow:wakemin inComponent:1 animated:YES];
    
    if (wakehour < 12) {
        [datePicker selectRow:wakehour-1 inComponent:0 animated:YES];
        [datePicker selectRow:0 inComponent:2 animated:YES];
    } else if (wakehour == 12) {
        [datePicker selectRow:11 inComponent:0 animated:YES];
        [datePicker selectRow:1 inComponent:2 animated:YES];
    } else if (wakehour < 24) {
        [datePicker selectRow:wakehour-12-1 inComponent:0 animated:YES];
        [datePicker selectRow:1 inComponent:2 animated:YES];
    } else if (wakehour == 24) {
        [datePicker selectRow:11 inComponent:0 animated:YES];
        [datePicker selectRow:0 inComponent:2 animated:YES];
    } else {
        [datePicker selectRow:wakehour-24-1 inComponent:0 animated:YES];
        if (wakehour < 36)
            [datePicker selectRow:0 inComponent:2 animated:YES];
        else {
            [datePicker selectRow:1 inComponent:2 animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    NSDate *date = [NSDate date];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"hh:mm:a"];
    
    NSString *day = [dateFormatter stringFromDate:date];
    NSArray *chunk = [day componentsSeparatedByString:@":"];
    int hour = [[chunk objectAtIndex:0] intValue];
    int min = [[chunk objectAtIndex:1] intValue];
    
    if ([[chunk objectAtIndex:2] isEqualToString:@"PM"]) {
        isAm = 0;
    } else {
        isAm=1;
    }
    
    if (hour < 10) {
        lblhour1.text = [NSString stringWithFormat:@"%i", 0];
        lblhour2.text = [NSString stringWithFormat:@"%i", hour];}
    else {
        lblhour1.text = [NSString stringWithFormat:@"%i", hour / 10];
        lblhour2.text = [NSString stringWithFormat:@"%i", hour % 10];
    }
    
    if (min < 10) {
        lblmin1.text = [NSString stringWithFormat:@"%i", 0];
        lblmin2.text = [NSString stringWithFormat:@"%i", min];}
    else {
        lblmin1.text = [NSString stringWithFormat:@"%i", min / 10];
        lblmin2.text = [NSString stringWithFormat:@"%i", min % 10];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTime" object:self];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *wakeuptime = [prefs objectForKey:@"wakeup"];
    int currentmin = [[NSString stringWithFormat:@"%@%@", lblmin1.text, lblmin2.text]intValue];
    
    if ((![wakeuptime length]) || ([wakeuptime isEqualToString:@"00:00"])) {
        wakeuptime = [NSString stringWithFormat:@"%@%@:%i", lblhour1.text, lblhour2.text, currentmin];
    }
    
    NSArray *timearray = [wakeuptime componentsSeparatedByString:@":"];
    int wakehour = [[timearray objectAtIndex:0] intValue];
    int wakemin = [[timearray objectAtIndex:1] intValue];
    int currenthour = [[NSString stringWithFormat:@"%@%@", lblhour1.text, lblhour2.text] intValue];
    
    if (currenthour == 12) {
        if (isAm) {
            currenthour = 24;
        } else {
            currenthour = 12;
        }
    } else if (!isAm) {
        currenthour += 12;
    }
    
    islock = 0;
    NSString *wakeuptime2 = [prefs objectForKey:@"wakeup"];
    if (wakeuptime2.length && ![wakeuptime2 isEqualToString:@"00:00"]) {
        if ((wakehour == currenthour) && (wakemin == min)) {
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            [prefs setObject:@"00:00" forKey:@"wakeup"];
            [prefs synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didWakeup" object:self];
        }}
}

#pragma mark - PickerView DataSource/Delegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView.tag == 0) {
        return 3;
    } else {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 0) {
        switch (component) {
            case 0:
                return 12;
                break;
            case 1:
                return 60;
                break;
            case 2:
                return 2;
                break;
            default:
                return 0;
                break;
        }
    } else if (pickerView.tag == 1) {
        return 24;
    } else {
        return 60;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 180, 15)];
    newLabel.backgroundColor = [UIColor clearColor];
    newLabel.opaque = YES;
    newLabel.textColor = [UIColor blackColor];
    newLabel.font = [UIFont boldSystemFontOfSize:18];
    newLabel.textAlignment = NSTextAlignmentCenter;
    
    if (pickerView.tag == 1)   {
        if (row > 1)
            newLabel.text = [NSString stringWithFormat:@"%li hours", (long)row];
        else
            newLabel.text = [NSString stringWithFormat:@"%li hour", (long)row];
    } else if (pickerView.tag == 2) {
        if (row > 1)
            newLabel.text = [NSString stringWithFormat:@"%li mins", (long)row];
        else
            newLabel.text = [NSString stringWithFormat:@"%li min", (long)row];
    } else {
        if (component == 0) {
            newLabel.text = [NSString stringWithFormat:@"%li", (long)row+1];
        } else {
            if (component == 0 || component == 1) {
                newLabel.text = [NSString stringWithFormat:@"%li", (long)row];
            } else {
                if (row == 0)
                    newLabel.text = @"AM";
                else
                    newLabel.text = @"PM";
            }
        }
    }
    
    return newLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    islock = 1;
    wakeupHour = [pickerView selectedRowInComponent:0] + 1;
    wakeupMin = [pickerView selectedRowInComponent:1];
    wakeupAp = [pickerView selectedRowInComponent:2];
    
    int currenthour = [[NSString stringWithFormat:@"%@%@", lblhour1.text, lblhour2.text] intValue];
    int currentmin = [[NSString stringWithFormat:@"%@%@", lblmin1.text, lblmin2.text] intValue];
    
    if (component == 0)
        wakeupHour = row + 1;
    else if (component == 1)
        wakeupMin = row;
    else if (component == 2)
        wakeupAp = row;
    
    if (wakeupAp) {
        if (wakeupHour < 12) {
            wakeupHour += 12;
        }
    } else if (wakeupHour > 12) {
        wakeupHour -= 12;
    }
    
    if (wakeupHour == 12) {
        if (!wakeupAp) {
            wakeupHour += 12;
        }
    }
    
    if (currenthour == 12) {
        if (isAm)
            currenthour = 24;
        else
            currenthour=12;
    } else if (!isAm) {
        currenthour += 12;
    }
    
    if (wakeupHour < currenthour)
        wakeupHour += 24;
    
    NSInteger sleepmin = 0;
    if (currenthour < 12) {
        sleepmin = wakeupHour * 60 + wakeupMin - currenthour * 60 - currentmin;
    } else {
        if ((wakeupHour * 60 + wakeupMin - currenthour * 60-currentmin) >= 0)
            sleepmin = wakeupHour * 60 + wakeupMin - currenthour * 60 - currentmin;
        else if (wakeupHour < 12)
            sleepmin = wakeupHour * 60 + 24 * 60 + wakeupMin - currenthour * 60 - currentmin;
    }
    
    if (sleepmin < 0) {
        sleepmin = 0;
    }
}

#pragma mark - Button Action Methods

- (IBAction)handleBtn:(id)sender {
    if ([btnSet.titleLabel.text isEqualToString:@"Set Alarm"]) {
        [self setAlarm:nil];
    } else {
        [self cancelAlarm:nil];
        [btnSet setTitle:@"Set Alarm" forState:UIControlStateNormal];
    }
}

#pragma mark - Setup/Cancel Alarm

- (void)cancelAlarm:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"00:00" forKey:@"wakeup"];
    [prefs synchronize];
}

- (void)setAlarm:(id)sender {
    wakeupHour = [datePicker selectedRowInComponent:0] + 1;
    wakeupMin = [datePicker selectedRowInComponent:1];
    wakeupAp = [datePicker selectedRowInComponent:2];
    
    int currenthour = [[NSString stringWithFormat:@"%@%@", lblhour1.text, lblhour2.text] intValue];
    
    if (wakeupAp) {
        if (wakeupHour < 12) {
            wakeupHour += 12;
        }
    } else if (wakeupHour > 12) {
        wakeupHour -= 12;
    }
    
    if (wakeupHour == 12) {
        if (!wakeupAp) {
            wakeupHour += 12;
        }
    }
    
    if (currenthour == 12) {
        if (isAm) {
            currenthour = 24;
        } else {
            currenthour=12;
        }
    } else if (!isAm) {
        currenthour+=12;
    }
    
    if (wakeupHour < currenthour) {
        wakeupHour += 24;
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:1 forKey:@"wake"];
    [prefs setObject:[NSString stringWithFormat:@"%li:%li", (long)wakeupHour, (long)wakeupMin] forKey:@"wakeup"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setAlarm" object:self];
    [self goClock];
}

#pragma mark - Go to Clock Page

- (void)goClock {
    ClockViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ClockViewController"];
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
