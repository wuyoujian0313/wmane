//
//  SharedManager.m
//  CommonProject
//
//  Created by wuyoujian on 16/5/12.
//  Copyright © 2016年 wuyoujian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "SharedManager.h"
#import "AIActionSheet.h"
#import "AIAppHook2Pay.h"

// 微信平台
#import "WechatAuthSDK.h"
#import "WXApiObject.h"
#import "WXApi.h"

// QQ平台
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/sdkdef.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentMessageObject.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentOAuthObject.h>

#define IS_RETINA ([UIScreen mainScreen].scale >= 2.0)

typedef NS_ENUM(NSInteger, AISharedPlatformScene) {
    AISharedPlatformSceneSession,   //聊天
    AISharedPlatformSceneTimeline,  //朋友圈&空间
    AISharedPlatformSceneFavorite,  //收藏
};


@implementation AISharedPlatformSDKInfo
+ (instancetype)platform:(AIPlatform)platform
                   appId:(NSString*)appId
                  secret:(NSString*)appSecret
             redirectURI:(NSString*)redirectURI
{
    
    AISharedPlatformSDKInfo *sdk = [[AISharedPlatformSDKInfo alloc] init];
    sdk.platform = platform;
    sdk.appId = appId;
    sdk.appSecret = appSecret;
    sdk.redirectURI = redirectURI;
    return sdk;
}

@end

@interface inline_SharedPlatformScene : NSObject
@property (nonatomic, assign) AIPlatform platform;
@property (nonatomic, assign) AISharedPlatformScene scene;
+ (instancetype)scene:(AISharedPlatformScene)scene platform:(AIPlatform)platform;
@end

@implementation inline_SharedPlatformScene
+ (instancetype)scene:(AISharedPlatformScene)scene platform:(AIPlatform)platform {
    inline_SharedPlatformScene *sharedscene = [[inline_SharedPlatformScene alloc] init];
    sharedscene.scene = scene;
    sharedscene.platform = platform;
    return sharedscene;
}
@end

@interface SharedManager ()< AIActionSheetDelegate,TencentSessionDelegate,WXApiDelegate,QQApiInterfaceDelegate>
@property (nonatomic, strong) AIActionSheet                               *actionSheet;
@property (nonatomic, strong) NSMutableArray<inline_SharedPlatformScene*> *scenes;
@property (nonatomic, strong) SharedDataModel                             *sharedData;
@property (nonatomic, strong) TencentOAuth                                *qqOAuth;
@property (nonatomic, copy) AISharedFinishBlock                           finishBlock;
@property (nonatomic, strong) NSMutableArray<AISharedPlatformSDKInfo*>    *platforms;
@property (nonatomic, strong) NSMutableDictionary                         *appIdMap;
@end

@implementation SharedManager

+ (SharedManager *)sharedManager {
    static SharedManager *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[super allocWithZone:NULL] init];
    });
    return obj;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [[self class] sharedManager];
}

- (instancetype)copy {
    return [[self class] sharedManager];
}

- (instancetype)init {
    if (self = [super init]) {
        self.platforms = [[NSMutableArray alloc] init];
        self.appIdMap = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (BOOL)handleOpenURL:(NSURL*)url {
    for (AISharedPlatformSDKInfo* sdk in _platforms) {
        if ([[url absoluteString] hasPrefix:[sdk appId]]) {
            //微信回调
            return [WXApi handleOpenURL:url delegate:self];
        } else if ([[url absoluteString] hasPrefix:[NSString stringWithFormat:@"QQ%@",[sdk appId]]] || [[url absoluteString] hasPrefix:[NSString stringWithFormat:@"tencent%@",[sdk appId]]]) {
            //QQ回调
            [QQApiInterface handleOpenURL:url delegate:self];
            [TencentOAuth HandleOpenURL:url];
            return YES;
        }
    }

    return YES;
}

- (void)registerSharedPlatforms:(NSArray<AISharedPlatformSDKInfo*> *)platforms {
    
    __weak typeof(self)wSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        typeof(self)sSelf = wSelf;
        [sSelf.platforms removeAllObjects];
        [sSelf.platforms addObjectsFromArray:platforms];
        [_actionSheet clearAllItems];
        
        for (AISharedPlatformSDKInfo *item  in platforms) {
            AIPlatform platform = [item platform];
            [sSelf.appIdMap setObject:[item appId] forKey:[[NSNumber numberWithInteger:platform] stringValue]];
        
            if (platform == AIPlatformWechat) {
                // 微信
                [WXApi registerApp:[item appId]];

                [sSelf addSharedPlatformScene:[inline_SharedPlatformScene scene:AISharedPlatformSceneSession platform:AIPlatformWechat]];
                [sSelf addSharedPlatformScene:[inline_SharedPlatformScene scene:AISharedPlatformSceneTimeline platform:AIPlatformWechat]];
                [sSelf addSharedPlatformScene:[inline_SharedPlatformScene scene:AISharedPlatformSceneFavorite platform:AIPlatformWechat]];
                
                
            } else if (platform == AIPlatformQQ) {
                //
                sSelf.qqOAuth = [[TencentOAuth alloc] initWithAppId:[item appId] andDelegate:sSelf];
                [sSelf addSharedPlatformScene:[inline_SharedPlatformScene scene:AISharedPlatformSceneSession platform:AIPlatformQQ]];
                [sSelf addSharedPlatformScene:[inline_SharedPlatformScene scene:AISharedPlatformSceneTimeline platform:AIPlatformQQ]];
            }
        }
    
    });
}

