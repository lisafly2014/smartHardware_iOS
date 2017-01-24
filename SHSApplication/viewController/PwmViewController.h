//
//  PwmOutputViewController.h
//  SHSApplication
//
//  Created by Simon Third on 17/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PwmSettingViewController.h"
@protocol PwmDelegate <NSObject>
-(void)didMovePwmSlider:(uint8_t) pwmIndex;
-(void)setPwmConfiguration:(uint8_t)command pwmIndex:(uint8_t)index withDutyCycle:(NSData *)newDutyCycle;
@end


@interface PwmViewController : UIViewController <pwmSettingDelegate>
@property(weak,nonatomic) NSMutableArray *pwmConfiguration;
@property(weak,nonatomic) NSMutableArray *pwmCurrentDutyCycle;
@property(weak,nonatomic) id<PwmDelegate> pwmDelegate;

@end
