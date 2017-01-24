//
//  PwmOutputSettingViewController.h
//  SHSApplication
//
//  Created by Simon Third on 17/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol pwmSettingDelegate
-(void)updatePwmConfiguration:(uint8_t)command pwmIndex:(uint8_t)index withDutyCycle:(NSData *)configureValue;

@end

@interface PwmSettingViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>{
    NSMutableArray *pwmChannelArray;
    NSMutableArray *pwmPinArray;
    NSMutableArray *pwmDriveArray;
    
    NSUInteger currentChannelIndex;
    NSUInteger currentPinIndex;
    NSUInteger currentDriveValue;
}

@property(weak, nonatomic) id<pwmSettingDelegate> delegate;
@property(weak,nonatomic) NSMutableArray *pwmConfiguration;
@property bool isLocked;

@end
