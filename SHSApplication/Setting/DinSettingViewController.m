//
//  InputPinSettingViewController.m
//  SHSApplication
//
//  Created by Simon Third on 17/03/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "DinSettingViewController.h"
#import "Utility.h"

@interface  DinSettingViewController ()
@property (weak, nonatomic) IBOutlet UIPickerView *inputPinPickerView;
@property (weak, nonatomic) IBOutlet UISwitch *enableSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *pullPickerView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation DinSettingViewController
@synthesize  dinConfiguration;
@synthesize  inputPinPickerView;
@synthesize pullPickerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initInputPinSetting];
    
    self.inputPinPickerView.dataSource = self;
    self.inputPinPickerView.delegate = self;
    self.inputPinPickerView.showsSelectionIndicator = YES;
    
    self.pullPickerView.dataSource = self;
    self.pullPickerView.delegate = self;
    self.pullPickerView.showsSelectionIndicator = YES;
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    if(![[[defaults dictionaryRepresentation] allKeys] containsObject:@"deviceLocked"]){
        self.isLocked = YES;
    }else{
        self.isLocked =[defaults boolForKey:@"deviceLocked"];
    }
    
    currentDinIndex =[defaults integerForKey:@"inputPinPicker"];
    [self.inputPinPickerView selectRow:currentDinIndex inComponent:0 animated:NO];
    if([self.dinConfiguration[currentDinIndex][0] boolValue]){
        [self.enableSwitch setOn:YES];
        
        [self.pullPickerView setUserInteractionEnabled:YES];
        [self.pullPickerView selectRow:[self.dinConfiguration[currentDinIndex][1] integerValue] inComponent:0 animated:NO];
    }else{
        [self.enableSwitch setOn: NO];
        [self.pullPickerView setUserInteractionEnabled:NO];
        [self.pullPickerView selectRow:0 inComponent:0 animated:NO];
    }
    
    currentPullValue = [self.dinConfiguration[currentDinIndex][1] integerValue];
}

-(void)initInputPinSetting{
    NSArray *inputPinList= [[NSArray alloc] initWithObjects:@0,@1,@2,@3,@4,@5,
                            @6,@7,@8,@9,@10,@11,@12,@13,@14,@15,@16,@17,@18,@19,
                            @20,@21,@22,@23,@24,@25,@26,@27,@28,@29,@30,@31,nil];
    pinArray =[NSMutableArray arrayWithArray:inputPinList];
    
    NSArray *pullList = [[NSArray alloc] initWithObjects:@"No Pull",@"Pull Down",@"Pull Up", nil];
    pullArray = [NSMutableArray arrayWithArray:pullList];
}

- (IBAction)didChangedInputPinStatus:(id)sender {
    if(self.enableSwitch.on){
        NSLog(@"input pin switch is on.");
        [self.pullPickerView setUserInteractionEnabled:YES];
    }else{
        NSLog(@"input pin switch is off");
    }
}

- (IBAction)didClickSaveInputPinButton:(id)sender {
    
    if([self.dinConfiguration[currentDinIndex][0] boolValue]){
        if(self.enableSwitch.on){
            if([self.dinConfiguration[currentDinIndex][1] integerValue]==currentPullValue){ //keep the same
                [Utility showAlert:@"Configuration has not changed."];
            }else{ //update configuration
                uint8_t value[] ={currentPullValue};
                
                [self.delegate updateInputpinConfiguration:MANAGE_ID_INTERFACE_ADD pinIndex:currentDinIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
            }
        }else{ //delete pin configuration
            uint8_t value[]= {0};
            [self.pullPickerView selectRow:0 inComponent:0 animated:NO];
            [self.delegate updateInputpinConfiguration:MANAGE_ID_INTERFACE_DELETE pinIndex:currentDinIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];
            
        }
    }else{
        if(self.enableSwitch.on){
            //add new configuration
            uint8_t value[] ={currentPullValue};
            [self.delegate updateInputpinConfiguration:MANAGE_ID_INTERFACE_ADD pinIndex:currentDinIndex withConfigure:[NSData dataWithBytes:&value length:sizeof(value)]];

        }else{
            [Utility showAlert:@"Not Configured."];
        }
    }
}

- (IBAction)didClickLockAndSaveInputPinButton:(id)sender {
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
    if([pickerView isEqual:self.inputPinPickerView]){
        return [pinArray count];
    }else if([pickerView isEqual:self.pullPickerView]){
        return [pullArray count];
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
    if([pickerView isEqual:self.inputPinPickerView]){
        [pickerLabel setText:[NSString stringWithFormat:@"%ld",(long)[pinArray[row] integerValue]]];
    }else if([pickerView isEqual:self.pullPickerView]){
        [pickerLabel setText:pullArray[row]];
    }
    return pickerLabel;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if([pickerView isEqual:self.inputPinPickerView]){
        currentDinIndex =row;
       [[NSUserDefaults standardUserDefaults] setInteger:currentDinIndex forKey:@"inputPinPicker"];
        if([self.dinConfiguration[currentDinIndex][0] boolValue]){
            [self.enableSwitch setOn:YES];
            NSUInteger pullValue = [self.dinConfiguration[currentDinIndex][1] integerValue];

            [self.pullPickerView setUserInteractionEnabled:YES];
            [self.pullPickerView selectRow:pullValue inComponent:0 animated:YES];

        }else{
            [self.enableSwitch setOn:NO];
            [self.pullPickerView setUserInteractionEnabled:NO];
            [self.pullPickerView selectRow:0 inComponent:0 animated:YES];
        }
    }else if([pickerView isEqual:self.pullPickerView]){
        currentPullValue =row;
        if(self.enableSwitch.on){
            [self.pullPickerView selectRow:currentPullValue inComponent:0 animated:NO];
        }else{
            [self.pullPickerView selectRow:0 inComponent:0 animated:NO];
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
