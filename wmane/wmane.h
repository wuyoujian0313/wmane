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
 * wmane
 *
 * Created by wuyoujian on 2018/1/10.
 * Copyright (c) 2018年 ___ORGANIZATIONNAME___. All rights reserved.
*/

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import "ANEExtensionFunc.h"

FREContext context;
ANEExtensionFunc *globalANEExFuc;

#define ANE_FUNCTION(f) FREObject (f)(FREContext ctx, void *data, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(f, data) { (const uint8_t*)(#f), (data), &(f) }

/* wmaneExtInitializer()
 * The extension initializer is called the first time the ActionScript side of the extension
 * calls ExtensionContext.createExtensionContext() for any context.
 *
 * Please note: this should be same as the <initializer> specified in the extension.xml 
*/
void wmaneExtInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet);

/* wmaneExtFinalizer()
 * The extension finalizer is called when the runtime unloads the extension. However, it may not always called.
 *
 * Please note: this should be same as the <finalizer> specified in the extension.xml 
*/
void wmaneExtFinalizer(void* extData);

/* ContextInitializer()
 * The context initializer is called when the runtime creates the extension context instance.
*/
void ContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

/* ContextFinalizer()
 * The context finalizer is called when the extension's ActionScript code
 * calls the ExtensionContext instance's dispose() method.
 * If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls ContextFinalizer().
*/
void ContextFinalizer(FREContext ctx);

ANE_FUNCTION(registerWXPaySDK);
ANE_FUNCTION(registerAlipaySDK);

// 注册分享sdk
/*
 参数采用json字符串(UTF-8编码)传递
 例如：
 [{"appId":"*****","appSecret":"***"},{"appId":"*****","appSecret":"***"}]
 */
ANE_FUNCTION(registerShareSDKs);


ANE_FUNCTION(sharing_function_text);
ANE_FUNCTION(sharing_function_link);
ANE_FUNCTION(sharing_function_image);
ANE_FUNCTION(sharing_function_image_url);
ANE_FUNCTION(sharing_function_is_installed);

// 支付接口，参数采用json字符串(UTF-8编码)传递；
/*
 字段:
 goodsDesc :商品描述
 goodsName :商品名称
 orderNo   :订单号
 price     :商品价格
 scheme    :应用程序配置的scheme
 
 例如：
 {"goodsDesc":"描述","goodsName":"名称","orderNo":"123321","price":"12.0","scheme":"alipayXXXX"}
 */
ANE_FUNCTION(alipay);
ANE_FUNCTION(wxpay);

ANE_FUNCTION(login_function_qq);
ANE_FUNCTION(login_function_wx);

ANE_FUNCTION(playAV);
ANE_FUNCTION(playAVForLocal);

ANE_FUNCTION(encrypt_wm);
ANE_FUNCTION(decrypt_wm);
