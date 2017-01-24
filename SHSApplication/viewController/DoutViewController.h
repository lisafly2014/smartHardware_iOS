//
//  DigitalOutputViewController.h
//  SHSApplication
//
//  Created by Simon Third on 05/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoutSettingViewController.h"

@protocol DoutDelegate <NSObject>
-(void)didOuputPinChanged:(uint8_t)outputPinIndex;
-(void)setOutputPinConfiguration:(uint8_t)command pinIndex:(uint8_t)dOutPin withConfigure:(NSData *)configureValue;
@end

@interface DoutViewController : UIViewController <DoutSettingDelegate>
@property(weak,nonatomic) NSMutableArray *doutConfiguration;
@property(weak,nonatomic) NSMutableArray *doutCurrentStatus;

@property(weak,nonatomic)id <DoutDelegate> doutDelegate;

@end
