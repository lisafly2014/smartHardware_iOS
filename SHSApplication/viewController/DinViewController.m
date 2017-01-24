//
//  DigitalInputViewController.m
//  SHSApplication
//
//  Created by Simon Third on 05/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "DinViewController.h"

@interface DinViewController ()

@property (weak, nonatomic) IBOutlet UIButton *pinIn0;
@property (weak, nonatomic) IBOutlet UIButton *pinIn1;
@property (weak, nonatomic) IBOutlet UIButton *pinIn2;
@property (weak, nonatomic) IBOutlet UIButton *pinIn3;
@property (weak, nonatomic) IBOutlet UIButton *pinIn4;
@property (weak, nonatomic) IBOutlet UIButton *pinIn5;
@property (weak, nonatomic) IBOutlet UIButton *pinIn6;
@property (weak, nonatomic) IBOutlet UIButton *pinIn7;
@property (weak, nonatomic) IBOutlet UIButton *pinIn8;
@property (weak, nonatomic) IBOutlet UIButton *pinIn9;
@property (weak, nonatomic) IBOutlet UIButton *pinIn10;
@property (weak, nonatomic) IBOutlet UIButton *pinIn11;
@property (weak, nonatomic) IBOutlet UIButton *pinIn12;
@property (weak, nonatomic) IBOutlet UIButton *pinIn13;
@property (weak, nonatomic) IBOutlet UIButton *pinIn14;
@property (weak, nonatomic) IBOutlet UIButton *pinIn15;
@property (weak, nonatomic) IBOutlet UIButton *pinIn16;
@property (weak, nonatomic) IBOutlet UIButton *pinIn17;
@property (weak, nonatomic) IBOutlet UIButton *pinIn18;
@property (weak, nonatomic) IBOutlet UIButton *pinIn19;
@property (weak, nonatomic) IBOutlet UIButton *pinIn20;
@property (weak, nonatomic) IBOutlet UIButton *pinIn21;
@property (weak, nonatomic) IBOutlet UIButton *pinIn22;
@property (weak, nonatomic) IBOutlet UIButton *pinIn23;
@property (weak, nonatomic) IBOutlet UIButton *pinIn24;
@property (weak, nonatomic) IBOutlet UIButton *pinIn25;
@property (weak, nonatomic) IBOutlet UIButton *pinIn26;
@property (weak, nonatomic) IBOutlet UIButton *pinIn27;
@property (weak, nonatomic) IBOutlet UIButton *pinIn28;
@property (weak, nonatomic) IBOutlet UIButton *pinIn29;
@property (weak, nonatomic) IBOutlet UIButton *pinIn30;
@property (weak, nonatomic) IBOutlet UIButton *pinIn31;

@property (strong,nonatomic)IBOutletCollection(UIButton) NSArray *inputPins;



@end

@implementation DinViewController
@synthesize dinConfiguration;
@synthesize dinCurrentStatus;
@synthesize inputPins;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.pinIn0.tag =0;
    self.pinIn1.tag =1;
    self.pinIn2.tag =2;
    self.pinIn3.tag =3;
    self.pinIn4.tag =4;
    self.pinIn5.tag =5;
    self.pinIn6.tag =6;
    self.pinIn7.tag =7;
    self.pinIn8.tag =8;
    self.pinIn9.tag =9;
    self.pinIn10.tag =10;
    self.pinIn11.tag =11;
    self.pinIn12.tag =12;
    self.pinIn13.tag =13;
    self.pinIn14.tag =14;
    self.pinIn15.tag =15;
    self.pinIn16.tag =16;
    self.pinIn17.tag =17;
    self.pinIn18.tag =18;
    self.pinIn19.tag =19;
    self.pinIn20.tag =20;
    self.pinIn21.tag =21;
    self.pinIn22.tag =22;
    self.pinIn23.tag =23;
    self.pinIn24.tag =24;
    self.pinIn25.tag =25;
    self.pinIn26.tag =26;
    self.pinIn27.tag =27;
    self.pinIn28.tag =28;
    self.pinIn29.tag =29;
    self.pinIn30.tag =30;    
    self.pinIn31.tag =31;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    for(UIButton *button in inputPins){
        [self setButtonImage:button withTag:(int)[button tag]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputPinStatusChanged) name:@"inputPinStatusChanged" object:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"inputPinStatusChanged" object:nil];

}


-(void)setButtonImage:(UIButton *)button withTag:(int) index{
    if(![self.dinConfiguration[index][0] boolValue]){
        [button setImage:[UIImage imageNamed:@"disable_checkbox.png"] forState:UIControlStateNormal];
        
    }else{
        if([self.dinCurrentStatus[index] integerValue] == 1){
            [button setImage:[UIImage imageNamed:@"checked_checkbox.png"] forState:UIControlStateNormal];
        }else if([self.dinCurrentStatus[index] integerValue] ==0){
            [button setImage:[UIImage imageNamed:@"unchecked_checkbox.png"] forState:UIControlStateNormal];
        }
        
    }
    
}

-(void)inputPinStatusChanged{
    for(UIButton *button in inputPins){
        [self setButtonImage:button withTag:(int)[button tag]];
    }
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"dinSetting"]){
        DinSettingViewController * controller =(DinSettingViewController *) segue.destinationViewController;
        controller.delegate =self;
        controller.dinConfiguration =self.dinConfiguration;
    }

    
}

#pragma  mark -- DinSettingDelegate
-(void)updateInputpinConfiguration:(uint8_t)command pinIndex:(uint8_t)inputPin withConfigure:(NSData *)configureValue{
    [self.dinDelegate  setInputPinConfiguration:command pinIndex:inputPin withConfigure:configureValue];
}

@end
