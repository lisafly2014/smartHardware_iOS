//
//  DoutSettingViewController.h
//  SHSApplication
//
//  Created by Simon Third on 21/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "Utility.h"

@protocol DoutSettingDelegate <NSObject>
-(void)updateOutpinConfiguration:(uint8_t)command pinIndex:(uint8_t)dOutPin withConfigure:(NSData *)configureValue;
@end

@interface DoutSettingViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>{
    NSMutableArray *pinArray;
    NSMutableArray *pullArray;
    NSMutableArray *driveArray;
    NSMutableArray *defaultArray;
    
    NSUInteger currentDoutIndex;
    NSUInteger currentPullValue;
    NSUInteger currentDriveValue;
    NSUInteger currentDefaultValue;
}

@property (weak,nonatomic) id<DoutSettingDelegate> delegate;
@property(weak,nonatomic) NSMutableArray *doutConfiguration;
@property bool isLocked;

@end