- (void)addSharedPlatformScene:(inline_SharedPlatformScene*)scene {
    
    if (_actionSheet == nil) {
        self.actionSheet = [[ AIActionSheet alloc] initInParentView:[UIApplication sharedApplication].keyWindow.rootViewController.view delegate:self];
        self.scenes = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    for (inline_SharedPlatformScene*item in _scenes) {
        if (item == scene) {
            return;
        }
    }
    
    NSString *resPath = [[NSBundle mainBundle] pathForResource:@"SharedUI" ofType:@"bundle"];
    AISheetItem * item = [[AISheetItem alloc] init];
    if (scene.platform == AIPlatformWechat ) {
        if (scene.scene == AISharedPlatformSceneSession) {
            if (IS_RETINA) {
                item.iconPath = [resPath stringByAppendingPathComponent:@"icon_wechat@2x.png"];
            } else {
                item.iconPath = [resPath stringByAppendingPathComponent:@"icon_wechat.png"];
            }
            
            item.title = @"微信好友";
        } else if (scene.scene == AISharedPlatformSceneTimeline) {
            if (IS_RETINA) {
                item.iconPath = [resPath stringByAppendingPathComponent:@"icon_wechatTimeline@2x.png"];
            } else {
                item.iconPath = [resPath stringByAppendingPathComponent:@"icon_wechatTimeline.png"];
            }
            
            item.title = @"微信朋友圈";
        } else if (scene.scene == AISharedPlatformSceneFavorite) {
            if (IS_RETINA) {
                item.iconPath = [resPath stringByAppendingPathComponent:@"icon_wechatFav@2x.png"];
            } else {
                item.iconPath = [resPath stringByAppendingPathComponent:@"icon_wechatFav.png"];
            }
            
            item.title = @"微信收藏";
        }
    } else if (scene.platform == AIPlatformQQ ) {
        if (scene.scene == AISharedPlatformSceneSession) {
            if (IS_RETINA) {
                item.iconPath = [resPath stringByAppendingPathComponent:@"icon_qq@2x.png"];
            } else {
                item.iconPath = [resPath stringByAppendingPathComponent:@"icon_qq.png"];
            }
            
            item.title = @"QQ";
        } else if (scene.scene == AISharedPlatformSceneTimeline) {
            if (IS_RETINA) {
                item.iconPath = [resPath stringByAppendingPathComponent:@"icon_qqzoom@2x.png"];
            } else {
                item.iconPath = [resPath stringByAppendingPathComponent:@"icon_qqzoom.png"];
            }
            
            item.title = @"QQ空间";
        }
    }
     
    [_actionSheet addActionItem:item];
    [_scenes addObject:scene];
}

- (void)unstallAppMessage:(NSString *)message {
    UIAlertAction *aAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //
    }];
    //
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:aAction];
    
    UIApplication *application = [UIApplication sharedApplication];
    [application.keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)sharedData:(SharedDataModel*)dataModel finish:(AISharedFinishBlock)finishBlock {
    
    self.finishBlock = finishBlock;
    self.sharedData = dataModel;
    if (_actionSheet) {
        [_actionSheet show];
    }
}


- (BOOL)isInstallShareApps {
    return [WXApi isWXAppInstalled] || [QQApiInterface isQQInstalled];
}


