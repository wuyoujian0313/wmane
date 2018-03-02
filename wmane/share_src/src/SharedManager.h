//
//  SharedManager.h
//  CommonProject
//
//  Created by wuyoujian on 16/5/12.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SharedDataModel.h"

typedef NS_ENUM(NSInteger, AIPlatform) {
    AIPlatformWechat = 0,
    AIPlatformQQ = 1,
};

typedef NS_ENUM(NSInteger, AIInvokingStatusCode) {
    AIInvokingStatusCodeDone = 1000,            // 调起分享平台的应用成功
    AIInvokingStatusCodeAuthDone,               // 调起授权成功
    AIInvokingStatusCodeCancelAuth,
    AIInvokingStatusCodeUnintallApp,            // 未安装对应的分享平台的应用
};

@interface AISharedPlatformSDKInfo : NSObject
@property (nonatomic, assign) AIPlatform platform;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, copy) NSString *redirectURI;//若无此参数，可以传入nil;
@end

// @param resp 是微信和qq回调对象
// @param statusCode可以是AISharedStatusCode，也兼容QQ的QQApiSendResultCode
typedef void(^AISharedFinishBlock)(NSInteger statusCode,id resp);

// 单例模式类
@interface SharedManager : NSObject
+ (SharedManager *)sharedManager;
- (BOOL)isInstallShareApps;

- (void)registerSharedPlatforms:(NSArray<AISharedPlatformSDKInfo*> *)platforms;
- (void)loginByWX:(AISharedFinishBlock)finishBlock;
- (void)loginByQQ:(AISharedFinishBlock)finishBlock;

- (BOOL)handleOpenURL:(NSURL *)url;
// 分享
- (void)sharedData:(SharedDataModel*)dataModel finish:(AISharedFinishBlock)finishBlock;
@end





