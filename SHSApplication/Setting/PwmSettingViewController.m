//
//  PwmOutputSettingViewController.m
//  SHSApplication
//
//  Created by Simon Third on 17/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "PwmSettingViewController.h"
#import "Utility.h"

@interface PwmSettingViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *pwmChannelPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pwmPinPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *pwmDrivePickerView;

@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@property (weak, nonatomic) IBOutlet UISlider *dutyCycleSlider;
@property (weak, nonatomic) IBOutlet UILabel *dutyCycleValue;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *lockAndSaveButton;

@end

@implementation PwmSettingViewController
@synthesize pwmConfiguration;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPwmSetting];
    
    self.pwmChannelPickerView.dataSource =self;
    self.pwmChannelPickerView.delegate =self;
    self.pwmChannelPickerView.showsSelectionIndicator = YES;
    
    self.pwmPinPickerView.dataSource =self;
    self.pwmPinPickerView.delegate =self;
    self.pwmPinPickerView.showsSelectionIndicator = YES;
    
    self.pwmDrivePickerView.dataSource =self;
    self.pwmDrivePickerView.delegate =self;
    self.pwmDrivePickerView.showsSelectionIndicator = YES;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    if(![[[defaults dictionaryRepresentation] allKeys] containsObject:@"deviceLocked"]){
        self.isLocked =YES;
    }else{
        self.isLocked = [defaults boolForKey:@"deviceLocked"];
    }
    
    currentChannelIndex = [defaults integerForKey:@"pwmChannelIndex"];
    currentPinIndex = [self.pwmConfiguration[currentChannelIndex][1] integerValue];
    currentDriveValue =[self.pwmConfiguration[currentChannelIndex][2] integerValue];
    
    [self.pwmChannelPickerView  selectRow:currentChannelIndex inComponent:0 animated:NO];
    
    if([self.pwmConfiguration[currentChannelIndex][0] boolValue]){
        [self.enableSwitch setOn:YES];
        
        [self.pwmPinPickerView setUserInteractionEnabled:YES];
        [self.pwmPinPickerView selectRow:currentPinIndex inComponent:0 animated:NO];
        
        [self.pwmDrivePickerView setUserInteractionEnabled:YES];
        [self.pwmDrivePickerView selectRow:currentDriveValue inComponent:0 animated:NO];
        int dutyCycle =(int)[self.pwmConfiguration[currentChannelIndex][3] integerValue];
        
        [self.dutyCycleSlider setUserInteractionEnabled:YES];
        [self.dutyCycleSlider setValue: dutyCycle*1.0f];
        self.dutyCycleValue.text= [NSString stringWithFormat:@"%d%%",dutyCycle];
        
    }else{
        [self.enableSwitch setOn:NO];
        [self.pwmPinPickerView setUserInteractionEnabled:NO];
        [self.pwmPinPickerView selectRow:0 inComponent:0 animated:NO];
        
        [self.pwmDrivePickerView setUserInteractionEnabled:NO];
        [self.pwmDrivePickerView selectRow:0 inComponent:0 animated:NO];
        
        [self.dutyCycleSlider setUserInteractionEnabled:NO];
        [self.dutyCycleSlider setValue: 0*1.0f];
        self.dutyCycleValue.text= [NSString stringWithFormat:@"%d%%",0];
    }
}

