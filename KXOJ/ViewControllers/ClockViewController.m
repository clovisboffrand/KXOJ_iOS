//
//  ClockViewController.m
//  WJRS
//
//  Created by admin_user on 3/7/16.
//
//

#import "ClockViewController.h"
#import "header.h"

@interface ClockViewController () {
    IBOutlet UILabel *lblDate;
    IBOutlet UILabel *lblTime;
    IBOutlet UILabel *lblAlarm;
}

@end

@implementation ClockViewController {
    NSDateFormatter *dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    
    NSArray *timearray=[[[NSUserDefaults standardUserDefaults] objectForKey:@"wakeup"] componentsSeparatedByString:@":"];
    int wakehour = [[timearray objectAtIndex:0]intValue];
    int wakemin = [[timearray objectAtIndex:1]intValue];
    
    NSString *displaymin;
    NSString *displayhour;
    
    if (wakemin < 10) {
        displaymin = [NSString stringWithFormat:@"0%i",wakemin];
    } else {
        displaymin = [NSString stringWithFormat:@"%i",wakemin];
    }
    
    if (wakehour < 12) {
        if (wakehour < 10)
            displayhour = [NSString stringWithFormat:@"0%i", wakehour];
        else
            displayhour = [NSString stringWithFormat:@"%i", wakehour];
        lblAlarm.text = [NSString stringWithFormat:@"Alarm %@:%@ AM", displayhour, displaymin];
    } else if (wakehour == 12) {
        lblAlarm.text = [NSString stringWithFormat:@"Alarm 12:%@ PM", displaymin];
    } else if (wakehour < 24) {
        if (wakehour - 12 < 10)
            displayhour = [NSString stringWithFormat:@"0%i", wakehour - 12];
        else
            displayhour = [NSString stringWithFormat:@"%i", wakehour - 12];
        lblAlarm.text = [NSString stringWithFormat:@"Alarm %@:%@ PM", displayhour, displaymin];
    } else if (wakehour == 24) {
        lblAlarm.text = [NSString stringWithFormat:@"Alarm %i:%@ AM", 12, displaymin];
    } else {
        if (wakehour - 24 < 10)
            displayhour = [NSString stringWithFormat:@"0%i", wakehour -24];
        else
            displayhour = [NSString stringWithFormat:@"%i", wakehour - 24];
        
        if (wakehour < 36) {
            lblAlarm.text = [NSString stringWithFormat:@"Alarm %@:%@ AM", displayhour, displaymin];
        } else {
            lblAlarm.text = [NSString stringWithFormat:@"Alarm %@:%@ PM", displayhour, displaymin];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTime) name:@"updateTime" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self rotateView];
}

#pragma mark - Rotate View

- (void)rotateView {
    CGAffineTransform transform = CGAffineTransformMakeRotation(3.14159/2);
    self.view.transform = transform;
    
    // Repositions and resizes the view.
    CGRect contentRect = CGRectMake(0, 0, Window().frame.size.height, Window().frame.size.width);
    self.view.bounds = contentRect;
}

#pragma mark - Button Action Methods

- (IBAction)doBack:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"setAlarm" object:self];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"00:00" forKey:@"wakeup"];
    [prefs synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doPlayPause:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateStream" object:self];
}

#pragma mark - Update Time

- (void)updateTime {
    NSDate *date = [NSDate date];
    [dateFormatter setDateFormat:@"hh : mm : a"];
    lblTime.text = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"MMM d, yyyy"];
    lblDate.text = [dateFormatter stringFromDate:date];
}

@end
