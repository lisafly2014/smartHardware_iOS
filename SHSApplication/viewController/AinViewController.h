//
//  AnalogInputViewController.h
//  SHSApplication
//
//  Created by Simon Third on 05/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AinSettingViewController.h"


@protocol AinDelegate <NSObject>
-(void)setAnalogPinConfiguration:(uint8_t)command pinIndex:(uint8_t)analogPin withConfigure:(NSData *)configureValue;
@end

@interface AinViewController : UIViewController<AinSettingDelegate>
@property(weak,nonatomic) NSMutableArray *ainConfiguration;
@property(weak,nonatomic) NSMutableArray *ainCurrentStatus;

@property (nonatomic) float progressValue;
@property(weak,nonatomic)id <AinDelegate> ainDelegate;

@end

