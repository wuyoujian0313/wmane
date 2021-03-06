//
//  AIAppHook2Pay.m
//  wmane
//
//  Created by wuyoujian on 2018/1/13.
//


#import <UIKit/UIKit.h>
#import "AIAppHook2Pay.h"
#import "AliPayManager.h"
#import "SharedManager.h"
#import "WXPayManager.h"
#import <objc/runtime.h>

// AppDelegate的名称，即，main的第三个参数值
#define AppDelegateClassName        @"CTAppController"

@implementation AIAppHook2Pay

+ (void)hookMehod:(SEL)oldSEL andDef:(SEL)defaultSEL andNew:(SEL)newSEL {
    
    Class oldClass = objc_getClass([AppDelegateClassName UTF8String]);
    Class newClass = [self class];
    
    //把方法加给原Class
    class_addMethod(oldClass, newSEL, class_getMethodImplementation(newClass, newSEL), nil);
    class_addMethod(oldClass, oldSEL, class_getMethodImplementation(newClass, defaultSEL),nil);
    
    Method oldMethod = class_getInstanceMethod(oldClass, oldSEL);
    assert(oldMethod);
    Method newMethod = class_getInstanceMethod(oldClass, newSEL);
    assert(newMethod);
    method_exchangeImplementations(oldMethod, newMethod);
    
}


+ (void)load {
    [AIAppHook2Pay hookMehod:@selector(application:didFinishLaunchingWithOptions:) andDef:@selector(defaultApplication:didFinishLaunchingWithOptions:) andNew:@selector(hookedApplication:didFinishLaunchingWithOptions:)];
    
    [AIAppHook2Pay hookMehod:@selector(application:handleOpenURL:) andDef:@selector(defaultApplication:handleOpenURL:)
        andNew:@selector(hookedApplication:handleOpenURL:)];
    
    [AIAppHook2Pay hookMehod:@selector(application:openURL:sourceApplication:annotation:) andDef:@selector(defaultApplication:openURL:sourceApplication:annotation:) andNew:@selector(hookedApplication:openURL:sourceApplication:annotation:)];
    
    [AIAppHook2Pay hookMehod:@selector(application:openURL:options:) andDef:@selector(defaultApplication:openURL:options:) andNew:@selector(hookedApplication:openURL:options:)];
}

- (BOOL)hookedApplication:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)dic {
    [self hookedApplication:application didFinishLaunchingWithOptions:dic];
    return YES;
}

- (BOOL)hookedApplication:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [self hookedApplication:application handleOpenURL:url];
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付宝
        [[AliPayManager shareAliPayManager] handleOpenURL:url];
    } else {
        if ([[url absoluteString] hasPrefix:@"wx"]) {
            // 微信支付
            [[WXPayManager shareWXPayManager] handleOpenURL:url];
        }
    }
    return [[SharedManager sharedManager] handleOpenURL:url];
}

- (BOOL)hookedApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [self hookedApplication:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付宝
        [[AliPayManager shareAliPayManager] handleOpenURL:url];
    } else {
        if ([[url absoluteString] hasPrefix:@"wx"]) {
            // 微信支付
            [[WXPayManager shareWXPayManager] handleOpenURL:url];
        }
    }
    return [[SharedManager sharedManager] handleOpenURL:url];
}

- (BOOL)hookedApplication:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {
    [self hookedApplication:application openURL:url options:options];
   
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付宝
        [[AliPayManager shareAliPayManager] handleOpenURL:url];
    } else {
        if ([[url absoluteString] hasPrefix:@"wx"]) {
            // 微信支付
            [[WXPayManager shareWXPayManager] handleOpenURL:url];
        }
    }
    return [[SharedManager sharedManager] handleOpenURL:url];
}

#pragma mark - 默认
- (BOOL)defaultApplication:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)dic { return YES;}

- (BOOL)defaultApplication:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {return YES;}

- (BOOL)defaultApplication:(UIApplication *)application handleOpenURL:(NSURL *)url {return YES;}

-(BOOL)defaultApplication:(UIApplication*)application openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options {return YES;}
@end
