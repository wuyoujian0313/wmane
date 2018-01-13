//
//  WXPayManager.m
//  wmpayane
//
//  Created by wuyoujian on 2018/1/11.
//

#import "WXPayManager.h"
#import "GetRSARequest.h"

@interface WXPayManager ()
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, copy) NSString *rsa2PrivateKey;
@property (nonatomic, copy) NSString *payJson;
@property (nonatomic, copy) PayCompletionBlock  payFinishBlock;
@end

@implementation WXPayManager

+ (WXPayManager*)shareWXPayManager {
    static WXPayManager *obj = nil;
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
    __weak WXPayManager *wSelf = self;
    // 微信支付回调
}

- (void)toPay {
}

- (void)pay:(NSString *)payJson completion:(PayCompletionBlock)block {
    _payFinishBlock = block;
    _payJson = payJson;
    if (_rsa2PrivateKey == nil || [_rsa2PrivateKey length] == 0) {
        GetRSARequest *request = [[GetRSARequest alloc] init];
        request.appId = _appId;
        
        __weak WXPayManager *wSelf = self;
        [request getRSAKeyFinishBlock:^(NSString *rsaKey) {
            //
            WXPayManager *sSelf = wSelf;
            [sSelf toPay];
        }];
    } else {
        [self toPay];
    }
}

@end
