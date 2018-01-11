//
//  alipayManager.h
//  wmpayane
//
//  Created by wuyoujian on 2018/1/11.
//

#import <Foundation/Foundation.h>

@interface alipayManager : NSObject

+ (alipayManager*)shareAlipayManager;

- (void)registerSDK:(NSString*)appId appSecret:(NSString*)appSecret;
- (void)pay:(NSString *)payJson;

@end
