//
//  GetRSARequest.h
//  wmane
//
//  Created by wuyoujian on 2018/1/13.
//

#import <Foundation/Foundation.h>

typedef void(^requestFinishBlock)(NSString *rsaKey);


@interface GetRSARequest : NSObject
@property(nonatomic,copy) NSString          *url;
@property(nonatomic,assign) NSTimeInterval  timeout;
@property(nonatomic,copy) NSString          *appId;

- (void)getRSAKeyFinishBlock:(requestFinishBlock)block;

@end
