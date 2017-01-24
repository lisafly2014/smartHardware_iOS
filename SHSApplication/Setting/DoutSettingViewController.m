//
//  DoutSettingViewController.m
//  SHSApplication
//
//  Created by Simon Third on 21/07/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "DoutSettingViewController.h"
#import "Utility.h"

@interface DoutSettingViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *ouputPinPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *pullPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *drivePickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *defaultPickerView;

@property (weak, nonatomic) IBOutlet UIButton *saveButtn;
@end

@implementation DoutSettingViewController

@synthesize doutConfiguration;
@synthesize ouputPinPickerView;
@synthesize pullPickerView;
@synthesize drivePickerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initOutputPinSetting];
    
    self.ouputPinPickerView.dataSource =self;
    self.ouputPinPickerView.delegate =self;
    self.ouputPinPickerView.showsSelectionIndicator =YES;
    
    
    self.pullPickerView.dataSource =self;
    self.pullPickerView.delegate =self;
    self.pullPickerView.showsSelectionIndicator = YES;
    
    self.drivePickerView.dataSource =self;
    self.drivePickerView.delegate =self;
    self.drivePickerView.showsSelectionIndicator =YES;
    
    self.defaultPickerView.dataSource =self;
    self.defaultPickerView.delegate =self;
    self.defaultPickerView.showsSelectionIndicator =YES;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    if(![[[defaults dictionaryRepresentation] allKeys] containsObject:@"deviceLocked"]){
        self.isLocked =YES;
    }else{
        self.isLocked = [defaults boolForKey:@"deviceLocked"];
    }
    
    currentDoutIndex = [defaults integerForKey:@"outputPinPicker"];
    currentPullValue = [self.doutConfiguration[currentDoutIndex][1] integerValue];
    currentDriveValue = [self.doutConfiguration[currentDoutIndex][2] integerValue];
    currentDefaultValue =[self.doutConfiguration[currentDoutIndex][3] integerValue];
    
    [self.ouputPinPickerView selectRow:currentDoutIndex inComponent:0 animated:NO];
    
    if([self.doutConfiguration[currentDoutIndex][0] boolValue]){
        [self.enableSwitch setOn:YES];
        
        [self.pullPickerView setUserInteractionEnabled:YES];
        [self.pullPickerView selectRow:currentPullValue inComponent:0 animated:NO];
        
        [self.drivePickerView setUserInteractionEnabled:YES];
        [self.drivePickerView selectRow:currentDriveValue inComponent:0 animated:NO];
        
        [self.defaultPickerView setUserInteractionEnabled:YES];
        [self.defaultPickerView selectRow:currentDefaultValue inComponent:0 animated:NO];
    }else{
        [self.enableSwitch setOn:NO];
        
        [self.pullPickerView setUserInteractionEnabled:NO];
        [self.pullPickerView selectRow:0 inComponent:0 animated:NO];
        
        [self.drivePickerView setUserInteractionEnabled:NO];
        [self.drivePickerView selectRow:0 inComponent:0 animated:NO];
        
        [self.defaultPickerView setUserInteractionEnabled:NO];
        [self.defaultPickerView selectRow:0 inComponent:0 animated:NO];
    }
}
-(void)initOutputPinSetting{
    NSArray *outPinList =[[NSArray alloc] initWithObjects:@0,@1,@2,@3,
                          @4,@5,@6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,
                          @17,@18,@19,@20,@21,@22,@23,@24,@25,@26,@27,@28,
                          @29,@30,@31,nil];
    pinArray =[NSMutableArray arrayWithArray:outPinList];
    
    NSArray *pullList =[[NSArray alloc] initWithObjects:@"No Pull",@"Pull Down",@"Pull Up", nil];
    pullArray =[NSMutableArray arrayWithArray:pullList];
    
    NSArray *driveList = [[NSArray alloc] initWithObjects:@"S0S1",@"H0S1",
                          @"S0H1",@"H0H1",@"D0S1",@"D0H1",@"S0D1",@"H0D1", nil];
    driveArray = [NSMutableArray arrayWithArray:driveList];
    
    NSArray *defaultList =[[NSArray alloc] initWithObjects:@"Low",@"High",nil];
    defaultArray =[NSMutableArray arrayWithArray:defaultList];
    
}

- (IBAction)didChangedOutputPinStatus:(id)sender {
    if(self.enableSwitch.on){
        NSLog(@"output pin switch is on.");
        [self.pullPickerView setUserInteractionEnabled:YES];
        [self.drivePickerView setUserInteractionEnabled:YES];
        [self.defaultPickerView setUserInteractionEnabled:YES];
    }else{
        NSLog(@"output pin switch is off");
    }
}

