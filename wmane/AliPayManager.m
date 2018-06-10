//
//  AliPayManager.m
//  wmane
//
//  Created by wuyoujian on 2018/1/11.
//

#import "AliPayManager.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AliPayManager ()
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, copy) PayCompletionBlock  payFinishBlock;
@end

@implementation AliPayManager

+ (AliPayManager*)shareAliPayManager {
    static AliPayManager *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (void)registerSDK:(NSString*)appId appSecret:(NSString*)appSecret {
    _appId = appId;
    _appSecret = appSecret;
}

- (void)handleOpenURL:(NSURL *)url {
    __weak AliPayManager *wSelf = self;
    // 支付跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
        
        AliPayManager *sSelf = wSelf;
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        if (sSelf.payFinishBlock) {
            sSelf.payFinishBlock(jsonString);
        }
    }];
}

- (void)pay:(NSString *)orderString completion:(PayCompletionBlock)block {
    _payFinishBlock = block;
    
    // NOTE: 调用支付结果开始支付
    AliPayManager *wSelf = self;
    NSString *appScheme = [NSString stringWithFormat:@"alipay%@",_appId];
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSLog(@"reslut = %@",resultDic);
        
        AliPayManager *sSelf = wSelf;
        if (sSelf.payFinishBlock) {
            sSelf.payFinishBlock(@"0");
        }
    }];
}

@end
