//
//  AESEncrypt.m
//  wmane
//
//  Created by wuyoujian on 2018/1/27.
//

#import "AESEncrypt.h"
#import "NSData+Crypto.h"



#define kEncryptIv @"_weimeitiancheng"

@implementation AESEncrypt

+ (NSString *)encrypt:(NSString *)content key:(NSString *)key {
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSData *enData = [data AES128EncryptWithKey:key gIv:kEncryptIv];
    NSString *base64 = [enData base64EncodedStringWithOptions:0];
    return base64;
}

+ (NSString *)decrypt:(NSString *)encrypt key:(NSString *)key  {
    NSData *base64Data = [[NSData alloc] initWithBase64EncodedString:encrypt options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSData *enData = [base64Data AES128DecryptWithKey:key gIv:kEncryptIv];
    NSString *content = [[NSString alloc] initWithData:enData encoding:NSUTF8StringEncoding];
    
    return content;
}

@end
