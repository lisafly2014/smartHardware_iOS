//
//  Utility.h
//  SHSApplication
//
//  Created by Simon Third on 02/02/16.
//  Copyright © 2016 Simon Third. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIkit/UIKit.h>

@interface Utility : NSObject
extern NSString *const shsServiceUUIDString;
extern NSString *const shsSendCharacteristicUUIDString;
extern NSString *const shsReceiveCharacteristicUUIDString;
extern NSString * const ANCSServiceUUIDString;

extern int8_t const ANALOGUE_INPUT_PIN_NUMBER;
extern int8_t const PWM_CHANNELS;
extern int8_t const SERVO_CHANNELS;



typedef enum{
    DIN,   //digitalInput
    DOUT,  //digitalOutput
    AIN,   //anologInput
    PWM,
    SERVO,
    SPI,
    I2C,
    UART,
    RC5,
    QUAD
}enumInterfaceType;

typedef enum{
    RESPONSE_SUCCESS =1,
    RESPONSE_FAIL,
    RESPONSE_UNKNOWN,   //command not recognise
    RESPONSE_LOCKED,
    RESPONSE_CLASH,     //pin already used
    RESPONSE_NOT_CONFIGURED, //pin is not configured for this action
    RESPONSE_WRONG_LENGTH  //packet length not correct
    
}enumResponseCode;

typedef enum{
    MANAGE_ID_DEVICE_RESPONSE =3,
    MANAGE_ID_DEVICE_RESET =4,
    MANAGE_ID_DEVICE_SET_NAME,
    MANAGE_ID_DEVICE_READ_INFO,
    MANAGE_ID_DEVICE_GET_INTERFACES,
    MANAGE_ID_DEVICE_CLEAR_INTERFACES,
    MANAGE_ID_DEVICE_STORE_CONFIG,
    MANAGE_ID_DEVICE_LOCK,
    MANAGE_ID_DEVICE_UNLOCK,
    
    MANAGE_ID_INTERFACE_ADD = 20,
    MANAGE_ID_INTERFACE_DELETE,
    MANAGE_ID_INTERFACE_GET,
    MANAGE_ID_INTERFACE_READ,
    MANAGE_ID_MAX
    
}enumCommandID;

typedef enum{
    FUNCTION_ID_DIN_0 = 32,
    FUNCTION_ID_DIN_1,
    FUNCTION_ID_DIN_2,
    FUNCTION_ID_DIN_3,
    FUNCTION_ID_DIN_4,
    FUNCTION_ID_DIN_5,
    FUNCTION_ID_DIN_6,
    FUNCTION_ID_DIN_7,
    FUNCTION_ID_DIN_8,
    FUNCTION_ID_DIN_9 ,
    FUNCTION_ID_DIN_10 ,
    FUNCTION_ID_DIN_11 ,
    FUNCTION_ID_DIN_12 ,
    FUNCTION_ID_DIN_13 ,
    FUNCTION_ID_DIN_14 ,
    FUNCTION_ID_DIN_15 ,
    FUNCTION_ID_DIN_16 ,
    FUNCTION_ID_DIN_17 ,
    FUNCTION_ID_DIN_18 ,
    FUNCTION_ID_DIN_19 ,
    FUNCTION_ID_DIN_20 ,
    FUNCTION_ID_DIN_21 ,
    FUNCTION_ID_DIN_22 ,
    FUNCTION_ID_DIN_23 ,
    FUNCTION_ID_DIN_24 ,
    FUNCTION_ID_DIN_25 ,
    FUNCTION_ID_DIN_26 ,
    FUNCTION_ID_DIN_27 ,
    FUNCTION_ID_DIN_28 ,
    FUNCTION_ID_DIN_29 ,
    FUNCTION_ID_DIN_30 ,
    FUNCTION_ID_DIN_31 ,
    
    FUNCTION_ID_DOUT_0 =64,
    FUNCTION_ID_DOUT_1,
    FUNCTION_ID_DOUT_2,
    FUNCTION_ID_DOUT_3,
    FUNCTION_ID_DOUT_4,
    FUNCTION_ID_DOUT_5,
    FUNCTION_ID_DOUT_6,
    FUNCTION_ID_DOUT_7,
    FUNCTION_ID_DOUT_8,
    FUNCTION_ID_DOUT_9,
    FUNCTION_ID_DOUT_10,
    FUNCTION_ID_DOUT_11,
    FUNCTION_ID_DOUT_12,
    FUNCTION_ID_DOUT_13,
    FUNCTION_ID_DOUT_14,
    FUNCTION_ID_DOUT_15,
    FUNCTION_ID_DOUT_16,
    FUNCTION_ID_DOUT_17,
    FUNCTION_ID_DOUT_18,
    FUNCTION_ID_DOUT_19,
    FUNCTION_ID_DOUT_20,
    FUNCTION_ID_DOUT_21,
    FUNCTION_ID_DOUT_22,
    FUNCTION_ID_DOUT_23,
    FUNCTION_ID_DOUT_24,
    FUNCTION_ID_DOUT_25,
    FUNCTION_ID_DOUT_26,
    FUNCTION_ID_DOUT_27,
    FUNCTION_ID_DOUT_28,
    FUNCTION_ID_DOUT_29,
    FUNCTION_ID_DOUT_30,
    FUNCTION_ID_DOUT_31,
    
    FUNCTION_ID_AIN_0 = 96,
    FUNCTION_ID_AIN_1,
    FUNCTION_ID_AIN_2,
    FUNCTION_ID_AIN_3,
    FUNCTION_ID_AIN_4,
    FUNCTION_ID_AIN_5,
    
    FUNCTION_ID_PWM_0 =112,
    FUNCTION_ID_PWM_1,
    FUNCTION_ID_PWM_2,
    FUNCTION_ID_PWM_3,
    
    FUNCTION_ID_SERVO_0 =116,
    FUNCTION_ID_SERVO_1,
    FUNCTION_ID_SERVO_2,
    FUNCTION_ID_SERVO_3,
    
    
    
    FUNCTION_ID_UART,
    FUNCTION_ID_UART_STATUS,
    
    FUNCTION_ID_SPI ,
    FUNCTION_ID_I2C,
    FUNCTION_ID_RC5,
    FUNCTION_ID_QUAD,
    FUNCTION_ID_TEMP_INT,
    
    FUNCTION_ID_MAX
}enumFunctionID;

typedef struct{
    uint8_t pinConfigValue;
    uint8_t defaultValue;
}pinConfiguration;


typedef struct{
    uint8_t dinData[32];
    uint8_t doutData[32];
 }interfaceData_t;

+ (void) showAlert:(NSString *)message;
+(void)showBackgroundNotification:(NSString *)message;
+ (BOOL)isApplicationStateInactiveORBackground;

@end
