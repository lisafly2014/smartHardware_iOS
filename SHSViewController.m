//
//  SHSViewController.m
//  SHSApplication
//
//  Created by Simon Third on 04/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "SHSViewController.h"
#import "ScannerViewController.h"
#import "InterfaceTableViewController.h"
#import "Utility.h"
#import "SHSOperations.h"

@interface SHSViewController ()
@property (weak, nonatomic) IBOutlet UIButton *findHardwareButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectHwButton;

@property(strong,nonatomic)SHSOperations *shsOperations;
/*
 This property is set when the hardware has been selected on the Scanner view Controller.
 */
@property(strong,nonatomic) CBPeripheral *selectedPeripheral;
@property BOOL isConnected;
@property BOOL isErrorKnown;
@property BOOL isTimeOut;

@end

@implementation SHSViewController
@synthesize selectedPeripheral;
@synthesize shsOperations;
@synthesize showInterfaceButton;
@synthesize hardwareName;
@synthesize interfaceDelegate;
@synthesize timer;


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        shsOperations = [[SHSOperations alloc] initWithDelegate: self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
    
}

-(void)initUI{
    self.hardwareName.text =@"";
    self.showInterfaceButton.hidden =YES;
    self.showInterfaceButton.enabled = NO;
    
    
    self.disconnectHwButton.hidden = YES;
    self.disconnectHwButton.enabled =NO;
    [self.findHardwareButton setTitle:@"Find Hardware" forState:UIControlStateNormal];
}

-(void)clearUI{
    self.selectedPeripheral = nil;
    
    self.hardwareName.text =@"";
    self.findHardwareButton.hidden = NO;
    self.findHardwareButton.enabled = YES;
    [self.findHardwareButton setTitle:@"Find Hardware" forState:UIControlStateNormal];
    
    self.showInterfaceButton.hidden =YES;
    self.showInterfaceButton.enabled = NO;
    
    self.disconnectHwButton.hidden = YES;
    self.disconnectHwButton.enabled =NO;
}



- (IBAction)onDisconnectHwClicked:(id)sender {
    [self.shsOperations disconnectPheripheral];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)appDidEnterBackground:(NSNotification *)_notification
{
    NSLog(@"appDidEnterBackground");
    [self.shsOperations disconnectPheripheral];
}

-(void)appDidEnterForeground:(NSNotification *)_notification
{
    NSLog(@"appDidEnterForeground");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

-(void)showAlert:(NSString *)message
{
    UIAlertController *alert= [UIAlertController alertControllerWithTitle:@"SHS" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok =[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [alert dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popToRootViewControllerAnimated:NO];

    }];
    [alert addAction:ok];
    [self presentViewController:alert  animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"scan"]){
        // Set this contoller as scanner delegate
        ScannerViewController *controller = (ScannerViewController *)segue.destinationViewController;
        
       // controller.filterUUID = [CBUUID UUIDWithString:shsServiceUUIDString];
        controller.delegate =self;
    }
    else if([segue.identifier isEqualToString:@"interface"]){
        InterfaceTableViewController *controller =(InterfaceTableViewController *)segue.destinationViewController;
        controller.interfaceDelegate =self;
        //Set this controller as interface configuration delegate
        controller.dinConfiguration = shsOperations.dinConfigurationArray;
        controller.dinCurrentStatus = shsOperations.dinCurrentStatusArray;
        controller.doutConfiguration = shsOperations.doutConfigurationArray;
        controller.doutCurrentStatus = shsOperations.doutCurrentStatusArray;
        controller.ainConfiguration = shsOperations.ainConfigurationArray;
        controller.ainCurrentStatus = shsOperations.ainCurrentStatusArray;
        controller.pwmConfiguration = shsOperations.pwmConfigurationArray;
        controller.pwmCurrentDutyCycle = shsOperations.pwmCurrentDutyCycleArray;
        controller.servoConfiguration = shsOperations.servoConfigurationArray;
        controller.servoCurrentPercentage = shsOperations.servoCurrentPercentageArray;
        NSLog(@"shsViewController:%lu,with shsOperations:%lu",controller.doutConfiguration.count,shsOperations.doutConfigurationArray.count);
    }
}


