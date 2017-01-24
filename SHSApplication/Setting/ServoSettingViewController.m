//
//  ServoSettingViewController.m
//  SHSApplication
//
//  Created by Simon Third on 06/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "ServoSettingViewController.h"
#import "Utility.h"

@interface ServoSettingViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *servoChannelPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *servoPinPickerView;

@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *servoDrivePickerView;


@property (weak, nonatomic) IBOutlet UISlider *percentageSlider;
@property (weak, nonatomic) IBOutlet UILabel *percentageValue;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (weak, nonatomic) IBOutlet UIButton *lockAndSaveButton;

@end

@implementation ServoSettingViewController
@synthesize servoConfiguration;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initServoSetting];
    
    self.servoChannelPickerView.dataSource =self;
    self.servoChannelPickerView.delegate =self;
    self.servoChannelPickerView.showsSelectionIndicator = YES;
    
    self.servoPinPickerView.dataSource =self;
    self.servoPinPickerView.delegate =self;
    self.servoPinPickerView.showsSelectionIndicator = YES;
    
    self.servoDrivePickerView.dataSource =self;
    self.servoDrivePickerView.delegate =self;
    self.servoDrivePickerView.showsSelectionIndicator = YES;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    if(![[[defaults dictionaryRepresentation] allKeys] containsObject:@"deviceLocked"]){
        self.isLocked =YES;
    }else{
        self.isLocked = [defaults boolForKey:@"deviceLocked"];
    }
    
    currentChannelIndex = [defaults integerForKey:@"servoChannelIndex"];
    currentPinIndex = [self.servoConfiguration[currentChannelIndex][1] integerValue];
    currentDriveValue = [self.servoConfiguration[currentChannelIndex][2] integerValue];
    
    [self.servoChannelPickerView  selectRow:currentChannelIndex inComponent:0 animated:NO];
    
    if([self.servoConfiguration[currentChannelIndex][0] boolValue]){
        [self.enableSwitch setOn:YES];
        
        [self.servoPinPickerView setUserInteractionEnabled:YES];
        [self.servoPinPickerView  selectRow:currentPinIndex inComponent:0 animated:NO];
        
        [self.servoDrivePickerView setUserInteractionEnabled:YES];
        [self.servoDrivePickerView  selectRow:currentDriveValue inComponent:0 animated:NO];
        
        int percentage =(int)[self.servoConfiguration[currentChannelIndex][3] integerValue];
        
        [self.percentageSlider setUserInteractionEnabled:YES];
        [self.percentageSlider setValue: percentage*1.0f];
        
        self.percentageValue.text= [NSString stringWithFormat:@"%d%%",percentage];
        
    }else{
        [self.enableSwitch setOn:NO];
        
        [self.servoPinPickerView setUserInteractionEnabled:NO];
        [self.servoPinPickerView  selectRow:0 inComponent:0 animated:NO];
        
        [self.servoDrivePickerView setUserInteractionEnabled:NO];
        [self.servoDrivePickerView  selectRow:0 inComponent:0 animated:NO];
        
        [self.percentageSlider setValue: 0*1.0f];
        self.percentageValue.text= [NSString stringWithFormat:@"%d%%",0];
        [self.percentageSlider setUserInteractionEnabled:NO];
    }
}

-(void)initServoSetting{
    NSArray *servoChannelList=[[NSArray alloc] initWithObjects:@0,@1,@2,@3,nil];
    servoChannelArray =[NSMutableArray arrayWithArray:servoChannelList];
    
    NSArray *servoPinList=[[NSArray alloc] initWithObjects:@0,@1,@2,@3,
                            @4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,
                            @17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,
                            @29,@30,@31,nil];
    servoPinArray =[NSMutableArray arrayWithArray:servoPinList];
    
    NSArray *driveList = [[NSArray alloc] initWithObjects:@"S0S1",@"H0S1",
                          @"S0H1",@"H0H1",@"D0S1",@"D0H1",@"S0D1",@"H0D1", nil];
    servoDriveArray = [NSMutableArray arrayWithArray:driveList];
}

//-(void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didChangedServoPinStatus:(id)sender {
    if(self.enableSwitch.on){
        NSLog(@"servo switch is on.");
        [self.servoPinPickerView setUserInteractionEnabled:YES];
        [self.servoDrivePickerView setUserInteractionEnabled:YES];
        [self.percentageSlider setUserInteractionEnabled:YES];
    }else{
        NSLog(@"servo switch is off");
    }
}

