//
//  ANEExtensionFunc.m
//  wmaneSDK
//
//  Created by wuyoujian on 17/3/1.
//  Copyright © 2017年 Asiainfo. All rights reserved.
//

#import "ANEExtensionFunc.h"
#import "ANETypeConversion.h"


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

- (void)registerWXSDK:(FREObject)appId appSecret:(FREObject)appSecret {
    
}

- (void)registerAlipaySDK:(FREObject)appId appSecret:(FREObject)appSecret {
    
}

- (void)alipay:(FREObject)payJson {
    
}

- (void)wxpay:(FREObject)payJson {
    
}

@end