#pragma mark Device Selection Delegate
-(void)centralManager:(CBCentralManager *)manager didPeripheralSelected:(CBPeripheral *)peripheral
{
    NSLog(@"didPeripheralSelected with: %@",peripheral.name);
    selectedPeripheral = peripheral;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.findHardwareButton setTitle:@"Connecting..." forState:UIControlStateNormal];
        self.findHardwareButton.enabled = NO;
    });
        
    [shsOperations setCentralManager:manager];
   
    [shsOperations connectDevice:peripheral];
}

#pragma mark SHSOperations delegate methods
-(void)onDeviceConnected:(CBPeripheral *)peripheral
{
    NSLog(@"onDeviceConnected %@",peripheral.name);
    self.isConnected = YES;
    self.isErrorKnown = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
         self.hardwareName.text = peripheral.name;

        
        self.findHardwareButton.hidden = YES;
        self.findHardwareButton.enabled = NO;
        [self.findHardwareButton setTitle:@"Find Hardware" forState:UIControlStateNormal];
        
        self.showInterfaceButton.hidden = NO;
        [self.showInterfaceButton setTitle:@"Get configuration, waiting....." forState:UIControlStateNormal];
        
        self.disconnectHwButton.hidden = NO;
        self.disconnectHwButton.enabled =YES;

    });
    
    
    //Following if condition display user permission alert for background notification
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound categories:nil]];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    timer =[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(onFire:) userInfo:nil repeats:NO];
    [shsOperations getDeviceConfiguration];
}

-(void) onFire:(NSTimer *) timer{
    self.isTimeOut =YES;
    [self.shsOperations disconnectPheripheral];
}

-(void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
    NSLog(@"device disconnected %@",peripheral.name);
    self.isConnected =NO;
    dispatch_async(dispatch_get_main_queue(), ^{

         if ([Utility isApplicationStateInactiveORBackground]) {
            [Utility showBackgroundNotification:[NSString stringWithFormat:@"%@Peripheral Disconnected.",peripheral.name]];
            [self.navigationController popToRootViewControllerAnimated:NO];
         }
         else {
             if(self.isTimeOut){
                 self.isTimeOut = NO;
                 [self showAlert:@"Reading device configuratiion timeout."];
             }else{
               [self showAlert:@"peripheral is disconnected"];  
             }
            
         }
        
        
         [self clearUI];
         [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
         [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        
    });
    
}

-(void)onError:(NSString *)errorMessage
{
    NSLog(@"OnError %@",errorMessage);
    self.isErrorKnown = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [Utility showAlert:errorMessage];
        [self clearUI];
    });
  
}

-(void)onErrorMessage:(NSString *)errorMessage{
    NSLog(@"onErrorMessage %@",errorMessage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [Utility showAlert:errorMessage];
   });
}

-(void)onGetDeviceInterfaceConfiguration
{
    [timer invalidate];
    timer =nil;
    NSLog(@"onGetDeviceInterfaceConfiguration");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.showInterfaceButton setTitle:@"Show Interface" forState:UIControlStateNormal];
        self.showInterfaceButton.enabled = YES;
    });
}

-(void)onConnectionTimeOut{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlert:@"connection time out."];
        [self clearUI];
    });
}

#pragma mark -- InterfaceTableVCDelegate
-(void)didUpdateInterfaceValue:(uint8_t)pinIndex interfaceType:(uint8_t)type{
     [self.shsOperations updateInterfaceValue:pinIndex interfaceType:type];
}

-(void)didUpdatePinConfiguration:(uint8_t)command withPinIndex:(uint8_t)pinIndex withConfigure:(NSData *)configureValue fromInterface:(uint8_t)interfaceType{
    if(!self.isConnected){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert:@"Cannot update configuration when connection lost"];
        });
    }else{
        [self.shsOperations unlockDevice:command pinIndex:pinIndex withConfigure:configureValue fromInterface:interfaceType];
    }
}
@end


