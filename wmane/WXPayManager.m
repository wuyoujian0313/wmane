//
//  WXPayManager.m
//  wmane
//
//  Created by wuyoujian on 2018/1/11.
//

#import "WXPayManager.h"
#import "GetRSARequest.h"
#import "WechatSDK1.8.2/WXApi.h"

@interface WXPayManager ()<WXApiDelegate>
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSecret;
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
    
    [WXApi registerApp:_appId enableMTA:NO];
}

- (void)handleOpenURL:(NSURL *)url {
    // 微信支付回调
    [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - WXApiDelegate
// 微信支付回调
- (void)onResp:(BaseResp*)resp {
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp*response=(PayResp*)resp;
        
        // WXSuccess           = 0,    /**< 成功    */
        // WXErrCodeCommon     = -1,   /**< 普通错误类型    */
        // WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
        // WXErrCodeSentFail   = -3,   /**< 发送失败    */
        // WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
        // WXErrCodeUnsupport  = -5,   /**< 微信不支持    */
        switch(response.errCode){
            case WXSuccess:
                if (self.payFinishBlock) {
                    self.payFinishBlock(@"{\"status\":\"success\"}");
                }
                break;
            case WXErrCodeUserCancel:
                if (self.payFinishBlock) {
                    self.payFinishBlock(@"{\"status\":\"cancel\"}");
                }
                break;
            default:
                break;
        }
    }
}

- (void)toPay {
    
    /*
     字段:
     goodsDesc :商品描述
     goodsName :商品名称
     orderNo   :订单号
     price     :商品价格
     scheme    :应用程序配置的scheme
     */
    NSError *error = nil;
    NSData *jsonData = [_payJson dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* param = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    // 预下单接口调用
#define kNetworkServerIP            @"http://101.69.181.210:80"
#define kNetworkAPIServer           kNetworkServerIP@"/tuwen_web"
#define kWeiXinBusinessNo           @""
    //weiXinToPay/wxToPay
    NSURL *url = [NSURL URLWithString:kNetworkAPIServer@"weiXinToPay/wxToPay"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //设置request
    request.HTTPMethod = @"POST";
    
    NSDictionary* towxParam =[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"1122",@"userId",
                          _appId,@"appid",
                          _appSecret,@"appsecret",
                          kWeiXinBusinessNo,@"partner",
                          param[@"price"],@"money",
                          @"WEB",@"device_info",
                          param[@"goodsDesc"],@"body",
                          "192.168.1.1",@"spbill_create_ip",
                          @"CNY",@"fee_type",
                          nil];
    
    NSString *bodyString = @"";
    for (NSString*key in [towxParam allKeys]) {
        NSString *value = [towxParam objectForKey:key];
        bodyString = [bodyString stringByAppendingFormat:@"%@=%@",key,value];
        if (![key isEqualToString:[[towxParam allKeys] lastObject]]) {
            bodyString = [bodyString stringByAppendingString:@"&"];
        }
    }
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        
            PayReq *request = [[PayReq alloc] init];
            request.partnerId =  dict[@"partnerId"];
            request.prepayId = dict[@"prepayId"];
            request.package = dict[@"package"];
            request.nonceStr = dict[@"nonceStr"];
            request.timeStamp = [dict[@"timeStamp"] intValue];
            request.sign = dict[@"sign"];
            [WXApi sendReq:request];
        });
        
    }];
    // 使用resume方法启动任务
    [dataTask resume];
}

- (void)pay:(NSString *)payJson completion:(PayCompletionBlock)block {
    _payFinishBlock = block;
    _payJson = payJson;
    
    GetRSARequest *request = [[GetRSARequest alloc] init];
    request.appId = _appId;
    
    __weak WXPayManager *wSelf = self;
    [request getRSAKeyFinishBlock:^(NSString *rsaKey) {
        //
        WXPayManager *sSelf = wSelf;
        [sSelf toPay];
    }];
}

@end