-(void)initPwmSetting{
    NSArray *pwmChannelList=[[NSArray alloc] initWithObjects:@0,@1,@2,@3,nil];
    pwmChannelArray =[NSMutableArray arrayWithArray:pwmChannelList];
    
    NSArray *pwmPinList=[[NSArray alloc] initWithObjects:@0,@1,@2,@3,
                           @4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,
                           @17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,
                           @29,@30,@31,nil];
    pwmPinArray =[NSMutableArray arrayWithArray:pwmPinList];
    
    NSArray *pwmDriveList = [[NSArray alloc] initWithObjects:@"S0S1",@"H0S1",
                          @"S0H1",@"H0H1",@"D0S1",@"D0H1",@"S0D1",@"H0D1", nil];
    pwmDriveArray = [NSMutableArray arrayWithArray:pwmDriveList];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didChangedPwmPinStatus:(id)sender {
    if(self.enableSwitch.on){
        NSLog(@"pwm switch is on.");
        [self.pwmPinPickerView setUserInteractionEnabled:YES];
        [self.pwmDrivePickerView setUserInteractionEnabled:YES];
        [self.dutyCycleSlider setUserInteractionEnabled:YES];
    }else{
        NSLog(@"pwm switch is off");
    }
}
- (IBAction)changePwmDefaultDutyCycle:(id)sender {
    int  dutyCycle;
    [self.dutyCycleSlider setValue:(int)(self.dutyCycleSlider.value +0.5)];
    dutyCycle = (int)self.dutyCycleSlider.value;
    self.dutyCycleValue.text = [NSString stringWithFormat:@"%d%%",dutyCycle];
}


- (IBAction)didClickPwmSaveButton:(id)sender {
    if([self.pwmConfiguration[currentChannelIndex][0] boolValue]){
        if(self.enableSwitch.on){
            if(([self.pwmConfiguration[currentChannelIndex][1] integerValue] ==currentPinIndex)
               &&([self.pwmConfiguration[currentChannelIndex][2] integerValue] ==currentDriveValue)
               &&(int)[self.pwmConfiguration[currentChannelIndex][3] integerValue] ==(int)(self.dutyCycleSlider.value)){
                //keep the same
                [Utility showAlert:@"Configuration has not changed."];
            }else{
                //update pwm dutyCycle
                uint8_t value[]={currentPinIndex,currentDriveValue,(int)self.dutyCycleSlider.value};
                [self.delegate updatePwmConfiguration:MANAGE_ID_INTERFACE_ADD pwmIndex:currentChannelIndex withDutyCycle:[NSData dataWithBytes:&value length:sizeof(value)]];
            }
        }else{
            //delete pin configuration
            uint8_t value[]={0,0,0};
            [self.pwmPinPickerView selectRow:0 inComponent:0 animated:NO];
            [self.pwmDrivePickerView selectRow:0 inComponent:0 animated:NO];
            [self.dutyCycleSlider setValue:0*1.0f];
            self.dutyCycleValue.text= [NSString stringWithFormat:@"%d%%",0];
            [self.delegate updatePwmConfiguration:MANAGE_ID_INTERFACE_DELETE pwmIndex:currentChannelIndex withDutyCycle:[NSData dataWithBytes:&value length:sizeof(value)]];
        }
    }else{
        if(self.enableSwitch.on){
            uint8_t value[]={currentPinIndex,currentDriveValue,(int)self.dutyCycleSlider.value};
            [self.delegate updatePwmConfiguration:MANAGE_ID_INTERFACE_ADD pwmIndex:currentChannelIndex withDutyCycle:[NSData dataWithBytes:&value length:sizeof(value)]];
        }else{
            [Utility showAlert:@"Not Configured."];
        }
    }
}


- (IBAction)didClickLockAndSavePwmPinButton:(id)sender {
    self.isLocked = !self.isLocked;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setBool:self.isLocked forKey:@"deviceLocked"];
    [defaults synchronize];
    
    if(self.isLocked){
        NSLog(@"After clicking save, lock device configuration");
        [sender setImage:[UIImage imageNamed:@"tick_checkbox.png"] forState:UIControlStateNormal];
    }else{
        NSLog(@"After clicking save, do not lock device configuration");
        [sender setImage:[UIImage imageNamed:@"unticked_checkbox.png"] forState:UIControlStateNormal];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIPickerViewDataSource
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([pickerView isEqual:self.pwmChannelPickerView]){
        return [pwmChannelArray count];
    }else if([pickerView isEqual:self.pwmPinPickerView]){
        return [pwmPinArray count];
    }else{
        return [pwmDriveArray count];
    }
}

#pragma mark - UIPickerViewDelegate
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *pickerLabel =(UILabel *)view;
    if(!pickerLabel){
        pickerLabel =[[UILabel alloc] init];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    }
    if([pickerView isEqual:self.pwmChannelPickerView]){
        [pickerLabel setText:[NSString stringWithFormat:@"%ld",(long)[pwmChannelArray[row] integerValue]]];
    }else if([pickerView isEqual:self.pwmPinPickerView]){
        [pickerLabel setText:[NSString stringWithFormat:@"%ld",(long)[pwmPinArray[row] integerValue]]];
    }else{
        [pickerLabel setText:pwmDriveArray[row]];
    }
    
    return pickerLabel;

    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if([pickerView isEqual:self.pwmChannelPickerView]){
        currentChannelIndex =row;
        [[NSUserDefaults standardUserDefaults] setInteger:currentChannelIndex forKey:@"pwmChannelIndex"];
        NSString *dutyCycleString = @"";
        if([self.pwmConfiguration[currentChannelIndex][0] boolValue]){
            [self.enableSwitch setOn:YES];
            currentPinIndex = [self.pwmConfiguration[currentChannelIndex][1] integerValue];
            currentDriveValue =[self.pwmConfiguration[currentChannelIndex][2] integerValue];
            
            [self.pwmPinPickerView setUserInteractionEnabled:YES];
            [self.pwmPinPickerView selectRow:currentPinIndex inComponent:0 animated:NO];
            
            [self.pwmDrivePickerView setUserInteractionEnabled:YES];
            [self.pwmDrivePickerView selectRow:currentDriveValue inComponent:0 animated:NO];
            
            int dutyCycle =(int)[self.pwmConfiguration[currentChannelIndex][3] integerValue];
            
            [self.dutyCycleSlider setUserInteractionEnabled:YES];
            if(dutyCycle ==0){
                dutyCycleString= [NSString stringWithFormat:@"%@%%",@(0)];
            }else if(dutyCycle ==100){
                dutyCycleString= [NSString stringWithFormat:@"%@%%",@(100)];
            }else{
                dutyCycleString= [NSString stringWithFormat:@"%d%%",dutyCycle];
            }
            [self.dutyCycleSlider setValue:(dutyCycle*1.0)];
            
        }else{
            [self.enableSwitch setOn:NO];
            
            [self.pwmPinPickerView setUserInteractionEnabled:NO];
            [self.pwmPinPickerView selectRow:0 inComponent:0 animated:NO];
            
            [self.pwmDrivePickerView setUserInteractionEnabled:NO];
            [self.pwmDrivePickerView selectRow:0 inComponent:0 animated:NO];
            
            dutyCycleString = @"0%";
            [self.dutyCycleSlider setValue:0.0];
            [self.dutyCycleSlider setUserInteractionEnabled:NO];
        }
        self.dutyCycleValue.text = dutyCycleString;
    }else if([pickerView isEqual:self.pwmPinPickerView]){
        currentPinIndex =row;
        if(self.enableSwitch.on){
            [self.pwmPinPickerView selectRow:row inComponent:0 animated:NO];
        }else{
           [self.pwmPinPickerView selectRow:0 inComponent:0 animated:NO];
        }
    }else if([pickerView isEqual:self.pwmDrivePickerView]){
        currentDriveValue =row;
        currentPinIndex =row;
        if(self.enableSwitch.on){
            [self.pwmDrivePickerView selectRow:row inComponent:0 animated:NO];
        }else{
            [self.pwmDrivePickerView selectRow:0 inComponent:0 animated:NO];
        }
    }
}

@end
