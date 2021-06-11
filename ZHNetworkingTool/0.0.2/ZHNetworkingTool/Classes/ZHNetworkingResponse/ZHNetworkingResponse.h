//
//  ZHNetworkingResponse.h
//  ZHNetworking
//
//  Created by zenghong on 2019/5/28.
//  Copyright © 2019 zenghong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHNetworkingResponse : NSObject
/**
 判断是否需要自动登录
 
 @param response 响应
 @return 是否需要
 */
+(BOOL)judegementNeedAutologinWithResponse:(NSHTTPURLResponse *)response;
@end

NS_ASSUME_NONNULL_END