- (IBAction)changeServoDefaultPercentage:(id)sender {
    int percentage;
    [self.percentageSlider setValue:(int) (self.percentageSlider.value +0.5) animated:NO];

    percentage = (int)self.percentageSlider.value;
    
    self.percentageValue.text = [NSString stringWithFormat:@"%d%%",percentage];
}
- (IBAction)didClickServoSaveButton:(id)sender {
    if([self.servoConfiguration[currentChannelIndex][0] boolValue]){
        if(self.enableSwitch.on){
            if(([self.servoConfiguration[currentChannelIndex][1] integerValue] == currentPinIndex)&&([self.servoConfiguration[currentChannelIndex][2] integerValue]== currentDriveValue)&&((int)[self.servoConfiguration[currentChannelIndex][3] integerValue] ==(int)self.percentageSlider.value)){
                //keep the same
                [Utility showAlert:@"Configuration has not changed."];
            }else{
                //update servo percentage
                uint8_t value[]={currentPinIndex,currentDriveValue,(int)self.percentageSlider.value};
                [self.delegate updateServoConfiguration:MANAGE_ID_INTERFACE_ADD servoIndex:currentChannelIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
            }
        }else{
            //delete pin configuration
            uint8_t value[]={0,0,0};
           [self.servoPinPickerView  selectRow:0 inComponent:0 animated:NO];
            [self.servoDrivePickerView selectRow:0 inComponent:0 animated:NO];
            [self.percentageSlider setValue: 0*1.0f];
            self.percentageValue.text= [NSString stringWithFormat:@"%d%%",0];
            [self.delegate updateServoConfiguration:MANAGE_ID_INTERFACE_DELETE servoIndex:currentChannelIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
        }
    }else{
        if(self.enableSwitch.on){
            uint8_t value[]={currentPinIndex,currentDriveValue,(int)self.percentageSlider.value};
            [self.delegate updateServoConfiguration:MANAGE_ID_INTERFACE_ADD servoIndex:currentChannelIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
        }else{
            [Utility showAlert:@"Not Configured."];
        }
    }    
}

- (IBAction)didClickLockAndSaveServoPinButton:(id)sender {
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

#pragma mark - UIPickerViewDataSource
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([pickerView isEqual:self.servoChannelPickerView]){
        return [servoChannelArray count];
    }else if([pickerView isEqual:self.servoPinPickerView]){
        return [servoPinArray count];
    }else if([pickerView isEqual:self.servoDrivePickerView]){
        return [servoDriveArray count];
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *pickerLabel =(UILabel *)view;
    if(!pickerLabel){
        pickerLabel =[[UILabel alloc] init];
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
    }
    if([pickerView isEqual:self.servoChannelPickerView]){
        [pickerLabel setText:[NSString stringWithFormat:@"%ld",(long)[servoChannelArray[row] integerValue]]];
    }else if([pickerView isEqual:self.servoPinPickerView]){
        [pickerLabel setText:[NSString stringWithFormat:@"%ld",(long)[servoPinArray[row] integerValue]]];
    }else{
        [pickerLabel setText:servoDriveArray[row]];
    }
    return pickerLabel;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    if([pickerView isEqual:self.servoChannelPickerView]){
        currentChannelIndex =row;
        [[NSUserDefaults standardUserDefaults] setInteger:currentChannelIndex forKey:@"servoChannelIndex"];
         NSString *percentageString = @"";
        if([self.servoConfiguration[currentChannelIndex][0] boolValue]){
            [self.enableSwitch setOn:YES];
            
            currentPinIndex = [self.servoConfiguration[currentChannelIndex][1] integerValue];
            currentDriveValue = [self.servoConfiguration[currentChannelIndex][2] integerValue];
            
            [self.servoPinPickerView setUserInteractionEnabled:YES];
            [self.servoPinPickerView selectRow:currentPinIndex inComponent:0 animated:NO];
            
            [self.servoDrivePickerView setUserInteractionEnabled:YES];
            [self.servoDrivePickerView selectRow:currentDriveValue inComponent:0 animated:NO];
            
            int percentage =(int)[self.servoConfiguration[currentChannelIndex][3] integerValue];
            
            if(percentage ==0){
                percentageString= [NSString stringWithFormat:@"%@%%",@(0)];
            }else if(percentage ==100){
                percentageString= [NSString stringWithFormat:@"%@%%",@(100)];
            }else{
                percentageString= [NSString stringWithFormat:@"%d%%",percentage];
            }
            [self.percentageSlider setUserInteractionEnabled:YES];
            [self.percentageSlider setValue:(percentage*1.0)];
            
        }else{
            [self.enableSwitch setOn:NO];
            [self.servoPinPickerView setUserInteractionEnabled:NO];
            [self.servoPinPickerView selectRow:0 inComponent:0 animated:NO];
            
            [self.servoDrivePickerView setUserInteractionEnabled:NO];
            [self.servoDrivePickerView selectRow:0 inComponent:0 animated:NO];
            
            percentageString = @"0%";
            [self.percentageSlider setValue:0.0];
            [self.percentageSlider setUserInteractionEnabled:NO];
        }
         self.percentageValue.text= percentageString;
        
    }else if([pickerView isEqual:self.servoPinPickerView]){
        currentPinIndex =row;
        if(self.enableSwitch.on){
            [self.servoPinPickerView selectRow:row inComponent:0 animated:NO];
            
        }else{
            [self.servoPinPickerView selectRow:0 inComponent:0 animated:NO];
        }
        
    }else if([pickerView isEqual:self.servoDrivePickerView]){
        currentDriveValue =row;
        if(self.enableSwitch.on){
            [self.servoDrivePickerView selectRow:row inComponent:0 animated:NO];
        }else{
            [self.servoDrivePickerView selectRow:0 inComponent:0 animated:NO];
        }
        
    }
}

@end
