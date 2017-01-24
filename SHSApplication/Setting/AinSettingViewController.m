//
//  AinSettingViewController.m
//  SHSApplication
//
//  Created by Simon Third on 21/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "AinSettingViewController.h"
#import "Utility.h"

@interface AinSettingViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *analogPinPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;

@property (weak, nonatomic) IBOutlet UIPickerView *rangePickerView;

@property (weak, nonatomic) IBOutlet UIPickerView *ratePickerView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@end

@implementation AinSettingViewController

@synthesize ainConfiguration;
@synthesize analogPinPickerView;
@synthesize rangePickerView;
@synthesize ratePickerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAnalogPinSetting];
    
    self.analogPinPickerView.dataSource =self;
    self.analogPinPickerView.delegate =self;
    self.analogPinPickerView.showsSelectionIndicator = YES;
    
    self.rangePickerView.dataSource =self;
    self.rangePickerView.delegate = self;
    self.rangePickerView.showsSelectionIndicator = YES;
    
    self.ratePickerView.dataSource = self;
    self.ratePickerView.delegate =self;
    self.ratePickerView.showsSelectionIndicator = YES;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    if(![[[defaults dictionaryRepresentation] allKeys] containsObject:@"deviceLocked"]){
        self.isLocked =YES;
    }else{
        self.isLocked = [defaults boolForKey:@"deviceLocked"];
    }
    
    currentAinIndex = [defaults integerForKey:@"analogPinPicker"];
    currentRangeValue = [self.ainConfiguration[currentAinIndex][1] integerValue];
    currentRateValue = [self.ainConfiguration[currentAinIndex][2] integerValue];
    
    [self.analogPinPickerView  selectRow:currentAinIndex inComponent:0 animated:NO];
    
    if([self.ainConfiguration[currentAinIndex][0] boolValue]){
        [self.enableSwitch setOn:YES];
        [self.rangePickerView setUserInteractionEnabled:YES];
        [self.rangePickerView selectRow:currentRangeValue inComponent:0 animated:NO];
        
        [self.ratePickerView setUserInteractionEnabled:YES];
        [self.ratePickerView selectRow:currentRateValue inComponent:0 animated:NO];
        
    }else{
        [self.enableSwitch setOn:NO];
        [self.rangePickerView setUserInteractionEnabled:NO];
        [self.rangePickerView selectRow:0 inComponent:0 animated:NO];
        [self.ratePickerView setUserInteractionEnabled:NO];
        [self.ratePickerView selectRow:0 inComponent:0 animated:NO];
    }
}
-(void)initAnalogPinSetting{
    NSArray *analogPinList=[[NSArray alloc] initWithObjects:@1,@2,@3,@4,@5,@6, nil];
    analogPinArray =[NSMutableArray arrayWithArray:analogPinList];
    
    NSArray *rateList =[[NSArray alloc] initWithObjects:@"Disabled",@"100ms",@"1s",@"10s", nil];
    rateArray =[NSMutableArray arrayWithArray:rateList];
    
    NSArray *rangeList =[[NSArray alloc] initWithObjects:@"VDD",@"3.6V",@"1.2V", nil];
    rangeArray = [NSMutableArray arrayWithArray:rangeList];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didChangedAnalogPinStatus:(id)sender {
    if(self.enableSwitch.on){
        NSLog(@"analogue InputPin switch is on.");
        [self.rangePickerView setUserInteractionEnabled:YES];
        [self.ratePickerView setUserInteractionEnabled:YES];
    }else{
        NSLog(@"analogue InputPin switch is off");
    }
}


- (IBAction)didClickLockAndSaveAnalogPinButton:(id)sender {
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
- (IBAction)didClickSaveAnalogPinButton:(id)sender {
    if([self.ainConfiguration[currentAinIndex][0] boolValue]){
        if(self.enableSwitch.on){
            if((([self.ainConfiguration[currentAinIndex][1] integerValue] ==currentRangeValue)&&([self.ainConfiguration[currentAinIndex][2] integerValue])==currentRateValue)){
                //keep the same
                [Utility showAlert:@"Configuration has not changed."];
            }else{
                //update configuration
                uint8_t value={currentRangeValue|(currentRateValue <<2)};
                [self.delegate updateAnalogInputPinConfiguration:MANAGE_ID_INTERFACE_ADD pinIndex:currentAinIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
            }
        }else{
            //delete pin configuration
            uint8_t value[]={0};
            [self.rangePickerView selectRow:0 inComponent:0 animated:NO];
            [self.ratePickerView selectRow:0 inComponent:0 animated:NO];
            
            [self.delegate updateAnalogInputPinConfiguration:MANAGE_ID_INTERFACE_DELETE pinIndex:currentAinIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
        }
    }else{
        if(self.enableSwitch.on){
            uint8_t value[]={currentRangeValue|(currentRateValue <<2)};
            [self.delegate updateAnalogInputPinConfiguration:MANAGE_ID_INTERFACE_ADD pinIndex:currentAinIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
        }else{
            [Utility showAlert:@"Not Configured."];
        }
    }
}


#pragma mark - UIPickerViewDataSource
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([pickerView isEqual:self.analogPinPickerView]){
        return [analogPinArray count];
    }else if([pickerView isEqual:self.ratePickerView]){
        return [rateArray count];
    }else if([pickerView isEqual:self.rangePickerView]){
        return [rangeArray count];
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
    if([pickerView isEqual:self.analogPinPickerView]){
        [pickerLabel setText:[NSString stringWithFormat:@"%ld",(long)[analogPinArray[row] integerValue]]];
    }else if([pickerView isEqual:self.rangePickerView]){
        [pickerLabel setText:rangeArray[row]];
    }else if([pickerView isEqual:self.ratePickerView]){
        [pickerLabel setText:rateArray[row]];
    }
    
    return pickerLabel;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if([pickerView isEqual:self.analogPinPickerView]){
        currentAinIndex =row;
        [[NSUserDefaults standardUserDefaults] setInteger:currentAinIndex forKey:@"analogPinPicker"];
        if([self.ainConfiguration[currentAinIndex][0] boolValue]){
            [self.enableSwitch setOn:YES];
            
            currentRangeValue = [self.ainConfiguration[currentAinIndex][1] integerValue];
            currentRateValue = [self.ainConfiguration[currentAinIndex][2] integerValue];

            [self.rangePickerView setUserInteractionEnabled:YES];
            [self.rangePickerView selectRow:currentRangeValue inComponent:0 animated:YES];
            
            [self.ratePickerView setUserInteractionEnabled:YES];
            [self.ratePickerView selectRow:currentRateValue inComponent:0 animated:YES];

        }else{
            [self.enableSwitch setOn:NO];
            [self.rangePickerView setUserInteractionEnabled:NO];
            [self.rangePickerView selectRow:0 inComponent:0 animated:YES];
            
            [self.ratePickerView setUserInteractionEnabled:NO];
            [self.ratePickerView selectRow:0 inComponent:0 animated:YES];
        }
        
    }else if([pickerView isEqual:self.rangePickerView]){
        currentRangeValue =row;
        if(self.enableSwitch.on){
            [self.rangePickerView selectRow:row inComponent:0 animated:NO];
            
        }else{
            [self.rangePickerView selectRow:0 inComponent:0 animated:NO];
        }
        
    }else if([pickerView isEqual:self.ratePickerView]){
        currentRateValue =row;
        if(self.enableSwitch.on){
            [self.ratePickerView selectRow:row inComponent:0 animated:NO];
        }else{
            [self.ratePickerView selectRow:0 inComponent:0 animated:NO];
        }
        
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

@end
