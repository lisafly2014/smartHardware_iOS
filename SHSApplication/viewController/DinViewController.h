//
//  DigitalInputViewController.h
//  SHSApplication
//
//  Created by Simon Third on 05/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DinSettingViewController.h"

@protocol DinDelegate <NSObject>
-(void)setInputPinConfiguration:(uint8_t)command pinIndex:(uint8_t)inputPin withConfigure:(NSData *)configureValue;
@end

@interface DinViewController : UIViewController <DinSettingDelegate>

@property(weak,nonatomic) NSMutableArray *dinConfiguration;
@property(weak,nonatomic) NSMutableArray *dinCurrentStatus;

@property(weak,nonatomic) id<DinDelegate> dinDelegate;

@end
