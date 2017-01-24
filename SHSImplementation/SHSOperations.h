//
//  SHSOperations.h
//  SHSApplication
//
//  Created by Simon Third on 03/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEOperations.h"
#import "Utility.h"

@class SHSOperations;

//define protocol for the delegate
@protocol SHSOperationsDelegate

//define protocol functions that can be used in any class using this delegate
-(void)onDeviceConnected:(CBPeripheral *)peripheral;
-(void)onDeviceDisconnected:(CBPeripheral *)peripheral;
-(void)onError:(NSString *)errorMessage;
-(void)onGetDeviceInterfaceConfiguration;//-(void)onSHSCancelled;
-(void)onErrorMessage:(NSString *)errorMessage;
-(void)onConnectionTimeOut;

@end

@interface SHSOperations : NSObject <BLEOperationsDelegate>{
    uint8_t command;
    uint8_t functionID;
}



@property(strong,nonatomic)CBPeripheral *bluetoothPeripheral;
@property (strong,nonatomic)CBCharacteristic *shsSendCharacteristic;
@property (strong, nonatomic)CBCharacteristic *shsReceiveCharacteristic;
@property (strong,nonatomic)BLEOperations *bleOperations;

@property(strong,nonatomic)NSMutableArray *dinConfigurationArray;
@property(strong,nonatomic)NSMutableArray *dinCurrentStatusArray;
@property(strong,nonatomic)NSMutableArray *doutConfigurationArray;
@property(strong,nonatomic)NSMutableArray *doutCurrentStatusArray;
@property(strong,nonatomic)NSMutableArray *ainConfigurationArray;
@property(strong,nonatomic)NSMutableArray *ainCurrentStatusArray;
@property(strong,nonatomic)NSMutableArray *pwmConfigurationArray;
@property(strong,nonatomic)NSMutableArray *pwmCurrentDutyCycleArray;
@property(strong,nonatomic)NSMutableArray *servoConfigurationArray;
@property(strong,nonatomic)NSMutableArray *servoCurrentPercentageArray;
@property(strong,nonatomic)NSMutableArray * cmdArray;
@property (nonatomic) bool isLocked;
@property(nonatomic) bool initFinished;
@property (strong,nonatomic) NSData * shshConfigureValue;

//define delegate property
@property (nonatomic,assign)id<SHSOperationsDelegate> shsDelegate;

-(SHSOperations *)initWithDelegate:(id<SHSOperationsDelegate>)delegate;

//define public methods
-(void)setCentralManager:(CBCentralManager *)manager;
-(void)connectDevice:(CBPeripheral *)peripheral;
-(void)getDeviceConfiguration;
-(void)updateInterfaceValue:(uint8_t) pinNumber interfaceType:(uint8_t)type;
-(void)unlockDevice:(uint8_t)cmd pinIndex:(uint8_t)index withConfigure:(NSData *)configureValue fromInterface:(uint8_t)interfaceType;

-(void)disconnectPheripheral;

@end
