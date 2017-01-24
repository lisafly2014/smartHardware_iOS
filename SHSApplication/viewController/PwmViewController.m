//
//  PwmOutputViewController.m
//  SHSApplication
//
//  Created by Simon Third on 17/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "PwmViewController.h"
#import "Utility.h"

@interface PwmViewController ()
@property (weak, nonatomic) IBOutlet UISlider *pwm0Slider;
@property (weak, nonatomic) IBOutlet UISlider *pwm1Slider;
@property (weak, nonatomic) IBOutlet UISlider *pwm2Slider;
@property (weak, nonatomic) IBOutlet UISlider *pwm3Slider;

@property (weak, nonatomic) IBOutlet UILabel *pwm0DutyCycle;
@property (weak, nonatomic) IBOutlet UILabel *pwm1DutyCycle;
@property (weak, nonatomic) IBOutlet UILabel *pwm2DutyCycle;
@property (weak, nonatomic) IBOutlet UILabel *pwm3DutyCycle;

@property(nonatomic) int slider0_retain_value;
@property(nonatomic) int slider1_retain_value;
@property(nonatomic) int slider2_retain_value;
@property(nonatomic) int slider3_retain_value;

@end

@implementation PwmViewController
@synthesize pwmConfiguration;
@synthesize pwmCurrentDutyCycle;

@synthesize slider0_retain_value;
@synthesize slider1_retain_value;
@synthesize slider2_retain_value;
@synthesize slider3_retain_value;


- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getPwmDutyCycle];
}

-(void)getPwmDutyCycle{
    int dutyCycle =0;
    float dutyCycleFloat;
    NSString *dutyCycleString=@"";
    for(int i=0;i< PWM_CHANNELS; i++){
        if([self.pwmConfiguration[i][0] boolValue]){
            dutyCycle = (int)[self.pwmCurrentDutyCycle[i] integerValue];
        }else{
            dutyCycle =0;
        }
        
        
        if(dutyCycle ==0){
            dutyCycleString= [NSString stringWithFormat:@"%@%%",@(0)];
        }else if(dutyCycle ==100){
            dutyCycleString= [NSString stringWithFormat:@"%@%%",@(100)];
        }else{
            dutyCycleString= [NSString stringWithFormat:@"%d%%",dutyCycle];
        }
        
        dutyCycleFloat = dutyCycle*1.0f;
        
        switch(i){
            case 0:
                if([self.pwmConfiguration[0][0] boolValue]){
                    [self.pwm0Slider setUserInteractionEnabled:YES];
                }else{
                    [self.pwm0Slider setUserInteractionEnabled:NO];
                }
                slider0_retain_value = dutyCycle;
                [self.pwm0Slider setValue:dutyCycleFloat];
                self.pwm0DutyCycle.text = dutyCycleString;
                break;
            case 1:
                if([self.pwmConfiguration[1][0] boolValue]){
                    [self.pwm1Slider setUserInteractionEnabled:YES];
                }else{
                    [self.pwm1Slider setUserInteractionEnabled:NO];
                }
                slider1_retain_value = dutyCycle;
                [self.pwm1Slider setValue:dutyCycleFloat];
                self.pwm1DutyCycle.text =dutyCycleString;
                break;
            case 2:
                if([self.pwmConfiguration[2][0] boolValue]){
                    [self.pwm2Slider setUserInteractionEnabled:YES];
                }else{
                    [self.pwm2Slider setUserInteractionEnabled:NO];
                }
                slider2_retain_value = dutyCycle;
                [self.pwm2Slider setValue:dutyCycleFloat];
                self.pwm2DutyCycle.text = dutyCycleString;
                break;
            case 3:
                if([self.pwmConfiguration[3][0] boolValue]){
                    [self.pwm3Slider setUserInteractionEnabled:YES];
                }else{
                    [self.pwm3Slider setUserInteractionEnabled:NO];
                }
                slider3_retain_value = dutyCycle;
                [self.pwm3Slider setValue:dutyCycleFloat];
                self.pwm3DutyCycle.text = dutyCycleString;
                break;
        }
    }
}

- (IBAction)moveSlider:(id)sender {
    int dutyCycle;
    int pwmIndex;
    
    if([sender isEqual:self.pwm0Slider]){
        pwmIndex = 0;
        [self.pwm0Slider setValue:(int)(self.pwm0Slider.value +0.5)];
        dutyCycle =(int) self.pwm0Slider.value;
        self.pwm0DutyCycle.text = [NSString stringWithFormat:@"%d%%",dutyCycle];
        
        if(slider0_retain_value != dutyCycle){
            slider0_retain_value =dutyCycle;
            self.pwmCurrentDutyCycle[pwmIndex] = @(dutyCycle);
            [self.pwmDelegate didMovePwmSlider:pwmIndex];
        }
  
    }else if([sender isEqual:self.pwm1Slider]){
        pwmIndex = 1;
        [self.pwm1Slider setValue:(int)(self.pwm1Slider.value +0.5)];
         self.pwm1DutyCycle.text = [NSString stringWithFormat:@"%d%%",dutyCycle];
        
        dutyCycle = (int)self.pwm1Slider.value;
        if(slider1_retain_value != dutyCycle){
            slider1_retain_value =dutyCycle;
            self.pwmCurrentDutyCycle[pwmIndex] = @(dutyCycle);
            [self.pwmDelegate didMovePwmSlider:pwmIndex];
        }
 
    }else if([sender isEqual:self.pwm2Slider]){
        pwmIndex = 2;
        [self.pwm2Slider setValue:(int)(self.pwm2Slider.value +0.5)];
         self.pwm2DutyCycle.text = [NSString stringWithFormat:@"%d%%",dutyCycle];
        
        dutyCycle = (int)self.pwm2Slider.value;
        if(slider2_retain_value != dutyCycle){
            slider2_retain_value =dutyCycle;
            self.pwmCurrentDutyCycle[pwmIndex] = @(dutyCycle);
            [self.pwmDelegate didMovePwmSlider:pwmIndex];
        }
        
    }else if([sender isEqual:self.pwm3Slider]){
        pwmIndex = 3;
        [self.pwm3Slider setValue:(int)(self.pwm3Slider.value +0.5)];
        self.pwm3DutyCycle.text = [NSString stringWithFormat:@"%d%%",dutyCycle];
        dutyCycle = (int)self.pwm3Slider.value;
        if(slider3_retain_value != dutyCycle){
            slider3_retain_value =dutyCycle;
            self.pwmCurrentDutyCycle[pwmIndex] = @(dutyCycle);
            [self.pwmDelegate didMovePwmSlider:pwmIndex];
        } 
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"pwmSetting"]){
        PwmSettingViewController * controller =(PwmSettingViewController *) segue.destinationViewController;
        controller.delegate =self;
        controller.pwmConfiguration =self.pwmConfiguration;
    }
}


-(void)updatePwmConfiguration:(uint8_t)command pwmIndex:(uint8_t)index withDutyCycle:(NSData *)configureValue{
    [self.pwmDelegate setPwmConfiguration:command pwmIndex:index withDutyCycle:configureValue];
}

@end
