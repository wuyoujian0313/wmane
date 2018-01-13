//
//  GetRSARequest.m
//  wmpayane
//
//  Created by wuyoujian on 2018/1/13.
//

#import "GetRSARequest.h"

#define kServerAddress      @""

@implementation GetRSARequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _url = kServerAddress;
        _timeout = 30;
    }
    return self;
}

- (void)getRSAKeyFinishBlock:(requestFinishBlock)block {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:[self HTTPPostRequest] completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"response:%@",str);
        /*
         字段:
         RSSKey :密钥
         */
        NSDictionary* param = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSString *key = param[@"RSSKey"];
        if (block) {
            block(key);
        }
    }];
    // 使用resume方法启动任务
    [dataTask resume];
}

- (NSURLRequest *)HTTPPostRequest {
    
    NSURL *URL = [NSURL URLWithString:self.url];
    NSMutableURLRequest *requestObj = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.timeout];
    
    [requestObj setHTTPMethod:@"POST"];
    //设置http 头
    [requestObj addValue:@"UTF-8" forHTTPHeaderField:@"Accept-Language"];
    [requestObj addValue:@"close" forHTTPHeaderField:@"Connection"];
    NSString *host = URL.host;
    [requestObj addValue:host forHTTPHeaderField:@"Host"];
    
    NSString *paramString = nil;
    if (_appId) {
        paramString = [NSString stringWithFormat:@"appId=%@",_appId];
        NSData *httpBody = [paramString dataUsingEncoding:NSUTF8StringEncoding];
        [requestObj setHTTPBody:httpBody];
        
        [requestObj addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    }

    return requestObj;
}

@end