- (void)shareToWeixin:(inline_SharedPlatformScene *)scene {
    
    if (![WXApi isWXAppInstalled]) {
        if (_finishBlock) {
            _finishBlock(AIInvokingStatusCodeUnintallApp,nil);
        }
        
        [self unstallAppMessage:@"手机未安装微信客户端！"];
        return;
    }
    
    //微信
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.scene = scene.scene;
    
    if (_sharedData.dataType == SharedDataTypeText) {
        // 文字类型分享
        req.text = _sharedData.content;
        req.bText = YES;
    } else if (_sharedData.dataType == SharedDataTypeImage) {
        // 图片类型分享
        req.bText = NO;
        WXMediaMessage *message = [WXMediaMessage message];
        [message setThumbImage:_sharedData.thumbImage];
        
        WXImageObject *imageObject = [WXImageObject object];
        imageObject.imageData = _sharedData.imageData;
        message.mediaObject = imageObject;
        
        req.message = message;
        
    } else if (_sharedData.dataType == SharedDataTypeMusic) {
        // 音乐类型分享
        req.bText = NO;
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = _sharedData.title;
        message.description = _sharedData.content;
        [message setThumbImage:_sharedData.thumbImage];
        
        WXMusicObject *musicObject = [WXMusicObject object];
        musicObject.musicUrl = _sharedData.url;
        musicObject.musicLowBandUrl = musicObject.musicUrl;
        musicObject.musicDataUrl = musicObject.musicUrl;
        musicObject.musicLowBandDataUrl = musicObject.musicUrl;
        message.mediaObject = musicObject;
        
        req.message = message;
    } else if (_sharedData.dataType == SharedDataTypeVideo) {
        // 视频类型分享
        req.bText = NO;
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = _sharedData.title;
        message.description = _sharedData.content;
        [message setThumbImage:_sharedData.thumbImage];
        
        WXVideoObject *videoObject = [WXVideoObject object];
        videoObject.videoUrl = _sharedData.url;
        videoObject.videoLowBandUrl = _sharedData.lowBandUrl;
        message.mediaObject = videoObject;
        
        req.message = message;
    } else if (_sharedData.dataType == SharedDataTypeURL) {
        // 网页类型分享
        req.bText = NO;
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = _sharedData.title;
        message.description = _sharedData.content;
        [message setThumbImage:_sharedData.thumbImage];
        
        WXWebpageObject *webpageObject = [WXWebpageObject object];
        webpageObject.webpageUrl = _sharedData.url;
        message.mediaObject = webpageObject;
        
        req.message = message;
        
    } else {
        
    }
    
    [WXApi sendReq:req];
}

- (void)loginByWX:(AISharedFinishBlock)finishBlock {
    
    self.finishBlock = finishBlock;
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"weimeitc_aneProject";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
}

- (void)loginByQQ:(AISharedFinishBlock)finishBlock {
    
    self.finishBlock = finishBlock;
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            nil];
    NSString *appId =  [_appIdMap objectForKey:[[NSNumber numberWithInteger:AIPlatformQQ] stringValue]];
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
    self.qqOAuth = tencentOAuth;
    [tencentOAuth authorize:permissions inSafari:NO];
}

- (void)shareToQQ:(inline_SharedPlatformScene *)scene {
    //QQ
    if (![QQApiInterface isQQInstalled]) {
        if (_finishBlock) {
            _finishBlock(AIInvokingStatusCodeUnintallApp,nil);
        }
        [self unstallAppMessage:@"手机未安装QQ客户端！"];
        return;
    }
    
    if (_sharedData.dataType == SharedDataTypeText || _sharedData.dataType == SharedDataTypeURL) {
        // 文字类型分享
        NSString *text = _sharedData.dataType == SharedDataTypeText ? _sharedData.content : _sharedData.url;
        
        if (scene.scene == AISharedPlatformSceneSession) {
            // 分享到聊天
            QQApiTextObject* txtObj = [QQApiTextObject objectWithText:text];
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:txtObj];
            QQApiSendResultCode sentCode = [QQApiInterface sendReq:req];
            [self handleSendQQResult:sentCode];
            
            
        } else if (scene.scene == AISharedPlatformSceneTimeline) {
            // 分享到空间
            
            QQApiTextObject* txtObj = [QQApiTextObject objectWithText:text];
            
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
            QQApiSendResultCode sentCode = [QQApiInterface SendReqToQZone:req];
            [self handleSendQQResult:sentCode];
            
        }
        
    } else if (_sharedData.dataType == SharedDataTypeImage) {
        // 图片类型分享
        if (scene.scene == AISharedPlatformSceneSession) {
            
            // 分享到聊天
            QQApiImageObject* img = [QQApiImageObject objectWithData:_sharedData.imageData previewImageData:UIImagePNGRepresentation(_sharedData.thumbImage) title:_sharedData.title description:_sharedData.content];
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
            
            QQApiSendResultCode sentCode = [QQApiInterface sendReq:req];
            [self handleSendQQResult:sentCode];
            
        } else if (scene.scene == AISharedPlatformSceneTimeline) {
            
            // 分享到空间
            QQApiImageArrayForQZoneObject *img = [QQApiImageArrayForQZoneObject objectWithimageDataArray:[NSArray arrayWithObject:_sharedData.imageData] title:_sharedData.title];
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
            QQApiSendResultCode sentCode = [QQApiInterface SendReqToQZone:req];
            [self handleSendQQResult:sentCode];
        }
        
    } else if (_sharedData.dataType == SharedDataTypeVideo) {
        // 视频类型分享
        if (scene.scene == AISharedPlatformSceneSession) {
            
            // 分享到聊天
            NSURL* url = [NSURL URLWithString:_sharedData.url];
            QQApiNewsObject* img = [QQApiNewsObject objectWithURL:url title:_sharedData.title description:_sharedData.content previewImageData:UIImagePNGRepresentation(_sharedData.thumbImage)];
            
            SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
            QQApiSendResultCode sentCode = [QQApiInterface sendReq:req];
            [self handleSendQQResult:sentCode];
            
        } else if (scene.scene == AISharedPlatformSceneTimeline) {
            
            // 分享到空间
            QQApiVideoForQZoneObject *video = [QQApiVideoForQZoneObject objectWithAssetURL:_sharedData.url title:_sharedData.title];
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:video];
            QQApiSendResultCode sentCode = [QQApiInterface SendReqToQZone:req];
            [self handleSendQQResult:sentCode];
        }
    }
}


