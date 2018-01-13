//
//  ANEExtensionFunc.m
//  wmaneSDK
//
//  Created by wuyoujian on 17/3/1.
//  Copyright © 2017年 Asiainfo. All rights reserved.
//

#import "ANEExtensionFunc.h"
#import "ANETypeConversion.h"
#import "AliPayManager.h"
#import "WXPayManager.h"
#import <objc/runtime.h>


#define DISPATCH_STATUS_EVENT(extensionContext, code, status) FREDispatchStatusEventAsync((extensionContext), (uint8_t*)code, (uint8_t*)status)

@interface ANEExtensionFunc ()
@property (nonatomic, assign) FREContext context;
@property (nonatomic, strong) ANETypeConversion *converter;
@end

@implementation ANEExtensionFunc

- (instancetype)initWithContext:(FREContext)extensionContext {
    self = [super init];
    if (self) {
        self.context = extensionContext;
        self.converter = [[ANETypeConversion alloc] init];
    }
    return self;
}

- (FREObject)registerWXSDK:(FREObject)appId appSecret:(FREObject)appSecret {
    NSString *value = nil;
    NSString *value1 = nil;
    FREResult ret = [_converter FREObject2NString:appId toNString:&value];
    [_converter FREObject2NString:appSecret toNString:&value1];
    if (ret == FRE_OK) {
        [[WXPayManager shareWXPayManager] registerSDK:value appSecret:value1];
    }
    
    return NULL;
}

- (FREObject)registerAlipaySDK:(FREObject)appId appSecret:(FREObject)appSecret {
    NSString *value = nil;
    NSString *value1 = nil;
    FREResult ret = [_converter FREObject2NString:appId toNString:&value];
    [_converter FREObject2NString:appSecret toNString:&value1];
    if (ret == FRE_OK) {
        [[AliPayManager shareAliPayManager] registerSDK:value appSecret:value1];
    }
    return NULL;
}

- (FREObject)alipay:(FREObject)payJson {
    NSString *value = nil;
    FREResult ret = [_converter FREObject2NString:payJson toNString:&value];
    if (ret == FRE_OK) {
        __weak ANEExtensionFunc *wSelf = self;
        [[AliPayManager shareAliPayManager] pay:value completion:^(NSString *resultJson) {
            //
            ANEExtensionFunc *sSelf = wSelf;
            DISPATCH_STATUS_EVENT(sSelf.context, [@"alipay" UTF8String], [resultJson UTF8String]);
        }];
    }
    return NULL;
}

- (FREObject)wxpay:(FREObject)payJson {
    NSString *value = nil;
    FREResult ret = [_converter FREObject2NString:payJson toNString:&value];
    if (ret == FRE_OK) {
        __weak ANEExtensionFunc *wSelf = self;
        [[WXPayManager shareWXPayManager] pay:value completion:^(NSString *resultJson) {
            //
            ANEExtensionFunc *sSelf = wSelf;
            DISPATCH_STATUS_EVENT(sSelf.context, [@"wxpay" UTF8String], [resultJson UTF8String]);
        }];
    }
    return NULL;
}

@end
