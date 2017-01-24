//
//  ServoSettingViewController.h
//  SHSApplication
//
//  Created by Simon Third on 06/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ServoSettingDelegate <NSObject>
-(void)updateServoConfiguration:(uint8_t)command servoIndex:(uint8_t)index withConfigure:(NSData *)configureValue;
@end

@interface ServoSettingViewController: UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>{
    NSMutableArray *servoChannelArray;
    NSMutableArray *servoPinArray;
    NSMutableArray *servoDriveArray;
    NSUInteger currentChannelIndex;
    NSUInteger currentPinIndex;
    NSUInteger currentDriveValue;
}

@property (weak,nonatomic) id<ServoSettingDelegate> delegate;
@property(weak,nonatomic) NSMutableArray *servoConfiguration;
@property bool isLocked;

@end
