//
//  ZHNetworkingResponse.m
//  ZHNetworking
//
//  Created by zenghong on 2019/5/28.
//  Copyright © 2019 zenghong. All rights reserved.
//

#import "ZHNetworkingResponse.h"

@implementation ZHNetworkingResponse
+(BOOL)judegementNeedAutologinWithResponse:(NSHTTPURLResponse *)response{
    if (([response.URL.absoluteString containsString:@"login"]||[response.URL.absoluteString containsString:@"Login"])&&response.statusCode==200) {
        return YES;
    }
    return NO;
}
@end
