//
//  SHSOperations.m
//  SHSApplication
//
//  Created by Simon Third on 03/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import "SHSOperations.h"

@implementation SHSOperations

@synthesize shsDelegate;
@synthesize bleOperations;

@synthesize shshConfigureValue;
@synthesize dinConfigurationArray;
@synthesize dinCurrentStatusArray;
@synthesize doutConfigurationArray;
@synthesize doutCurrentStatusArray;
@synthesize ainConfigurationArray;
@synthesize ainCurrentStatusArray;
@synthesize pwmConfigurationArray;
@synthesize pwmCurrentDutyCycleArray;
@synthesize servoConfigurationArray;
@synthesize servoCurrentPercentageArray;
@synthesize cmdArray;
@synthesize initFinished;

-(SHSOperations *)initWithDelegate:(id<SHSOperationsDelegate>) delegate{
    if(self =[super init]){
        shsDelegate = delegate;
        bleOperations =[[BLEOperations alloc] initWithDelegate:self];

        
    }
    return self;
}

-(void)initInterfaceConfiguration{
    self.dinConfigurationArray = [NSMutableArray array];
    self.dinCurrentStatusArray = [NSMutableArray array];
    self.doutConfigurationArray = [NSMutableArray array];
    self.doutCurrentStatusArray = [NSMutableArray array];
    self.ainConfigurationArray = [NSMutableArray array];
    self.ainCurrentStatusArray = [NSMutableArray array];
    self.pwmConfigurationArray = [NSMutableArray array];
    self.pwmCurrentDutyCycleArray = [NSMutableArray array];
    self.servoConfigurationArray = [NSMutableArray array];
    self.servoCurrentPercentageArray = [NSMutableArray array];
    self.cmdArray =[NSMutableArray array];
    
    self.initFinished = false;
    
    for (int j=0;j<32;j++){
        NSMutableArray *dinPin =[NSMutableArray arrayWithObjects:@(NO),@(0), nil]; //din pull
        [self.dinConfigurationArray addObject:dinPin];
        
        [self.dinCurrentStatusArray addObject:@0];//init digital input pin status
    }
    
    for (int k=0;k<32;k++){
        NSMutableArray *doutPin =[NSMutableArray arrayWithObjects:@(NO),@0,@0,@0,nil]; //dout pull,drive,default
        [self.doutConfigurationArray addObject:doutPin];
        
        
        [self.doutCurrentStatusArray addObject:@0];
    }

    for(int i=0;i<ANALOGUE_INPUT_PIN_NUMBER;i++){
        NSMutableArray *ainPin =[NSMutableArray arrayWithObjects:@(NO),@0,@0, nil]; //ain range,rate
        [self.ainConfigurationArray addObject:ainPin];
        
        [self.ainCurrentStatusArray addObject:@0];
    }
    for(int p=0;p<PWM_CHANNELS; p++){
        NSMutableArray *pwmChannel =[NSMutableArray arrayWithObjects:@(NO),@0,@0,@0,nil]; //pwm index,drive,dutyCycle
        
        [self.pwmConfigurationArray addObject:pwmChannel];
        [self.pwmCurrentDutyCycleArray addObject:@(0)];
        
    }for(int q=0; q<SERVO_CHANNELS;q++){
        NSMutableArray *servoChannel =[NSMutableArray arrayWithObjects:@(NO),@0,@0,@0, nil]; //servo index,drive,percentage
        
        [self.servoConfigurationArray addObject:servoChannel];
        [self.servoCurrentPercentageArray addObject:@(0)];
        
    }
}

-(void)setCentralManager:(CBCentralManager *)manager
{
    if (manager) {
        [bleOperations setBluetoothCentralManager:manager];
    }
    else {
        NSLog(@"CBCentralManager is nil");
        NSString *errorMessage = [NSString stringWithFormat:@"Error on received CBCentralManager\n Message: Bluetooth central manager is nil"];
        [shsDelegate onError:errorMessage];
    }
}

