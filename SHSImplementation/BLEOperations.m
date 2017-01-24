/*
 * Copyright (c) 2015, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "BLEOperations.h"
#import "Utility.h"

@interface BLEOperations ()
/*!
 * The timer is used to monitor connection time
 */
@property (strong, nonatomic) NSTimer *timer;
- (void)timerFireMethod:(NSTimer *)timer;
@end

@implementation BLEOperations

@synthesize shsSendCharacteristic;
@synthesize shsReceiveCharacteristic;
@synthesize timer;

bool isSHSServiceFound, isSHSSendCharacteristicFound,isSHSReceiveCharacteristicFound;

-(BLEOperations *)initWithDelegate:(id<BLEOperationsDelegate>)delegate{
    if(self =[super init]){
        self.bleDelegate = delegate;
    }
    return self;
}

-(void)setBluetoothCentralManager:(CBCentralManager *)manager{
    self.centralManager =manager;
    self.centralManager.delegate =self;
}

-(void)connectDevice:(CBPeripheral *)peripheral{
    NSLog(@"connectDevice");
    self.bluetoothPeripheral =peripheral;
    self.bluetoothPeripheral.delegate =self;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:NO];
    [self.centralManager connectPeripheral:peripheral options:nil];
    
}

-(void)searchSHSRequiredCharacteristics:(CBService *)service{
    isSHSSendCharacteristicFound =NO;
    isSHSReceiveCharacteristicFound =NO;
    for (CBCharacteristic *characteristic in service.characteristics){
        NSLog(@"Found characteristic %@",characteristic.UUID);
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:shsSendCharacteristicUUIDString]]){
            NSLog(@"Send Characteristic Found.");
            isSHSSendCharacteristicFound = YES;
            self.shsSendCharacteristic = characteristic;
        }
        if([characteristic.UUID isEqual:[CBUUID UUIDWithString:shsReceiveCharacteristicUUIDString]]){
            NSLog(@"Receive Characteristic Found.");
            isSHSReceiveCharacteristicFound = YES;
            self.shsReceiveCharacteristic = characteristic;
        }
    }
}

-(void)requestDisconnection{
    NSLog(@"requestDisconnection");
    [self.centralManager cancelPeripheralConnection:self.bluetoothPeripheral];
}

- (void)timerFireMethod:(NSTimer *)timer{
    [self.bleDelegate onTimerUp];
}

#pragma mark - CentralManager delegates
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManagerDidUpdateState");
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.timer invalidate];
    
    [self.bluetoothPeripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didDisconnectPeripheral");
    [self.bleDelegate onDeviceDisconnected:peripheral];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral");
    [self.bleDelegate onDeviceDisconnected:peripheral];
}

#pragma mark - CBPeripheral delegates
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    isSHSServiceFound = NO;
    NSLog(@"discoverd service:%@",peripheral.services);
    for(CBService *service in peripheral.services){
        if([service.UUID isEqual:[CBUUID UUIDWithString:shsServiceUUIDString]]){
            NSLog(@"SHS Service is found");
            isSHSServiceFound = YES;
            [self.bluetoothPeripheral discoverCharacteristics:nil forService:service];
        }
    }
    if(!isSHSServiceFound){
        NSString *errorMessage = [NSString stringWithFormat:@"Error on discovering service\n Message: Required SHS service not available on peripheral"];
        [self.centralManager cancelPeripheralConnection:peripheral];
        [self.bleDelegate onError:errorMessage];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"didDiscoverCharacteristicsForService");
    if([service.UUID isEqual:[CBUUID UUIDWithString:shsServiceUUIDString]]){
        [self searchSHSRequiredCharacteristics:service];
        if(isSHSSendCharacteristicFound && isSHSReceiveCharacteristicFound){
            [self.bleDelegate onDeviceConnected:self.bluetoothPeripheral
                              withSendCharacteristic:self.shsSendCharacteristic
                       andReceiveCharacteristic:self.shsReceiveCharacteristic];
        }
        
    }else{
        NSString *errorMessage = [NSString stringWithFormat:@"Error on discovering characteristics\n Message: Required SHS characteristics are not available on peripheral"];
        [self.centralManager cancelPeripheralConnection:peripheral];
        [self.bleDelegate onError:errorMessage];
        
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"error in writing characteristic %@ and error %@",characteristic.UUID,[error localizedDescription]);
    }
    else {
       // NSLog(@"didWriteValueForCharacteristic %@ and value %@",characteristic.UUID,characteristic.value);
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSString *errorMessage = [NSString stringWithFormat:@"Error on BLE Notification\n Message: %@",[error localizedDescription]];
        NSLog(@"Error in Notification state: %@",[error localizedDescription]);
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:shsSendCharacteristicUUIDString]]) {
            NSLog(@"Error in Reading out the current configuration of all interfaces from shsSendCharacteristic.");
            errorMessage = [NSString stringWithFormat:@"Error on BLE Notification\n Message: %@\n Please reset Bluetooth from IOS Settings and then try again",[error localizedDescription]];
        }
        [self.bleDelegate onError:errorMessage];
    }
    else {
        [self.bleDelegate onReceivedNotification:characteristic.value];
    }

}


@end
