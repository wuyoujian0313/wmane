//
//  AESEncrypt.h
//  wmane
//
//  Created by wuyoujian on 2018/1/27.
//

#import <Foundation/Foundation.h>

@interface AESEncrypt : NSObject

+ (NSString *)encrypt:(NSString *)content key:(NSString *)key;
+ (NSString *)decrypt:(NSString *)encrypt key:(NSString *)key;

@end
