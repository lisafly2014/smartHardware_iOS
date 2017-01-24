//
//  Utility.m
//  SHSApplication
//
//  Created by Simon Third on 02/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "Utility.h"

@implementation Utility
NSString * const shsServiceUUIDString=                @"48530000-5a4e-6c61-626f-6c475344414d";
/*send command from app to device*/
NSString * const shsSendCharacteristicUUIDString =    @"48530001-5a4e-6c61-626f-6c475344414d";
/*receive command from device to app*/
NSString * const shsReceiveCharacteristicUUIDString = @"48530002-5a4e-6c61-626f-6c475344414d";
NSString * const ANCSServiceUUIDString = @"7905F431-B5CE-4E99-A40F-4B1E122D00D0";

int8_t const ANALOGUE_INPUT_PIN_NUMBER =6; //ananog pin number 6
int8_t const PWM_CHANNELS =4;
int8_t const SERVO_CHANNELS =4;




+ (void)showAlert:(NSString *)message
{
    UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"SHS" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    UIViewController *currentTopVC = [self getTopViewController];
    [currentTopVC presentViewController:alert  animated:YES completion:nil];
}

+(UIViewController *) getTopViewController{
    UIViewController *topViewController =[[[UIApplication sharedApplication]  keyWindow] rootViewController];

    while(topViewController.presentedViewController){
        topViewController = topViewController.presentedViewController;
    }
    return topViewController;
}

+(void)showBackgroundNotification:(NSString *)message
{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertAction = @"Show";
    notification.alertBody = message;
    notification.hasAction = NO;
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
    notification.timeZone = [NSTimeZone  defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
}

+ (BOOL)isApplicationStateInactiveORBackground {
    UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
    if (applicationState == UIApplicationStateInactive || applicationState == UIApplicationStateBackground) {
        return YES;
    }
    else {
        return NO;
    }
}


@end
