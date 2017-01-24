//
//  AinSettingViewController.h
//  SHSApplication
//
//  Created by Simon Third on 21/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AinSettingDelegate <NSObject>
-(void)updateAnalogInputPinConfiguration:(uint8_t)command pinIndex:(uint8_t)aInPin withConfigure:(NSData *)configureValue;
@end
@interface AinSettingViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>{
    NSMutableArray *analogPinArray;
    NSMutableArray *rateArray;
    NSMutableArray *rangeArray;
    
    
    NSUInteger currentAinIndex;
    NSUInteger currentRateValue;
    NSUInteger currentRangeValue;
}
@property (weak,nonatomic) id<AinSettingDelegate> delegate;
@property(weak,nonatomic) NSMutableArray *ainConfiguration;
@property bool isLocked;

@end
