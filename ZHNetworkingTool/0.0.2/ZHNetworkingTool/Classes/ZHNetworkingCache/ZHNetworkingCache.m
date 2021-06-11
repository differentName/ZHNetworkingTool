//
//  ZHNetworkingCache.m
//  ZHNetworking
//
//  Created by zenghong on 2019/5/31.
//  Copyright © 2019 zenghong. All rights reserved.
//

#import "ZHNetworkingCache.h"
#import <pthread.h>
static NSString *  const tokenIdentify = @"tokenIdentify";
static NSString *  const tokenExpirationIdentify = @"tokenExpirationIdentify";
static NSString *  const sessionExpirationIdentify = @"sessionExpirationIdentify";
static NSString * const autologinNumberIdentify         = @"autologinNumber";
static NSString * const signInIdentify = @"signInIdentify";

@implementation ZHNetworkingCache
+(void)memeryAutoLoginNumber:(NSUInteger)number{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:number] forKey:autologinNumberIdentify];
    [[NSUserDefaults standardUserDefaults] synchronize];
    pthread_mutex_unlock(&mutex);
}
+(NSUInteger)obtainMemoryLoginNumber{
    NSInteger number = [[[NSUserDefaults standardUserDefaults] objectForKey:autologinNumberIdentify] integerValue];
    if (number <=0) {
        number = 0;
    }
    return number;
}
+(void)clearMemoryAutoLoginNumber{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:autologinNumberIdentify];
    [[NSUserDefaults standardUserDefaults] synchronize];
    pthread_mutex_unlock(&mutex);
}
+(void)memoryTokenWithString:(NSString *)token{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:tokenIdentify];
    [[NSUserDefaults standardUserDefaults] synchronize];
    pthread_mutex_unlock(&mutex);
    
}
+(NSString *)obtainMemoryToken{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    return [[NSUserDefaults standardUserDefaults] objectForKey:tokenIdentify];
    pthread_mutex_unlock(&mutex);
}
+(void)removeMemoryToken{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:tokenIdentify];
    [[NSUserDefaults standardUserDefaults] synchronize];
    pthread_mutex_unlock(&mutex);
}
#pragma mark -- token时间戳
+(void)memoryTokenExpirationWithString:(NSString *)tokenExpiration{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    [[NSUserDefaults standardUserDefaults] setObject:tokenExpiration forKey:tokenExpirationIdentify];
    [[NSUserDefaults standardUserDefaults] synchronize];
    pthread_mutex_unlock(&mutex);
}
+(NSString *)obtainMemoryTokenExpiration{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    return [[NSUserDefaults standardUserDefaults] objectForKey:tokenExpirationIdentify];
    pthread_mutex_unlock(&mutex);
}
+(void)removeMemoryTokenExpiration{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:tokenExpirationIdentify];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark --session 时间戳
+(void)memorySessionExpirationWithString:(NSString *)sessionExpiration{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    [[NSUserDefaults standardUserDefaults] setObject:sessionExpiration forKey:sessionExpirationIdentify];
    [[NSUserDefaults standardUserDefaults] synchronize];
    pthread_mutex_unlock(&mutex);
}
+(NSString *)obtainSessionTokenExpiration{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    return [[NSUserDefaults standardUserDefaults] objectForKey:sessionExpirationIdentify];
}
+(void)removeMemorySessionExpiration{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:sessionExpirationIdentify];
    [[NSUserDefaults standardUserDefaults] synchronize];
    pthread_mutex_unlock(&mutex);
}
+(void)memoryTokenMessageWithDictionary:(NSDictionary *)dictionary{
    if ([dictionary.allKeys containsObject:@"token"]) {
        [self memoryTokenWithString:dictionary[@"token"]];
    }
    if ([dictionary.allKeys containsObject:@"sessionExpiration"]) {
        [self memorySessionExpirationWithString:dictionary[@"sessionExpiration"]];
    }
    if ([dictionary.allKeys containsObject:@"tokenExpiration"]) {
        [self memoryTokenExpirationWithString:dictionary[@"tokenExpiration"]];
    }
}
+(void)loginOut{
    [self removeMemoryToken];
    [self removeMemoryTokenExpiration];
    [self removeMemorySessionExpiration];
}

+(void)memorySignInIdentify:(NSString *)userIdentify{
    __block pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
    pthread_mutex_lock(&mutex);
    [[NSUserDefaults standardUserDefaults] setObject:userIdentify forKey:signInIdentify];
    [[NSUserDefaults standardUserDefaults] synchronize];
    pthread_mutex_unlock(&mutex);
}
@end
