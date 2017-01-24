//
//  InputPinSettingViewController.h
//  SHSApplication
//
//  Created by Simon Third on 17/03/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DinSettingDelegate <NSObject>
-(void)updateInputpinConfiguration:(uint8_t)command pinIndex:(uint8_t)inputPin withConfigure:(NSData *)configureValue;
@end

@interface DinSettingViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>{

    NSMutableArray *pinArray;
    NSMutableArray *pullArray;
    
    NSUInteger currentDinIndex;
    NSUInteger currentPullValue;
}

@property (weak,nonatomic) id<DinSettingDelegate> delegate;
@property(weak,nonatomic) NSMutableArray *dinConfiguration;
@property bool isLocked;
@end
