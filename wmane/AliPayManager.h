//
//  AliPayManager.h
//  wmpayane
//
//  Created by wuyoujian on 2018/1/11.
//

#import <Foundation/Foundation.h>
#import "PayConstant.h"

@interface AliPayManager : NSObject

+ (AliPayManager*)shareAliPayManager;

- (void)registerSDK:(NSString*)appId appSecret:(NSString*)appSecret;
- (void)pay:(NSString *)payJson completion:(PayCompletionBlock)block;

- (void)handleOpenURL:(NSURL *)url;

@end
