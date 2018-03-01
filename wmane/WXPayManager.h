//
//  WXPayManager.h
//  wmane
//
//  Created by wuyoujian on 2018/1/11.
//

#import <Foundation/Foundation.h>
#import "PayConstant.h"

@interface WXPayManager : NSObject
+ (WXPayManager*)shareWXPayManager;
- (void)registerSDK:(NSString*)appId appSecret:(NSString*)appSecret partner:(NSString *)partner;

- (void)pay:(NSString *)payJson completion:(PayCompletionBlock)block;
- (void)handleOpenURL:(NSURL *)url;
@end
