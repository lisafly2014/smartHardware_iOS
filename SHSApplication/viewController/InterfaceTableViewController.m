//
//  InterfaceTableViewController.m
//  SHSApplication
//
//  Created by Simon Third on 05/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "InterfaceTableViewController.h"
#import "DinViewController.h"
#import "DoutViewController.h"
#import "AinViewController.h"
#import "PwmViewController.h"
#import "ServoViewController.h"

@interface InterfaceTableViewController ()

@end

@implementation InterfaceTableViewController
@synthesize interfaceList;
@synthesize interfaceDelegate;
@synthesize dinConfiguration;
@synthesize dinCurrentStatus;
@synthesize doutConfiguration;
@synthesize doutCurrentStatus;
@synthesize ainConfiguration;
@synthesize ainCurrentStatus;
@synthesize pwmConfiguration;
@synthesize pwmCurrentDutyCycle;
@synthesize servoConfiguration;
@synthesize servoCurrentPercentage;


- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationItem.title =@"Choose Interface";
    self.interfaceList = [[NSMutableArray alloc] init];
    [self loadInitialInterface];
}

-(void)loadInitialInterface{
    NSArray *interfaceArray= @[@"Digital Input", @"Digital Output", @"Analog Input", @"PWM",@"Servo",
                               @"SPI",@"I2C",@"UART",@"RCS",@"QUAD"];
    [self.interfaceList addObjectsFromArray:interfaceArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"din"]){
        DinViewController *controller = (DinViewController *)segue.destinationViewController;
        controller.dinConfiguration = self.dinConfiguration;
        controller.dinCurrentStatus =self.dinCurrentStatus;
        controller.dinDelegate =self;
//        NSLog(@"din: %@",self.dinCurrentStatus);
        
    }else if([segue.identifier isEqualToString:@"dout"]){
        DoutViewController *controller =(DoutViewController *)segue.destinationViewController;
        controller.doutConfiguration =self.doutConfiguration;
        controller.doutCurrentStatus =self.doutCurrentStatus;
        controller.doutDelegate =self;
//        NSLog(@"dout:%@",controller.doutConfiguration);
    }else if([segue.identifier isEqualToString:@"ain"]){
        AinViewController  *controller =(AinViewController *)segue.destinationViewController;
        controller.ainConfiguration =self.ainConfiguration;
        controller.ainCurrentStatus = self.ainCurrentStatus;
        controller.ainDelegate =self;
    }else if([segue.identifier isEqualToString:@"pwm"]){
        PwmViewController *controller =(PwmViewController *)segue.destinationViewController;
        controller.pwmConfiguration = self.pwmConfiguration;
        controller.pwmCurrentDutyCycle =self.pwmCurrentDutyCycle;
        controller.pwmDelegate =self;

    }else if([segue.identifier isEqualToString:@"servo"]){
        ServoViewController *controller =(ServoViewController *)segue.destinationViewController;
        controller.servoConfiguration =self.servoConfiguration;
        controller.servoCurrentPercentage =self.servoCurrentPercentage;
        controller.servoDelegate = self;
    }
    
}

#pragma mark - DoutDelegate
-(void)didOuputPinChanged:(uint8_t)outputPinIndex{
    [self.interfaceDelegate  didUpdateInterfaceValue:outputPinIndex interfaceType:DOUT];
}

-(void)setOutputPinConfiguration:(uint8_t)command pinIndex:(uint8_t)dOutPin withConfigure:(NSData *)configureValue{
    [self.interfaceDelegate didUpdatePinConfiguration:command withPinIndex:dOutPin withConfigure:configureValue fromInterface:DOUT];
}

#pragma mark - DinDelegate

-(void)setInputPinConfiguration:(uint8_t)command pinIndex:(uint8_t)inputPin withConfigure:(NSData *)configureValue{
    [self.interfaceDelegate didUpdatePinConfiguration:command withPinIndex:inputPin withConfigure:configureValue fromInterface:DIN];
}

#pragma  mark - AinDelegate
-(void)setAnalogPinConfiguration:(uint8_t)command pinIndex:(uint8_t)analogPin withConfigure:(NSData *)configureValue{
      [self.interfaceDelegate didUpdatePinConfiguration:command withPinIndex: analogPin withConfigure:configureValue fromInterface: AIN];
}
#pragma mark - PwmDelegate
-(void)didMovePwmSlider:(uint8_t) pwmIndex{
    [self.interfaceDelegate didUpdateInterfaceValue:pwmIndex interfaceType:PWM];
}
-(void)setPwmConfiguration:(uint8_t)command pwmIndex:(uint8_t)index withDutyCycle:(NSData *)newDutyCycle{
    [self.interfaceDelegate didUpdatePinConfiguration:command withPinIndex: index withConfigure:newDutyCycle fromInterface: PWM];
}

#pragma mark - ServoDelegate
-(void)didMoveServoSlider:(uint8_t) servoIndex{
    [self.interfaceDelegate didUpdateInterfaceValue:servoIndex interfaceType:SERVO];
    
}
-(void)setServoConfiguration:(uint8_t)command pinIndex:(uint8_t)index withPercentage:(NSData *)newPercentage{
     [self.interfaceDelegate didUpdatePinConfiguration:command withPinIndex: index withConfigure:newPercentage fromInterface: SERVO];
}



#pragma mark Table View delegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.row){
        case 0:
            [self performSegueWithIdentifier:@"din" sender:self];
            break;
        case 1:
            [self performSegueWithIdentifier:@"dout" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"ain" sender:self];
            break;
        case 3:
            [self performSegueWithIdentifier:@"pwm" sender:self];
            break;
        case 4:
            [self performSegueWithIdentifier:@"servo" sender:self];
            break;
   }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.interfaceList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InterfaceCell" forIndexPath:indexPath];
    
    NSString *interface =[self.interfaceList objectAtIndex:indexPath.row];
    cell.textLabel.text = interface;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
