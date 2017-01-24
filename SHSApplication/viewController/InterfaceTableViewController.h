//
//  InterfaceTableViewController.h
//  SHSApplication
//
//  Created by Simon Third on 05/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoutViewController.h"
#import "DinViewController.h"
#import "AinViewController.h"
#import "PwmViewController.h"
#import "ServoViewController.h"

@protocol InterfaceTableVCDelegate <NSObject>

-(void)didUpdatePinConfiguration:(uint8_t)command withPinIndex:(uint8_t)pinIndex withConfigure:(NSData *)configureValue fromInterface:(uint8_t)interfaceType;
-(void)didUpdateInterfaceValue:(uint8_t)pinIndex interfaceType:(uint8_t)type;
@end

@interface InterfaceTableViewController : UITableViewController <DoutDelegate, DinDelegate,AinDelegate,PwmDelegate,ServoDelegate>

@property NSMutableArray *interfaceList;

@property(weak,nonatomic)NSMutableArray *dinConfiguration;
@property(weak,nonatomic)NSMutableArray *dinCurrentStatus;

@property(weak,nonatomic)NSMutableArray *doutConfiguration;
@property(weak,nonatomic)NSMutableArray *doutCurrentStatus;

@property(weak,nonatomic)NSMutableArray *ainConfiguration;
@property(weak,nonatomic)NSMutableArray *ainCurrentStatus;

@property(weak,nonatomic)NSMutableArray *pwmConfiguration;
@property(weak,nonatomic)NSMutableArray *pwmCurrentDutyCycle;

@property(weak,nonatomic)NSMutableArray *servoConfiguration;
@property(weak,nonatomic)NSMutableArray *servoCurrentPercentage;


@property(weak,nonatomic)id <InterfaceTableVCDelegate> interfaceDelegate;


@end
