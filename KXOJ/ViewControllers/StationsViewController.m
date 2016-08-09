//
//  StationsViewController.m
//  KXOJ
//
//  Created by admin_user on 8/9/16.
//  Copyright © 2016 RadioServersLLC. All rights reserved.
//

#import "StationsViewController.h"

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cancelView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
