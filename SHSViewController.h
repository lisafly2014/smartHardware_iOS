//
//  SHSViewController.h
//  SHSApplication
//
//  Created by Simon Third on 04/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScannerDelegate.h"
#import "SHSOperations.h"
#import "InterfaceTableViewController.h"

@interface SHSViewController : UIViewController<ScannerDelegate,SHSOperationsDelegate,InterfaceTableVCDelegate>
@property (weak, nonatomic) IBOutlet UILabel *hardwareName;
@property (weak, nonatomic) IBOutlet UIButton *showInterfaceButton;
@property (weak,nonatomic) id <InterfaceTableVCDelegate> interfaceDelegate;
@property (weak,nonatomic) NSTimer *timer;

@end
