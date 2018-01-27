//
//  NSData+Crypto.h
//  Encrypt
//
//  Created by wuyj on 15/7/3.
//  Copyright (c) 2015年 wuyj. All rights reserved.
//


#import <Foundation/Foundation.h>


@interface NSData (Crypto)

- (NSData *)AES128DecryptWithKey:(NSString *)key gIv:(NSString *)Iv;
- (NSData *)AES128EncryptWithKey:(NSString *)key gIv:(NSString *)Iv;

@end