- (IBAction)didClickSaveOutputPinButton:(id)sender {
    if([self.doutConfiguration[currentDoutIndex][0] boolValue]){
        if(self.enableSwitch.on){
            if((([self.doutConfiguration[currentDoutIndex][1] integerValue]) ==currentPullValue)&&(([self.doutConfiguration[currentDoutIndex][2] integerValue])==currentDriveValue)&&([self.doutConfiguration[currentDoutIndex][3] integerValue]==currentDefaultValue)){ //keep the same
                [Utility showAlert:@"Configuration has not changed."];
            }else{ //update configuration
                uint8_t value[]={currentPullValue|(currentDriveValue <<2),currentDefaultValue};
                [self.delegate updateOutpinConfiguration:MANAGE_ID_INTERFACE_ADD pinIndex:currentDoutIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
            }
        }else{ //delete pin configuration
            uint8_t value[]={0,0};
            [self.pullPickerView selectRow:0 inComponent:0 animated:NO];
            [self.drivePickerView selectRow:0 inComponent:0 animated:NO];
            [self.defaultPickerView selectRow:0 inComponent:0 animated:NO];
            [self.delegate updateOutpinConfiguration:MANAGE_ID_INTERFACE_DELETE pinIndex:currentDoutIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
        }
    }else{
        if(self.enableSwitch.on){
            //add new pin configuration
            uint8_t value[]={currentPullValue|(currentDriveValue <<2),currentDefaultValue};
            [self.delegate updateOutpinConfiguration:MANAGE_ID_INTERFACE_ADD pinIndex:currentDoutIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
        }else{
            [Utility showAlert:@"Not Configured."];
        }
    }
}

- (IBAction)didClickLockAndSaveOutputPinButton:(id)sender {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIPickerViewDataSource
-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if([pickerView isEqual:self.ouputPinPickerView]){
        return [pinArray count];
    }else if([pickerView isEqual:self.pullPickerView]){
        return [pullArray count];
    }else if([pickerView isEqual:self.drivePickerView]){
        return [driveArray count];
    }else if([pickerView isEqual:self.defaultPickerView]){
        return [defaultArray count];
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
    if([pickerView isEqual:self.ouputPinPickerView]){
        [pickerLabel setText:[NSString stringWithFormat:@"%ld",(long)[pinArray[row] integerValue]]];
    }else if([pickerView isEqual:self.pullPickerView]){
        [pickerLabel setText:pullArray[row]];
    }else if([pickerView isEqual:self.drivePickerView]){
        [pickerLabel setText:driveArray[row]];
    }else{
        [pickerLabel setText:defaultArray[row]];
    }
    return pickerLabel;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if([pickerView isEqual:self.ouputPinPickerView]){
        currentDoutIndex =row;
        [[NSUserDefaults standardUserDefaults] setInteger:currentDoutIndex forKey:@"outputPinPicker"];
        if([self.doutConfiguration[currentDoutIndex][0] boolValue]){
            [self.enableSwitch setOn:YES];
            
            currentPullValue = [self.doutConfiguration[currentDoutIndex][1] integerValue];
            currentDriveValue = [self.doutConfiguration[currentDoutIndex][2] integerValue] ;
            currentDefaultValue =[self.doutConfiguration[currentDoutIndex][3] integerValue];
            
            [self.pullPickerView setUserInteractionEnabled:YES];
            [self.pullPickerView selectRow:currentPullValue inComponent:0 animated:YES];
            
            [self.drivePickerView setUserInteractionEnabled:YES];
            [self.drivePickerView selectRow:currentDriveValue inComponent:0 animated:YES];
            
            [self.defaultPickerView setUserInteractionEnabled:YES];
            [self.defaultPickerView selectRow:currentDefaultValue inComponent:0 animated:YES];


            
        }else{
            [self.enableSwitch setOn:NO];
            
            [self.pullPickerView setUserInteractionEnabled:NO];
            [self.pullPickerView selectRow:0 inComponent:0 animated:YES];
            
            [self.drivePickerView setUserInteractionEnabled:NO];
            [self.drivePickerView selectRow:0 inComponent:0 animated:YES];
            
             [self.defaultPickerView setUserInteractionEnabled:NO];
            [self.defaultPickerView selectRow:0 inComponent:0 animated:YES];
        }
        
    }else if([pickerView isEqual:self.pullPickerView]){
        currentPullValue =row;
        if(self.enableSwitch.on){
            [self.pullPickerView selectRow:row inComponent:0 animated:NO];
            
        }else{
            [self.pullPickerView selectRow:0 inComponent:0 animated:NO];
        }
        
    }else if([pickerView isEqual:self.drivePickerView]){
        currentDriveValue =row;
        if(self.enableSwitch.on){
            [self.drivePickerView selectRow:row inComponent:0 animated:NO];
        }else{
            [self.drivePickerView selectRow:0 inComponent:0 animated:NO];
        }
        
    }else{
        currentDefaultValue =row;
        if(self.enableSwitch.on){
            [self.defaultPickerView selectRow:row inComponent:0 animated:NO];
        }else{
            [self.defaultPickerView selectRow:0 inComponent:0 animated:NO];
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
