//
//  ZHNetworkingCache.h
//  ZHNetworking
//
//  Created by zenghong on 2019/5/31.
//  Copyright © 2019 zenghong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHNetworkingCache : NSObject
/**
 存储的自动登录次数
 
 @param number 次数
 */
+(void)memeryAutoLoginNumber:(NSUInteger)number;

/**
 获取自动登录次数
 
 @return 自动登录次数
 */
+(NSUInteger)obtainMemoryLoginNumber;

/**
 移除存储的自动登录次数
 */
+(void)clearMemoryAutoLoginNumber;

/**
 存储token
 
 @param token token
 */
+(void)memoryTokenWithString:(NSString *)token;

/**
 获取存储的token
 
 @return token
 */
+(NSString *)obtainMemoryToken;

/**
 移除token
 */
+(void)removeMemoryToken;

/**
 截止时间戳
 
 @param sessionExpiration 截止时间戳
 */
+(void)memorySessionExpirationWithString:(NSString *)sessionExpiration;

/**
 获取存储的时间戳
 
 @return 间隔
 */
+(NSString *)obtainSessionTokenExpiration;

/**
 移除间隔
 */
+(void)removeMemorySessionExpiration;

/**
 存储时间戳
 
 @param tokenExpiration 时间戳
 */
+(void)memoryTokenExpirationWithString:(NSString *)tokenExpiration;

/**
 获取存储的时间戳
 
 @return 时间戳
 */
+(NSString *)obtainMemoryTokenExpiration;

/**
 移除戳
 */
+(void)removeMemoryTokenExpiration;


+(void)memoryTokenMessageWithDictionary:(NSDictionary *)dictionary;

+(void)loginOut;

/// 存储用户唯一标识
/// @param userIdentify 唯一标识
+(void)memorySignInIdentify:(NSString *)userIdentify;
@end

NS_ASSUME_NONNULL_END