-(void)connectDevice:(CBPeripheral *)peripheral
{
    if (peripheral) {
        [bleOperations connectDevice:peripheral];
    }
    else {
        NSLog(@"CBPeripheral is nil");
        NSString *errorMessage = [NSString stringWithFormat:@"Error on received CBPeripheral\n Message: Bluetooth peripheral is nil"];
        [shsDelegate onError:errorMessage];
    }
}

-(void) enableNotification
{
    NSLog(@"enableNotification");
    [self.bluetoothPeripheral setNotifyValue:YES forCharacteristic:self.shsReceiveCharacteristic];
}

-(void)getDeviceConfiguration
{
    NSLog(@"getDeviceConfiguration");
    [self enableNotification];
    [self initInterfaceConfiguration];
    uint8_t value[] ={MANAGE_ID_DEVICE_GET_INTERFACES};
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)updateInterfaceValue:(uint8_t) pinNumber interfaceType:(uint8_t)type{
    switch(type){
        case DOUT:
            if( self.doutConfigurationArray[pinNumber][0]){
                uint8_t value[]={FUNCTION_ID_DOUT_0+pinNumber,[self.doutCurrentStatusArray[pinNumber] integerValue]};
                [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
            }else{
                [self.shsDelegate onError:@"Error. Try to configure a disabled outputPin."];
            }
            break;
        case PWM:
            if(self.pwmConfigurationArray[pinNumber][0]){
                uint8_t value[]={FUNCTION_ID_PWM_0+pinNumber,[self.pwmCurrentDutyCycleArray[pinNumber] integerValue]};
                [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
            }else{
                [self.shsDelegate onError:@"Error. Try to configure a disabled pwm pin."];
            }
            break;
        case SERVO:
            if(self.servoConfigurationArray[ pinNumber][0]){
                uint8_t value[]={FUNCTION_ID_SERVO_0+pinNumber,[self.servoCurrentPercentageArray[pinNumber] integerValue]};
                NSLog(@"value = %i, time: %@",(int)[self.servoCurrentPercentageArray[pinNumber] integerValue],[NSDate date]);
                [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
            }else{
                [self.shsDelegate onError:@"Error. Try to configure a disabled servo pin."];
            }
            break;
    }

}

/**
 dOutPin:  0~31
 */
-(void)unlockDevice:(uint8_t)cmd pinIndex:(uint8_t) index withConfigure:(NSData *)configureValue fromInterface:(uint8_t)interfaceType{
    command =cmd;
    switch(interfaceType){
        case DIN:
        {
            functionID = index +FUNCTION_ID_DIN_0;
            break;
        }
        case DOUT:
        {
            functionID = index + FUNCTION_ID_DOUT_0;
            break;
        }
        case AIN:
        {
            functionID =index + FUNCTION_ID_AIN_0 ;
            break;
        }
        case PWM:
        {
            functionID =index + FUNCTION_ID_PWM_0 ;
            break;
            
        }
        case SERVO:
        {
            functionID =index + FUNCTION_ID_SERVO_0 ;
            break;
            
        }
            
    }
    self.shshConfigureValue = configureValue;
    uint8_t value = MANAGE_ID_DEVICE_UNLOCK;
    
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    if(![[[defaults dictionaryRepresentation] allKeys] containsObject:@"deviceLocked"]){
        self.isLocked =YES;
    }else{
        self.isLocked = [defaults boolForKey:@"deviceLocked"];
    }
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)lockDevice{
    NSLog(@"lockDevice");
    uint8_t value = MANAGE_ID_DEVICE_LOCK;
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void)storeDeviceConfiguration{
    NSLog(@"storeDeviceConfiguration");
    uint8_t value = MANAGE_ID_DEVICE_STORE_CONFIG;
    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
}
//-(void)reReadDeviceConfiguration{
//    NSLog(@"reReadDeviceConfiguration");
//    uint8_t value[] ={MANAGE_ID_INTERFACE_GET,functionID};
//        [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
//}

-(void)disconnectPheripheral{
    [bleOperations requestDisconnection];  
}

/**
 funcID: FUNCTION_ID_DIN_0 ~ FUNCTION_ID_DIN_31
         FUNCTION_ID_DOUT_0 ~ FUNCTION_ID_DOUT_31
*/

-(void)updatePinConfiguration{
    uint8_t value[]={command,functionID};
    if(command == MANAGE_ID_INTERFACE_ADD){
        NSMutableData *data= [NSMutableData dataWithBytes:&value length:sizeof(value)];
        [data appendData:self.shshConfigureValue];
        [self.bluetoothPeripheral writeValue:data forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
        
    }else if(command ==MANAGE_ID_INTERFACE_DELETE){
        [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    

}

-(void)readPinStatus{
    NSLog(@"readPinStatus");
    for(int index =0; index <cmdArray.count;index++){
        uint8_t value[] = {[self.cmdArray[index][0] unsignedCharValue],[self.cmdArray[index][1] unsignedCharValue]};
                    [self.bluetoothPeripheral writeValue:[NSData dataWithBytes:&value length:sizeof(value)] forCharacteristic:self.shsSendCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    self.initFinished = true;
}



-(void)processSHSResponse:(uint8_t *)data withLength:(uint8_t) length
{
    if(data[0]== MANAGE_ID_INTERFACE_GET){
        if(data[1] >=FUNCTION_ID_DIN_0 && data[1]<=FUNCTION_ID_DIN_31 )
        {
            uint8_t dinPin = data[1]-FUNCTION_ID_DIN_0;
            
            self.dinConfigurationArray[dinPin][0] = @(YES);
            self.dinConfigurationArray[dinPin][1] = @(data[2]);
//          NSLog(@"din %i, %@", dinPin,self.dinConfigurationArray[dinPin]);
            
            if(!self.initFinished){
                 NSMutableArray *dinValue =[NSMutableArray arrayWithObjects:@(MANAGE_ID_INTERFACE_READ),@(data[1]), nil];
                [self.cmdArray addObject:dinValue];
            }
        }else if(data[1] >= FUNCTION_ID_DOUT_0 && data[1] <= FUNCTION_ID_DOUT_31)
        {
            uint8_t doutPin = data[1]- FUNCTION_ID_DOUT_0;
            uint8_t pullValue = data[2]&0x03;
            uint8_t driveValue = (data[2]&0x1C)>>2;
            
            self.doutConfigurationArray[doutPin][0] = @(YES);
            self.doutConfigurationArray[doutPin][1] = @(pullValue);
            self.doutConfigurationArray[doutPin][2] = @(driveValue);
            self.doutConfigurationArray[doutPin][3] = @(data[3]);
//            NSLog(@"dout %i, %@", doutPin,self.doutConfigurationArray[doutPin]);
            
            if(!self.initFinished){
                NSMutableArray *doutValue =[NSMutableArray arrayWithObjects:@(MANAGE_ID_INTERFACE_READ),@(data[1]), nil];
                [self.cmdArray addObject:doutValue];
            }
            
        }else if(data[1]>=FUNCTION_ID_AIN_0 &&data[1]<= FUNCTION_ID_AIN_5){
            uint8_t ainPin =data[1]- FUNCTION_ID_AIN_0;
            uint8_t rangeValue = data[2]&0x03;
            uint8_t rateValue = (data[2]&0x0C) >>2;

            self.ainConfigurationArray[ainPin][0] = @(YES);
            self.ainConfigurationArray[ainPin][1] = @(rangeValue);
            self.ainConfigurationArray[ainPin][2] = @(rateValue);
//            NSLog(@"ain %i, %@", ainPin,self.ainConfigurationArray[ainPin]);
            
            if(!self.initFinished){
                 NSMutableArray *ainValue =[NSMutableArray arrayWithObjects:@(MANAGE_ID_INTERFACE_READ),@(data[1]), nil];
                [self.cmdArray addObject:ainValue];
            }

        }else if(data[1]>=FUNCTION_ID_PWM_0 && data[1] <=FUNCTION_ID_PWM_3){
            uint8_t  pwmChannel = data[1] - FUNCTION_ID_PWM_0;
            
            self.pwmConfigurationArray[pwmChannel][0] = @(YES);
            self.pwmConfigurationArray[pwmChannel][1] = @(data[2]); //pwm pin
            self.pwmConfigurationArray[pwmChannel][2] = @(data[3]); //pwm drive
            self.pwmConfigurationArray[pwmChannel][3] = @(data[4]); //pwm duty cycle
//            NSLog(@"pwm %i, %@",pwmChannel,self.pwmConfigurationArray[pwmChannel]);
            if(!self.initFinished){
                NSMutableArray *pwmValue =[NSMutableArray arrayWithObjects:@(MANAGE_ID_INTERFACE_READ),@(data[1]), nil];
                [self.cmdArray addObject:pwmValue];
            }

        }else if(data[1]>=FUNCTION_ID_SERVO_0 && data[1] <=FUNCTION_ID_SERVO_3){
            uint8_t servoChannel = data[1]- FUNCTION_ID_SERVO_0;
            
            self.servoConfigurationArray[servoChannel][0] = @(YES);
            self.servoConfigurationArray[servoChannel][1] = @(data[2]); //servo pin
            self.servoConfigurationArray[servoChannel][2] = @(data[3]);// servo drive
            self.servoConfigurationArray[servoChannel][3] = @(data[4]);//servo default percentage
            
//            NSLog(@"servo %i, %@",servoChannel,self.servoConfigurationArray[servoChannel]);
            if(!self.initFinished){
                NSMutableArray *servoValue =[NSMutableArray arrayWithObjects:@(MANAGE_ID_INTERFACE_READ),@(data[1]), nil];
                [self.cmdArray addObject:servoValue];
            }
        }
    }else if(data[0] ==MANAGE_ID_DEVICE_RESPONSE){
        if(data[1] == MANAGE_ID_DEVICE_GET_INTERFACES){
            NSLog(@"Get device configuration done.");
            
            if(data[2] == RESPONSE_SUCCESS){
                [self readPinStatus];
                [shsDelegate onGetDeviceInterfaceConfiguration];
            }else{
                [self.shsDelegate onError:@"Error when getting device interfaces."];
            }
        }else if(data[1] == MANAGE_ID_INTERFACE_ADD){
            if(data[2] == RESPONSE_SUCCESS){
                uint8_t *configureValue=(uint8_t *)[self.shshConfigureValue bytes];
                if(functionID >=FUNCTION_ID_DIN_0 &&functionID <= FUNCTION_ID_DIN_31){
                    NSLog(@"Update input pin configuration");
                    uint8_t dinIndex = functionID -FUNCTION_ID_DIN_0;
                    if(![self.dinConfigurationArray[dinIndex][0] boolValue]){
                        self.dinConfigurationArray[dinIndex][0] =@YES;
                        self.dinCurrentStatusArray[dinIndex] = @(0);
                    }
                    
                    self.dinConfigurationArray[dinIndex][1] = @(configureValue[0]);
                    
                }else if(functionID >= FUNCTION_ID_DOUT_0 && functionID <= FUNCTION_ID_DOUT_31){
                    NSLog(@"Update output pin configuration");
                    uint8_t doutIndex = functionID-FUNCTION_ID_DOUT_0;
                    uint8_t pullValue = configureValue[0] & 0x03;
                    uint8_t driveValue = (configureValue[0] &0x1C) >>2;
                    if(![self.doutConfigurationArray[doutIndex][0] boolValue]){
                        self.doutConfigurationArray[doutIndex][0]=@YES;
                        self.doutCurrentStatusArray[doutIndex] = @(configureValue[1]);

                    }
                    
                    self.doutConfigurationArray[doutIndex][1]=@(pullValue);
                    self.doutConfigurationArray[doutIndex][2]=@(driveValue);
                    self.doutConfigurationArray[doutIndex][3] =@(configureValue[1]);
                    
                }else if(functionID >= FUNCTION_ID_AIN_0 && functionID <= FUNCTION_ID_AIN_5){
                    NSLog(@"Update analog input pin configuration");
                    uint8_t ainIndex = functionID - FUNCTION_ID_AIN_0;
                    uint8_t rangeValue = configureValue[0] & 0x03;
                    uint8_t rateValue = (configureValue[0] & 0x0C) >> 2;
                    if(![self.ainConfigurationArray[ainIndex][0] boolValue]){
                        self.ainConfigurationArray[ainIndex][0] = @YES;
                        self.ainCurrentStatusArray[ainIndex] = @(configureValue[0]);
                    }
                    self.ainConfigurationArray[ainIndex][1] = @(rangeValue);
                    self.ainConfigurationArray[ainIndex][2] = @(rateValue);

                }else if(functionID >= FUNCTION_ID_PWM_0 && functionID <= FUNCTION_ID_PWM_3){
                    NSLog(@"update pwm output configuration");
                    uint8_t pwmChl = functionID - FUNCTION_ID_PWM_0;
                    if(![self.pwmConfigurationArray[pwmChl][0] boolValue]){
                        self.pwmConfigurationArray[pwmChl][0]=@YES;
                        self.pwmCurrentDutyCycleArray[pwmChl] = @(configureValue[2]);
                    }

                    self.pwmConfigurationArray[pwmChl][1] =@(configureValue[0]); //pwm pin
                    self.pwmConfigurationArray[pwmChl][2] =@(configureValue[1]); //pwm drive
                    self.pwmConfigurationArray[pwmChl][3] =@(configureValue[2]); //pwm default duty cycle
                    
                }else if(functionID >= FUNCTION_ID_SERVO_0 && functionID <= FUNCTION_ID_SERVO_3){
                    NSLog(@"update servo output configuration");
                    uint8_t servoChl = functionID - FUNCTION_ID_SERVO_0;
                    if(![self.servoConfigurationArray[servoChl][0] boolValue]){
                        self.servoConfigurationArray[servoChl][0]=@YES;
                        self.servoCurrentPercentageArray[servoChl] =@(configureValue[2]);
                    }
                    self.servoConfigurationArray[servoChl][1] =@(configureValue[0]); //servo pin
                    self.servoConfigurationArray[servoChl][2] =@(configureValue[1]); //servo drive
                    self.servoConfigurationArray[servoChl][3] =@(configureValue[2]); //servo default percentage
                }
                [self storeDeviceConfiguration];
                
            }else if(data[2] ==RESPONSE_WRONG_LENGTH){
                [self.shsDelegate onErrorMessage:@"Command length wrong during update pin"];
            }else if(data[2] == RESPONSE_LOCKED){
                [self.shsDelegate onErrorMessage:@"Device locked during update pin"];
            }else if(data[2] == RESPONSE_CLASH){
                [self.shsDelegate onErrorMessage:@"Pin clash during update pin"];
            }
            
        }else if(data[1] == MANAGE_ID_INTERFACE_DELETE){
            if(data[2] == RESPONSE_SUCCESS){
                if(functionID >=FUNCTION_ID_DIN_0 &&functionID <= FUNCTION_ID_DIN_31){
                    NSLog(@"Delete input pin configuration");
                    uint8_t dinIndex = functionID -FUNCTION_ID_DIN_0;
                    self.dinConfigurationArray[dinIndex][0] =@NO;
                    self.dinConfigurationArray[dinIndex][1] = @(0); //default pull value
                    self.dinCurrentStatusArray[dinIndex] = @(0);
                }else if(functionID >= FUNCTION_ID_DOUT_0 && functionID <= FUNCTION_ID_DOUT_31){
                    NSLog(@"Delete output pin configuration");
                    uint8_t doutIndex = functionID-FUNCTION_ID_DOUT_0;
                    self.doutConfigurationArray[doutIndex][0]= @NO;
                    self.doutConfigurationArray[doutIndex][1]= @(0); //pull value
                    self.doutConfigurationArray[doutIndex][2]= @(0); //drive value
                    self.doutConfigurationArray[doutIndex][3]= @(0); //default pin Value
                    
                    self.doutCurrentStatusArray[doutIndex] = @(0);
                }else if(functionID >= FUNCTION_ID_AIN_0 && functionID <= FUNCTION_ID_AIN_5){
                    NSLog(@"Delete  analog input pin configuration");
                    uint ainIndex = functionID-FUNCTION_ID_AIN_0;
                    
                    self.ainConfigurationArray[ainIndex][0]= @NO;
                    self.ainConfigurationArray[ainIndex][1]= @(0); //range value
                    self.ainConfigurationArray[ainIndex][2] =@(0);//rate value
                    
                    self.ainCurrentStatusArray[ainIndex] = @(0);
                    
                }else if(functionID >= FUNCTION_ID_PWM_0 && functionID <= FUNCTION_ID_PWM_3){
                    NSLog(@"Delete  pwm output configuration");
                    uint pwmIndex = functionID-FUNCTION_ID_PWM_0;
                    
                    self.pwmConfigurationArray[pwmIndex][0]= @NO;
                    self.pwmConfigurationArray[pwmIndex][1]= @(0); //index
                    self.pwmConfigurationArray[pwmIndex][2]= @(0); //drive
                    self.pwmConfigurationArray[pwmIndex][3]= @(0); //duty cycle
                    
                    self.pwmCurrentDutyCycleArray[pwmIndex] = @(0);
                    
                }else if(functionID >= FUNCTION_ID_SERVO_0 && functionID <= FUNCTION_ID_SERVO_3){
                    NSLog(@"Delete  servo output configuration");
                    uint servoIndex = functionID-FUNCTION_ID_SERVO_0;
                    
                    self.servoConfigurationArray[servoIndex][0]= @NO;
                    self.servoConfigurationArray[servoIndex][1]= @(0); //index
                    self.servoConfigurationArray[servoIndex][2]= @(0); //drive
                    self.servoConfigurationArray[servoIndex][3]= @(0); //percentage
                    
                    self.servoCurrentPercentageArray[servoIndex] = @(0);
                }
                [self storeDeviceConfiguration];
                
            }else if(data[2] == RESPONSE_WRONG_LENGTH){
                [self.shsDelegate onErrorMessage:@"Command length wrong during delete pin"];
            }else if(data[2] == RESPONSE_LOCKED){
                [self.shsDelegate onErrorMessage:@"Device locked during delete pin"];
            }else if(data[2] == RESPONSE_NOT_CONFIGURED){
                [self.shsDelegate onErrorMessage:@"Device not configured and could not delete"];
            }
        }else if(data[1] == MANAGE_ID_DEVICE_UNLOCK){
            if(data[2] == RESPONSE_SUCCESS){
                NSLog(@"Unlock device successfully.");
                [self updatePinConfiguration];
                
            }else{
                [self.shsDelegate onErrorMessage:@"Unlock device fail."];
            }
        }else if(data[1] == MANAGE_ID_DEVICE_LOCK){
            if(data[2] == RESPONSE_SUCCESS){
                NSLog(@"Lock device successfully.");
            }else{
                [self.shsDelegate onErrorMessage:@"Lock device fail."];
            }
        }else if(data[1] == MANAGE_ID_DEVICE_STORE_CONFIG){
            if(data[2] == RESPONSE_SUCCESS){
                NSLog(@"Strore device configuration successfully.");
                if(self.isLocked){
                    [self lockDevice];
                }
            }else{
                [self.shsDelegate onErrorMessage:@"Strore device configuration fail."];
            }
        }
    }else if(data[0] >=FUNCTION_ID_DIN_0 && data[0] <= FUNCTION_ID_DIN_31){
        self.dinCurrentStatusArray[data[0]- FUNCTION_ID_DIN_0]=@(data[1]);
//        NSLog(@"din %i,data:%i",data[0]- FUNCTION_ID_DIN_0,data[1]);
        dispatch_async(dispatch_get_main_queue(),  ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"inputPinStatusChanged" object:nil];
        });
        
    }else if(data[0] >= FUNCTION_ID_DOUT_0 && data[0] <= FUNCTION_ID_DOUT_31){
        self.doutCurrentStatusArray[data[0]-FUNCTION_ID_DOUT_0] = @(data[1]);
//        NSLog(@"dout %i,data:%i",data[0]- FUNCTION_ID_DOUT_0,data[1]);
    }else if(data[0] >=FUNCTION_ID_AIN_0 && data[0] <= FUNCTION_ID_AIN_5){
       // NSLog(@"ain data: %i, %i",data[1],data[2]);

        int sampleMSB = data[1] & 0xFF;
        int sampleLSB = data[2] & 0xFF;
        
        int ainValue = (sampleMSB <<8) + sampleLSB;
        self.ainCurrentStatusArray[data[0]-FUNCTION_ID_AIN_0] = @(ainValue);

        dispatch_async(dispatch_get_main_queue(),  ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"analogPinStatusChanged" object:nil];
        });
        
    }else if(data[0] >= FUNCTION_ID_PWM_0 && data[0] <= FUNCTION_ID_PWM_3){
        self.pwmCurrentDutyCycleArray[data[0]- FUNCTION_ID_PWM_0 ] = @(data[1]);
//        NSLog(@"pwm %i,data:%i",data[0]- FUNCTION_ID_PWM_0,data[1]);
    }else if(data[0] >= FUNCTION_ID_SERVO_0 && data[0] <= FUNCTION_ID_SERVO_3){
        self.servoCurrentPercentageArray[data[0]- FUNCTION_ID_SERVO_0] = @(data[1]);
//        NSLog(@"servo %i,data:%i",data[0]- FUNCTION_ID_SERVO_0,data[1]);
    }
  }

-(void)clearResource{
    self.dinConfigurationArray = nil;
    self.dinCurrentStatusArray = nil;
    self.doutConfigurationArray = nil;
    self.doutCurrentStatusArray = nil;
    self.ainConfigurationArray = nil;
    self.ainCurrentStatusArray = nil;
    self.pwmConfigurationArray = nil;
    self.pwmCurrentDutyCycleArray = nil;
    self.servoConfigurationArray = nil;
    self.servoCurrentPercentageArray = nil;
    self.cmdArray =nil;
    
}
#pragma mark - BLEOperations delegates

-(void)onDeviceConnected:(CBPeripheral *)peripheral
withSendCharacteristic:(CBCharacteristic *)shsSendCharacteristic
andReceiveCharacteristic:(CBCharacteristic *)shsReceiveCharacteristic
{
     NSLog(@"onDeviceConnected");
    self.bluetoothPeripheral = peripheral;
    self.shsSendCharacteristic = shsSendCharacteristic;
    self.shsReceiveCharacteristic = shsReceiveCharacteristic;
    [shsDelegate onDeviceConnected:peripheral];
}

-(void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
     NSLog(@"onDeviceDisconnected");

    [self clearResource];
    [shsDelegate onDeviceDisconnected:peripheral];
}

-(void)onReceivedNotification:(NSData *)data
{
    [self processSHSResponse:(uint8_t *)[data bytes] withLength:[data length]];
}

-(void)onError:(NSString *)errorMessage
{
    [shsDelegate onError:errorMessage];
}
-(void)onTimerUp{
    NSLog(@"Connection time out");
    [shsDelegate onConnectionTimeOut];
}
@end
