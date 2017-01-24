//
//  ServoViewController.h
//  SHSApplication
//
//  Created by Simon Third on 06/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServoSettingViewController.h"

@protocol ServoDelegate <NSObject>
-(void)setServoConfiguration:(uint8_t)command pinIndex:(uint8_t)index withPercentage:(NSData *)newPercentage;
-(void)didMoveServoSlider:(uint8_t) servoIndex;
@end

@interface ServoViewController : UIViewController <ServoSettingDelegate>
@property(weak,nonatomic) NSMutableArray *servoConfiguration;
@property(weak,nonatomic) NSMutableArray *servoCurrentPercentage;
@property(weak,nonatomic) id<ServoDelegate> servoDelegate;

@end
