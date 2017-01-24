//
//  ServoViewController.m
//  SHSApplication
//
//  Created by Simon Third on 06/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "ServoViewController.h"
#import "Utility.h"


@interface ServoViewController ()
@property (weak, nonatomic) IBOutlet UISlider *servo0Slider;
@property (weak, nonatomic) IBOutlet UISlider *servo1Slider;
@property (weak, nonatomic) IBOutlet UISlider *servo2Slider;
@property (weak, nonatomic) IBOutlet UISlider *servo3Slider;


@property (weak, nonatomic) IBOutlet UILabel *servo0Percentage;
@property (weak, nonatomic) IBOutlet UILabel *servo1Percentage;
@property (weak, nonatomic) IBOutlet UILabel *servo2Percentage;
@property (weak, nonatomic) IBOutlet UILabel *servo3Percentage;

@property(nonatomic) int slider0_retain_value;
@property(nonatomic) int slider1_retain_value;
@property(nonatomic) int slider2_retain_value;
@property(nonatomic) int slider3_retain_value;

@end

@implementation ServoViewController
@synthesize servoConfiguration;
@synthesize servoCurrentPercentage;
@synthesize slider0_retain_value;
@synthesize slider1_retain_value;
@synthesize slider2_retain_value;
@synthesize slider3_retain_value;

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self getServoPercentage];
}
-(void)getServoPercentage{
    int percentage =0;
    float percentageFloat;
    NSString *percentageString=@"";
    for(int i=0;i< SERVO_CHANNELS; i++){
        if([self.servoConfiguration[i][0] boolValue]){
            percentage =(int)[self.servoCurrentPercentage[i] integerValue];
//            NSLog(@"percentage = %d",(int)percentage);
        }else{
            percentage =0;
        }
        

        if(percentage ==0){
            percentageString= [NSString stringWithFormat:@"%@%%",@(0)];
        }else if(percentage ==100){
            percentageString= [NSString stringWithFormat:@"%@%%",@(100)];
        }else{
            percentageString= [NSString stringWithFormat:@"%d%%",percentage];
        }
        
        percentageFloat = percentage*1.0f;
        
        switch(i){
            case 0:
                if([self.servoConfiguration[0][0] boolValue]){
                    [self.servo0Slider setUserInteractionEnabled:YES];
                }else{
                    [self.servo0Slider setUserInteractionEnabled:NO];
                }
                slider0_retain_value = percentage;
                [self.servo0Slider setValue:percentageFloat];
                self.servo0Percentage.text = percentageString;
                break;
            case 1:
                if([self.servoConfiguration[1][0] boolValue]){
                    [self.servo1Slider setUserInteractionEnabled:YES];
                }else{
                    [self.servo1Slider setUserInteractionEnabled: NO];
                }
                slider1_retain_value = percentage;
                [self.servo1Slider setValue:percentageFloat];
                self.servo1Percentage.text =percentageString;
                break;
            case 2:
                if([self.servoConfiguration[2][0] boolValue]){
                    [self.servo2Slider setUserInteractionEnabled:YES];
                }else{
                    [self.servo2Slider setUserInteractionEnabled:NO];
                }
                slider2_retain_value = percentage;
                [self.servo2Slider setValue:percentageFloat];
                self.servo2Percentage.text = percentageString;
                break;
            case 3:
                if([self.servoConfiguration[3][0] boolValue]){
                    [self.servo3Slider setUserInteractionEnabled:YES];
                }else{
                    [self.servo3Slider setUserInteractionEnabled:NO];
                }
                slider3_retain_value = percentage;
                [self.servo3Slider setValue:percentageFloat];
                self.servo3Percentage.text = percentageString;
                break;
        }
      }
}

- (IBAction)moveSlider:(id)sender {
    int percentage;
    int servoIndex;
    
    if([sender isEqual:self.servo0Slider]){
        servoIndex =0;
        [self.servo0Slider setValue:(int) (self.servo0Slider.value +0.5) animated:NO];
        percentage = (int)self.servo0Slider.value;
        
        self.servo0Percentage.text = [NSString stringWithFormat:@"%d%%",percentage];
        if(slider0_retain_value != percentage){
            slider0_retain_value = percentage;
            self.servoCurrentPercentage[servoIndex] = @(percentage);
            [self.servoDelegate didMoveServoSlider:servoIndex];
        }
    }else if([sender isEqual:self.servo1Slider]){
            servoIndex =1;
            [self.servo1Slider setValue:(int) (self.servo1Slider.value +0.5) animated:NO];
            percentage = (int)self.servo1Slider.value;

            self.servo1Percentage.text = [NSString stringWithFormat:@"%d%%",percentage];
            if(slider1_retain_value != percentage){
                slider1_retain_value = percentage;
                self.servoCurrentPercentage[servoIndex] = @(percentage);
                [self.servoDelegate didMoveServoSlider:servoIndex];
            }
        }else if([sender isEqual:self.servo2Slider]){
            servoIndex =2;
            [self.servo2Slider setValue:(int) (self.servo2Slider.value +0.5) animated:NO];
            percentage = (int)self.servo2Slider.value;

            self.servo2Percentage.text = [NSString stringWithFormat:@"%d%%",percentage];
            if(slider2_retain_value != percentage){
                slider2_retain_value = percentage;
                self.servoCurrentPercentage[servoIndex] = @(percentage);
                [self.servoDelegate didMoveServoSlider:servoIndex];
            }
        }else if([sender isEqual:self.servo3Slider]){
            servoIndex =3;
            [self.servo3Slider setValue:(int) (self.servo3Slider.value +0.5) animated:NO];
            percentage = (int)self.servo3Slider.value;

            self.servo3Percentage.text = [NSString stringWithFormat:@"%d%%",percentage];
            if(slider3_retain_value != percentage){
                slider3_retain_value = percentage;
                self.servoCurrentPercentage[servoIndex] = @(percentage);
                [self.servoDelegate didMoveServoSlider:servoIndex];
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
    if([segue.identifier isEqualToString:@"servoSetting"]){
        ServoSettingViewController * controller =(ServoSettingViewController *) segue.destinationViewController;
        controller.delegate =self;
        controller.servoConfiguration =self.servoConfiguration;
    }
}

#pragma mark -- ServoSettingDelegate
-(void)updateServoConfiguration:(uint8_t)command servoIndex:(uint8_t)index withConfigure:(NSData *)configureValue{
    [self.servoDelegate setServoConfiguration:command pinIndex:index withPercentage:configureValue];
    
}


@end
