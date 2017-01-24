//
//  AnalogInputViewController.m
//  SHSApplication
//
//  Created by Simon Third on 05/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "AinViewController.h"
#import "AinSettingViewController.h"
#import "Utility.h"

@interface AinViewController ()
@property (weak, nonatomic) IBOutlet UIProgressView *progressView0;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel0;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView1;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel1;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView2;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel2;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView3;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel3;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView4;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel4;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView5;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel5;



@end

@implementation AinViewController
@synthesize ainConfiguration;
@synthesize ainCurrentStatus;
@synthesize progressValue;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self getAnalogPinStatus];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(analogueInputPinStatusChanged) name:@"analogPinStatusChanged" object:nil];
}

-(void)getAnalogPinStatus{

    for(int i=0;i< ANALOGUE_INPUT_PIN_NUMBER;i++){
        int16_t value =0;
        if([self.ainConfiguration[i][0] boolValue]){
            value = [self.ainCurrentStatus[i] integerValue];
            
            self.progressValue = value/1023.0;
        }else{
            self.progressValue =0.0;
        }
            switch(i){
                case 0:
                {
                   [self.progressView0 setProgress:self.progressValue animated:NO];
                    self.progressLabel0.text = [NSString stringWithFormat:@"%d",value];
                    break;
                }
                case 1:
                {
                    [self.progressView1 setProgress:self.progressValue animated:NO];
                    self.progressLabel1.text = [NSString stringWithFormat:@"%d",value];
                    break;
                }
                case 2:
                {
                    [self.progressView2 setProgress:self.progressValue animated:NO];
                    self.progressLabel2.text = [NSString stringWithFormat:@"%d",value];
                    break;
                }
                case 3:
                    [self.progressView3 setProgress:self.progressValue animated:NO];
                    self.progressLabel3.text = [NSString stringWithFormat:@"%d",value];
                    break;
                case 4:
                    [self.progressView4 setProgress:self.progressValue animated:NO];
                    self.progressLabel4.text = [NSString stringWithFormat:@"%d",value];
                    break;
                case 5:
                    [self.progressView5 setProgress:self.progressValue animated:NO];
                    
                    self.progressLabel5.text = [NSString stringWithFormat:@"%d",value];
                    break;
        }
    }
}



-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"analogPinStatusChanged" object:nil];
}
-(void)analogueInputPinStatusChanged{
    [self getAnalogPinStatus]; 
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ainSetting"]){
        AinSettingViewController *controller =(AinSettingViewController *) segue.destinationViewController;
        controller.delegate =self;
        controller.ainConfiguration =self.ainConfiguration;
    }
}
#pragma mark - AinSettingDelegate

-(void)updateAnalogInputPinConfiguration:(uint8_t)command pinIndex:(uint8_t)aInPin withConfigure:(NSData *)configureValue{
    [self.ainDelegate setAnalogPinConfiguration:command pinIndex:aInPin withConfigure:configureValue];
}


@end
