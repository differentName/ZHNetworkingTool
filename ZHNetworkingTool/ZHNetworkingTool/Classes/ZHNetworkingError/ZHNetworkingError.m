//
//  ZHNetworkingError.m
//  ZHNetworking
//
//  Created by zenghong on 2019/5/28.
//  Copyright © 2019 zenghong. All rights reserved.
//

#import "ZHNetworkingError.h"
#import "ZHNetworkingCache.h"

static NSString * const ResponseSerializationErrorDomain = @"com.alamofire.error.serialization.response";
static NSString * const OperationFailingURLResponseErrorKey = @"com.alamofire.serialization.response.error.response";
static NSString * const OperationFailingURLResponseDataErrorKey = @"com.alamofire.serialization.response.error.data";
@implementation ZHNetworkingError

+(void)AnalysisError:(NSError * _Null_unspecified )error completeBlock:(void(^)(NSString * message,NSInteger optionalFailCode,NSInteger state))completeBlock{
    if (!error||[error isKindOfClass:[NSNull class]]) {
        completeBlock(@"error is empty",-1,-1);
    }
    else{
        NSDictionary * messageDictionary = nil;
        if ([[error.userInfo allKeys] containsObject:OperationFailingURLResponseDataErrorKey]) {
            NSData * userInfoData = [error.userInfo objectForKey:OperationFailingURLResponseDataErrorKey];
            if (userInfoData.bytes>0) {
                messageDictionary =  [NSJSONSerialization JSONObjectWithData:userInfoData options:NSJSONReadingMutableContainers error:nil];
                if (messageDictionary ==nil ||[messageDictionary isKindOfClass:[NSNull class]]) {
                    messageDictionary = error.userInfo;
                }
            }
            else{
                messageDictionary = error.userInfo;
            }
        }
        else{
            messageDictionary = error.userInfo;
        }
        completeBlock([self obtainErrorMessageWithDictionary:messageDictionary],[self obtainErrorCodeWithDictionary:messageDictionary],error.code);
    }
}

#pragma mark --获取错误信息
+(NSString *)obtainErrorMessageWithDictionary:(NSDictionary *)dictionary{
    if (!dictionary||[dictionary isKindOfClass:[NSNull class]]) {
        return nil;
    }
    else{
        if ([dictionary.allKeys containsObject:@"msg"]) {
            return dictionary[@"msg"];
        }
        else if ([dictionary.allKeys containsObject:@"MSG"]){
            return dictionary[@"MSG"];
        }
        else if ([dictionary.allKeys containsObject:@"Message"]){
            return dictionary[@"Message"];
        }
        else if ([dictionary.allKeys containsObject:@"MessageDetail"]){
            return dictionary[@"MessageDetail"];
        }
        else if([dictionary.allKeys containsObject:@"NSLocalizedDescription"]){
            return dictionary[@"NSLocalizedDescription"];
        }
        else if([dictionary.allKeys containsObject:@"NSDebugDescription"]){
            return dictionary[@"NSDebugDescription"];
        } else if ([dictionary.allKeys containsObject:@"errmsg"]) {
            return dictionary[@"errmsg"];
        }
        else{
            return nil;
        }
    }
}

+(NSInteger)obtainErrorCodeWithDictionary:(NSDictionary *)dictionary{
    if (!dictionary||[dictionary isKindOfClass:[NSNull class]]) {
        return -1;
    }
    else{
        if ([dictionary.allKeys containsObject:@"errno"]) {
            return [dictionary[@"errno"] integerValue];
        }
        return -1;
    }
}

+(BOOL)AnalysisRequestSuccess:(NSDictionary *)dictonary{
    if ([dictonary.allKeys containsObject:@"errmsg"]&& [dictonary.allKeys containsObject:@"errno"]) {
        if ([dictonary[@"errmsg"] isEqualToString:@""]&& [dictonary[@"errno"] integerValue] ==0) {
            return YES;
        }
        return NO;
    }
    return YES;
}

+ (void)requestFail:(NSHTTPURLResponse *)response error:(NSError *)error message:(NSString *)message optionalFailCode:(NSInteger)optionalFailCode code:(NSInteger)code cancel:(BOOL)cancel reachale:(BOOL)reachale needAutoLogin:(BOOL)needAutoLogin{
    if (reachale) {
        if (response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"url---%@,code----%li",response.URL,code);
                
            });
        }
        else if(!response && [message isEqualToString:@"session time out"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //重新登录
                
                [ZHNetworkingCache loginOut];
                
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"url---%@,code----%li",response.URL,code);
//                [SVProgressHUD showErrorWithStatus:@"Network unavailable"];
            });
        }
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            //Network unavailable
            NSLog(@"url---%@,code----%li",response.URL,code);
            
        });
    }
}
@end
