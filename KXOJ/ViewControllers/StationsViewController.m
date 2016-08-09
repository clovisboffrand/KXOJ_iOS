//
//  StationsViewController.m
//  KXOJ
//
//  Created by admin_user on 8/9/16.
//  Copyright © 2016 RadioServersLLC. All rights reserved.
//

#import "StationsViewController.h"
#import "Header.h"

@interface StationsViewController ()
{
    IBOutlet UIButton *btnChannel1;
    IBOutlet UIButton *btnChannel2;
    IBOutlet UIView *viewChannel1;
    IBOutlet UIView *viewChannel2;
}

@end

@implementation StationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup navigation bar.
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelView)]];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.title = @"Stations";
    
    // Setup channel views.
    viewChannel1.layer.borderWidth = 2;
    viewChannel1.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f].CGColor;
    viewChannel2.layer.borderWidth = 2;
    viewChannel2.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f].CGColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([AppSettings shared].channelId.integerValue == 1) {
        btnChannel1.enabled = NO;
        [btnChannel1 setTitle:@"Playing" forState:UIControlStateNormal];
    } else {
        btnChannel2.enabled = NO;
        [btnChannel2 setTitle:@"Playing" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cancelView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Button Action Methods

- (IBAction)didTapPlayButton:(UIButton *)button {
    if (button.tag == 1) {
        [[AppSettings shared] loadFirstChannel];
    } else {
        [[AppSettings shared] loadSecondChannel];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotiticationReloadRadioStreamingLink" object:nil];
    [self cancelView];
}

@end

