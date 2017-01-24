//
//  DigitalOutputViewController.m
//  SHSApplication
//
//  Created by Simon Third on 05/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "DoutViewController.h"
#import "DoutSettingViewController.h"
#import "Utility.h"


@interface DoutViewController ()

@property (weak, nonatomic) IBOutlet UIButton *pinOut0;
@property (weak, nonatomic) IBOutlet UIButton *pinOut1;
@property (weak, nonatomic) IBOutlet UIButton *pinOut2;
@property (weak, nonatomic) IBOutlet UIButton *pinOut3;
@property (weak, nonatomic) IBOutlet UIButton *pinOut4;
@property (weak, nonatomic) IBOutlet UIButton *pinOut5;
@property (weak, nonatomic) IBOutlet UIButton *pinOut6;
@property (weak, nonatomic) IBOutlet UIButton *pinOut7;
@property (weak, nonatomic) IBOutlet UIButton *pinOut8;
@property (weak, nonatomic) IBOutlet UIButton *pinOut9;
@property (weak, nonatomic) IBOutlet UIButton *pinOut10;
@property (weak, nonatomic) IBOutlet UIButton *pinOut11;
@property (weak, nonatomic) IBOutlet UIButton *pinOut12;
@property (weak, nonatomic) IBOutlet UIButton *pinOut13;
@property (weak, nonatomic) IBOutlet UIButton *pinOut14;
@property (weak, nonatomic) IBOutlet UIButton *pinOut15;
@property (weak, nonatomic) IBOutlet UIButton *pinOut16;
@property (weak, nonatomic) IBOutlet UIButton *pinOut17;
@property (weak, nonatomic) IBOutlet UIButton *pinOut18;
@property (weak, nonatomic) IBOutlet UIButton *pinOut19;
@property (weak, nonatomic) IBOutlet UIButton *pinOut20;
@property (weak, nonatomic) IBOutlet UIButton *pinOut21;
@property (weak, nonatomic) IBOutlet UIButton *pinOut22;
@property (weak, nonatomic) IBOutlet UIButton *pinOut23;
@property (weak, nonatomic) IBOutlet UIButton *pinOut24;
@property (weak, nonatomic) IBOutlet UIButton *pinOut25;
@property (weak, nonatomic) IBOutlet UIButton *pinOut26;
@property (weak, nonatomic) IBOutlet UIButton *pinOut27;
@property (weak, nonatomic) IBOutlet UIButton *pinOut28;
@property (weak, nonatomic) IBOutlet UIButton *pinOut29;
@property (weak, nonatomic) IBOutlet UIButton *pinOut30;
@property (weak, nonatomic) IBOutlet UIButton *pinOut31;

@property (strong,nonatomic)IBOutletCollection(UIButton) NSArray *outputPins;


@end

@implementation DoutViewController
@synthesize doutConfiguration;
@synthesize doutCurrentStatus;
@synthesize outputPins;


- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self initialDigitalPinStatus];

}
-(void)initialDigitalPinStatus
{
    
    self.pinOut0.tag =0;
    self.pinOut1.tag =1;
    self.pinOut2.tag =2;
    self.pinOut3.tag =3;
    self.pinOut4.tag =4;
    self.pinOut5.tag= 5;
    self.pinOut6.tag= 6;
    self.pinOut7.tag =7;
    self.pinOut8.tag =8;
    self.pinOut9.tag =9;
    self.pinOut10.tag= 10;
    self.pinOut11.tag =11;
    self.pinOut12.tag =12;
    self.pinOut13.tag =13;
    self.pinOut14.tag =14;
    self.pinOut15.tag =15;
    self.pinOut16.tag =16;
    self.pinOut17.tag =17;
    self.pinOut18.tag =18;
    self.pinOut19.tag =19;
    self.pinOut20.tag =20;
    self.pinOut21.tag =21;
    self.pinOut22.tag =22;
    self.pinOut23.tag =23;
    self.pinOut24.tag =24;
    self.pinOut25.tag =25;
    self.pinOut26.tag =26;
    self.pinOut27.tag =27;
    self.pinOut28.tag =28;
    self.pinOut29.tag =29;
    self.pinOut30.tag= 30;
    self.pinOut31.tag =31;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setButtonImage];
}

-(void)setButtonImage{
    for(int index=0;index<32;index++){
        if([self.doutConfiguration[index][0] boolValue]){
            if([self.doutCurrentStatus[index] integerValue] ==1){
                [outputPins[index] setImage:[UIImage imageNamed:@"checked_checkbox.png"] forState:UIControlStateNormal];
            }else if([self.doutCurrentStatus[index] integerValue] ==0){
                [outputPins[index] setImage:[UIImage imageNamed:@"unchecked_checkbox.png"] forState:UIControlStateNormal];
            }
        }else{
            
            [outputPins[index] setImage:[UIImage imageNamed:@"disable_checkbox.png"] forState:UIControlStateNormal];
        }
    }
}



- (IBAction)didTapButton:(id)sender {
    int8_t tag = (uint8_t)[(UIButton *) sender tag];
     if([self.doutConfiguration[tag][0] boolValue]){
         if([self.doutCurrentStatus[tag] integerValue]==1){
             [sender setImage:[UIImage imageNamed:@"unchecked_checkbox.png"] forState:UIControlStateNormal];
             self.doutCurrentStatus[tag]=@(0);
         }else if([self.doutCurrentStatus[tag] integerValue]==0){
             [sender setImage:[UIImage imageNamed:@"checked_checkbox.png"] forState:UIControlStateNormal];
             self.doutCurrentStatus[tag]=@(1);
         }
         [self.doutDelegate didOuputPinChanged:tag];
     } 
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 if([segue.identifier isEqualToString:@"doutSetting"]){
     DoutSettingViewController * controller =(DoutSettingViewController *) segue.destinationViewController;
     controller.delegate =self;
     controller.doutConfiguration =self.doutConfiguration;
 }
}


#pragma mark -- DoutSettingDelegate
-(void)updateOutpinConfiguration:(uint8_t)command pinIndex:(uint8_t)dOutPin withConfigure:(NSData *)configureValue{
    [self.doutDelegate  setOutputPinConfiguration:command pinIndex:dOutPin withConfigure:configureValue];
}

@end


