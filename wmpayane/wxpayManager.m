//
//  wxpayManager.m
//  wmpayane
//
//  Created by wuyoujian on 2018/1/11.
//

#import "wxpayManager.h"

@implementation wxpayManager

+ (wxpayManager*)sharewxpayManager {
    static wxpayManager *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

@end
