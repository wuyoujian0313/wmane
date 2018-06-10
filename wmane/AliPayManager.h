//
//  AliPayManager.h
//  wmane
//
//  Created by wuyoujian on 2018/1/11.
//

#import <Foundation/Foundation.h>
#import "PayConstant.h"

@interface AliPayManager : NSObject

+ (AliPayManager*)shareAliPayManager;

- (void)registerSDK:(NSString*)appId appSecret:(NSString*)appSecret;
- (void)pay:(NSString *)orderString completion:(PayCompletionBlock)block;
- (void)handleOpenURL:(NSURL *)url;

@end
