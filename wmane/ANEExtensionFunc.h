//
//  ANEExtensionFunc.h
//  wmaneSDK
//
//  Created by wuyoujian on 17/3/1.
//  Copyright © 2017年 Asiainfo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"


@interface ANEExtensionFunc : NSObject

- (instancetype)initWithContext:(FREContext)extensionContext;

- (FREObject)registerWXPaySDK:(FREObject)appId appSecret:(FREObject)appSecret;
- (FREObject)registerShareSDKs:(FREObject)sdksJson;
- (FREObject)registerAlipaySDK:(FREObject)appId appSecret:(FREObject)appSecret;
- (FREObject)isAppInstalled;
- (FREObject)alipay:(FREObject)payJson;
- (FREObject)wxpay:(FREObject)payJson;

// 发送文字
- (FREObject)sendText:(FREObject)text;

// 发送链接
- (FREObject)sendLinkTitle:(FREObject)title text:(FREObject)text url:(FREObject)url;

// 发送本地图片
- (FREObject)sendImage:(FREObject)image;

// 发送远程图片
-(FREObject)sendImageUrl:(FREObject)imgUrl;

- (FREObject)loginByWX;
- (FREObject)loginByQQ;

- (FREObject)playAV:(FREObject)text;
- (FREObject)playAVForLocal:(FREObject)text;

@end
