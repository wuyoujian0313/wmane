/*
 
 Copyright (c) 2012, DIVIJ KUMAR
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met: 
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer. 
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution. 
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies, 
 either expressed or implied, of the FreeBSD Project.
 
 
 */

/*
 * wmane.m
 * wmane
 *
 * Created by wuyoujian on 2018/1/10.
 * Copyright (c) 2018年 ___ORGANIZATIONNAME___. All rights reserved.
 */

#import "wmane.h"


/* wmaneExtInitializer()
 * The extension initializer is called the first time the ActionScript side of the extension
 * calls ExtensionContext.createExtensionContext() for any context.
 *
 * Please note: this should be same as the <initializer> specified in the extension.xml 
 */
void wmaneExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet) 
{
    NSLog(@"Entering wmaneExtInitializer()");

    *extDataToSet = NULL;
    *ctxInitializerToSet = &ContextInitializer;
    *ctxFinalizerToSet = &ContextFinalizer;

    NSLog(@"Exiting wmaneExtInitializer()");
}

/* wmaneExtFinalizer()
 * The extension finalizer is called when the runtime unloads the extension. However, it may not always called.
 *
 * Please note: this should be same as the <finalizer> specified in the extension.xml 
 */
void wmaneExtFinalizer(void* extData) 
{
    NSLog(@"Entering wmaneExtFinalizer()");

    // Nothing to clean up.
    NSLog(@"Exiting wmaneExtFinalizer()");
    return;
}

/* ContextInitializer()
 * The context initializer is called when the runtime creates the extension context instance.
 */
void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    NSLog(@"Entering ContextInitializer()");
    
    /* The following code describes the functions that are exposed by this native extension to the ActionScript code.
     */
    static FRENamedFunction func[] = 
    {
        MAP_FUNCTION(registerWXPaySDK,NULL),
        MAP_FUNCTION(registerAlipaySDK,NULL),
        MAP_FUNCTION(registerShareSDKs, NULL),
        MAP_FUNCTION(sharing_function_is_installed, NULL),
        MAP_FUNCTION(alipay,NULL),
        MAP_FUNCTION(wxpay,NULL),
        MAP_FUNCTION(sharing_function_text,NULL),
        MAP_FUNCTION(sharing_function_link,NULL),
        MAP_FUNCTION(sharing_function_image,NULL),
        MAP_FUNCTION(sharing_function_image_url,NULL),
        MAP_FUNCTION(login_function_qq,NULL),
        MAP_FUNCTION(login_function_wx,NULL),
        MAP_FUNCTION(playAV, NULL),
        MAP_FUNCTION(playAVForLocal, NULL),
        MAP_FUNCTION(encrypt_wm, NULL),
        MAP_FUNCTION(decrypt_wm, NULL),
    };
    
    *numFunctionsToTest = sizeof(func) / sizeof(FRENamedFunction);
    *functionsToSet = func;
    
    context = ctx;
    globalANEExFuc = [[ANEExtensionFunc alloc] initWithContext:ctx];
}

/* ContextFinalizer()
 * The context finalizer is called when the extension's ActionScript code
 * calls the ExtensionContext instance's dispose() method.
 * If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls ContextFinalizer().
 */
void ContextFinalizer(FREContext ctx) 
{
    NSLog(@"Entering ContextFinalizer()");
    // Nothing to clean up.
    NSLog(@"Exiting ContextFinalizer()");
    return;
}

ANE_FUNCTION(registerWXPaySDK) {
    return [globalANEExFuc registerWXPaySDK:argv[0] appSecret:argv[1] partner:argv[2]];
}

ANE_FUNCTION(registerAlipaySDK) {
    return [globalANEExFuc registerAlipaySDK:argv[0] appSecret:argv[1]];
}

ANE_FUNCTION(registerShareSDKs) {
    return [globalANEExFuc registerShareSDKs:argv[0]];
}

ANE_FUNCTION(sharing_function_is_installed) {
    return [globalANEExFuc isAppInstalled];
}

ANE_FUNCTION(alipay) {
    return [globalANEExFuc alipay:argv[0]];
}

ANE_FUNCTION(wxpay) {
    return [globalANEExFuc wxpay:argv[0]];
}

ANE_FUNCTION(sharing_function_text) {
    return [globalANEExFuc sendText:argv[0]];
}

ANE_FUNCTION(sharing_function_link) {
    return [globalANEExFuc sendLinkTitle:argv[0] text:argv[1] url:argv[2]];
}

ANE_FUNCTION(sharing_function_image) {
    return [globalANEExFuc sendImage:argv[0]];
}

ANE_FUNCTION(sharing_function_image_url) {
    return [globalANEExFuc sendImageUrl:argv[0]];
}

ANE_FUNCTION(login_function_qq) {
    return [globalANEExFuc loginByQQ];
}

ANE_FUNCTION(login_function_wx) {
    return [globalANEExFuc loginByWX];
}

ANE_FUNCTION(playAV) {
    return [globalANEExFuc playAV:argv[0]];
}

ANE_FUNCTION(playAVForLocal) {
    return [globalANEExFuc playAVForLocal:argv[0]];
}

ANE_FUNCTION(encrypt_wm) {
    return [globalANEExFuc encrypt:argv[0]];
}


ANE_FUNCTION(decrypt_wm) {
    return [globalANEExFuc decrypt:argv[0]];
}

