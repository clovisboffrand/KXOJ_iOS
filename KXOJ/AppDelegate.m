//
//  AppDelegate.m
//  iRadio
//
//  Created by ben on 10/05/11.
//  Copyright 2011 Ingravitymedia.com. All rights reserved.
//

#import "AppDelegate.h"
#import "Header.h"

@implementation AppDelegate

#pragma mark - Application lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Battery monitor
    [self registerForBatteryStateChanges];
    
    // Force updates at first time
    [self batteryStateDidChange];
    
    // Begin receiving the remote control events.
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
        [self becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - Battery Status Monitor

- (void)registerForBatteryStateChanges {
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
    // Start tracking battery state
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(batteryStateDidChange)
                                                 name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

- (void)batteryStateDidChange {
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    //UIDeviceBatteryStateCharging - plugged in, less than 100%
    //UIDeviceBatteryStateFull - plugged in, at 100%
    if ((batteryState == UIDeviceBatteryStateCharging) || (batteryState == UIDeviceBatteryStateFull)) {
        // DON'T let the device go to sleep
        // a trick, you must set it NO before, it's apple's bug in some iOS versions
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    } else {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
}

#pragma mark - Remote Control Events

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if (event.type == UIEventTypeRemoteControl)	{
        switch(event.subtype)		{
            case UIEventSubtypeRemoteControlPlay:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TogglePlayPause" object:nil];
                break;
            case UIEventSubtypeRemoteControlPause:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TogglePlayPause" object:nil];
                break;
            case UIEventSubtypeRemoteControlStop:
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"TogglePlayPause" object:nil];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NextTrack" object:nil];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PreviousTrack" object:nil];
                break;
            default:
                return;
        }
    }
}

@end