#pragma mark - AIActionSheetDelegate
- (void)didSelectedActionSheet:( AIActionSheet *)actionSheet buttonIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex != buttonIndex) {
        inline_SharedPlatformScene *scene = [_scenes objectAtIndex:buttonIndex];
        if (scene.platform == AIPlatformWechat) {
            [self shareToWeixin:scene];
        } else if (scene.platform == AIPlatformQQ) {
            [self shareToQQ:scene];
        }
    }
}

- (void)handleSendQQResult:(QQApiSendResultCode)sendResult {
    switch (sendResult) {
        case EQQAPIAPPNOTREGISTED: {
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID: {
            break;
        }
        case EQQAPIQQNOTINSTALLED: {
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI: {
            if (_finishBlock) {
                _finishBlock(sendResult,nil);
            }
            break;
        }
        case EQQAPISENDFAILD: {
            break;
        }
        default:
        {
            break;
        }
    }
}

#pragma mark - TencentLoginDelegate
- (void)tencentDidLogin {
    if (_finishBlock) {
        _finishBlock(AIInvokingStatusCodeAuthDone,[_qqOAuth openId]);
    }
}
- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (_finishBlock) {
        _finishBlock(AIInvokingStatusCodeCancelAuth,[_qqOAuth openId]);
    }
}
- (void)tencentDidNotNetWork {}

#pragma mark - WXApiDelegate & QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req {}
- (void)onResp:(id)resp {
    //
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if ([aresp.state isEqualToString:@"weimeitc_aneProject"]) {
            NSString *code = aresp.code;
            [self getAccessTokenWithCode:code];
        }
    } else if ([resp isKindOfClass:[QQBaseResp class]]) {
        if (_finishBlock) {
            _finishBlock(AIInvokingStatusCodeDone,resp);
        }
    }

}

- (void)isOnlineResponse:(NSDictionary *)response {}

- (void)getAccessTokenWithCode:(NSString *)code {
    
    NSString *wxAppId = nil;
    NSString *wxAppSecret = nil;
    for (AISharedPlatformSDKInfo *item  in _platforms) {
        AIPlatform platform = [item platform];
        if (platform == AIPlatformWechat) {
            wxAppId = [item appId];
            wxAppSecret = [item appSecret];
        }
    }
    
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",wxAppId,wxAppSecret,code];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data){
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([dict objectForKey:@"errcode"]) {
                    NSLog(@"%@",dict);
                } else {
                    /*
                     {
                     "access_token" = "tnSXfzh2w8zrDe8zCdi0m1ZmOR***************Ckz6S6xJLQFeUDgu5Hyhwyowg5fvOhW2ZpA7Rr_PGPPO8P1Sw";
                     "expires_in" = 7200;
                     openid = oKiGKvxz***************JEjaYTNZPmA6OU;
                     "refresh_token" = "piHYgVqYxjw8mGdS1Wrnq8bIihijEp_Tvz6K***************jveI4iv5MPvOyV9zIemT_YAzv5S9djY";
                     scope = "snsapi_userinfo";
                     unionid = "o6awM***************aYlc***************ft9-A";
                     }
                     */
                    [self getUserInfoWithAccessToken:[dict objectForKey:@"access_token"] andOpenId:[dict objectForKey:@"openid"]];
                }
            }
        });
    });
}


//使用AccessToken获取用户信息
- (void)getUserInfoWithAccessToken:(NSString *)accessToken andOpenId:(NSString *)openId {
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                if ([dict objectForKey:@"errcode"]) {
                    //AccessToken失效
                }else {
                    NSLog(@"dictdict%@",dict);
                    if (_finishBlock) {
                        _finishBlock(AIInvokingStatusCodeAuthDone,dict);
                    }
                }
            }
        });
    });
}


@end

