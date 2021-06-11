//
//  ZHNetworkingTool.m
//  ZHNetworking
//
//  Created by zenghong on 2019/5/28.
//  Copyright © 2019 zenghong. All rights reserved.
//

#import "ZHNetworkingTool.h"
#import "MacroHeader.h"
#import "ZHNetworkingCache.h"
#import "ZHNetworkingResponse.h"
#import "ZHNetworkingError.h"
#import "ZHNetworkingBase.h"
@implementation ZHNetworkingTool
+(void)ZH_SetRequestSerializer:(RequestSerializer)requestSerializer{
    [ZHNetworkingBase setRequestSerializer:requestSerializer];
}
+(void)ZH_SetResponseSerializer:(ResponseSerializer)responseSerilizer{
    [ZHNetworkingBase setResponseSerializer:responseSerilizer];
}
+(void)ZH_SetRequestTimeInterval:(NSTimeInterval)timeInterval{
    NSAssert(timeInterval<=0, @"request timeInterval must greater than zero");
    [ZHNetworkingBase setRequestTimeInterval:timeInterval];
}
+(void)initialize{
    [ZHNetworkingCache memeryAutoLoginNumber:3];
    [ZHNetworkingBase setupDomainWithString:host];
}
#pragma mark --设置自动登录限制次数
+(void)ZH_SetAutoLoginTimes:(NSInteger)times{
    [ZHNetworkingCache memeryAutoLoginNumber:times];
}
#pragma mark --请求数据
+(void)requestWithMethod:(RequestMethod)method url:(NSString *)url parameter:(NSDictionary *)parameter encode:(BOOL)encode containSuccess:(BOOL)containSuccess setToken:(BOOL)setToken progressBlock:(DownloadOrUploadProgressBlock)progressBlock successBlock:(OptionalSuccessBlock)successBlock optionalFailBlock:(OptionalFailBlock)optionalFailBlock failBlock:(RequestToolFailBlock)failBlock{
    if([url containsString:@"scripts/ios"]){
        [ZHNetworkingTool ZH_SetResponseSerializer:ResponseSerializer_HTTP];
    }else{
        [ZHNetworkingTool ZH_SetResponseSerializer:ResponseSerializer_JSON];
    }
    if (encode) {
        parameter = [self encodeParameterWithDictionary:parameter];
    }
    if (setToken) {
        NSString * token = [ZHNetworkingCache obtainMemoryToken];
        if (!NetworkingEmptyString(token)) {
//            if ([NSDate judgementExpirationWithIntervalSince1970:[ZHNetworkingCache obtainSessionTokenExpiration]]){
//                optionalFailBlock(nil,@"session time out",-1,-1,NO,[ZHNetworkingBase Reachcble],NO);
//            }
//            else{
//                if ([NSDate judgementExpirationWithIntervalSince1970:[ZHNetworkingCache obtainMemoryTokenExpiration]]) {
//                    [self refreshTokenWithMethod:method url:url parameter:parameter containSuccess:containSuccess progressBlock:progressBlock successBlock:successBlock optionalFailBlock:optionalFailBlock failBlock:failBlock];
//                }
//                else{
                    [ZHNetworkingBase setValue:token forHTTPHeaderFiled:@"authorization"];
                    [self requestDateWithMethod:method url:url parameter:parameter containSuccess:containSuccess progressBlock:progressBlock successBlock:successBlock optionalFailBlock:optionalFailBlock failBlock:failBlock];
//                }
//            }
        }else{
            
        }
    }
    else{
        [self requestDateWithMethod:method url:url parameter:parameter containSuccess:containSuccess progressBlock:progressBlock successBlock:successBlock optionalFailBlock:optionalFailBlock failBlock:failBlock];
    }
}
+(void)requestDateWithMethod:(RequestMethod)method url:(NSString *)url parameter:(NSDictionary *)parameter containSuccess:(BOOL)containSuccess progressBlock:(DownloadOrUploadProgressBlock)progressBlock successBlock:(OptionalSuccessBlock)successBlock optionalFailBlock:(OptionalFailBlock)optionalFailBlock failBlock:(RequestToolFailBlock)failBlock{
    [ZHNetworkingBase request:method url:url parameter:parameter progressBlock:^(NSProgress * _Nullable progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock?progressBlock(progress):nil;
        });
    } successBlock:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull responseobject, BOOL reachable) {
        if ([responseobject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * dictionary = (NSDictionary *)responseobject;
            if (containSuccess) {
                __block BOOL success = NO;
                [dictionary.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString * key = (NSString *)obj;
                    if ([[key lowercaseString] isEqualToString:@"success"]) {
                        success = [dictionary[key] boolValue];
                    }
                }];
                if (success) {
                    successBlock(response,responseobject,[ZHNetworkingBase Reachcble]);
                }
                else{
                    optionalFailBlock(response,@"",-1,response.statusCode,NO,[ZHNetworkingBase Reachcble],[ZHNetworkingResponse judegementNeedAutologinWithResponse:response]);
                }
            }
            else{
                BOOL success= [ZHNetworkingError AnalysisRequestSuccess:responseobject];
                if (success) {
                    successBlock(response,responseobject,[ZHNetworkingBase Reachcble]);
                }
                else{
                    optionalFailBlock(response,@"",-1,response.statusCode,NO,[ZHNetworkingBase Reachcble],[ZHNetworkingResponse judegementNeedAutologinWithResponse:response]);
                }
            }
        }
        else{
            successBlock(response,responseobject,[ZHNetworkingBase Reachcble]);
        }
    } failBlock:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error, BOOL cancel, BOOL reachale) {
        __block NSString * errorMessage = nil;
        //__block NSInteger errorCode = -1;
        __block NSInteger FailCode = -1;
        [ZHNetworkingError AnalysisError:error completeBlock:^(NSString * _Nonnull message,NSInteger optionalFailCode, NSInteger code) {
            errorMessage = message;
            //errorCode = code;
            FailCode = optionalFailCode;
        }];
        if (response.statusCode == 401&& FailCode == 1100) {
//            [self refreshTokenWithMethod:method url:url parameter:parameter containSuccess:containSuccess progressBlock:progressBlock successBlock:successBlock optionalFailBlock:optionalFailBlock failBlock:failBlock];
        }
        else{
            failBlock(response,error,errorMessage,FailCode,response.statusCode,cancel,reachale,[ZHNetworkingResponse judegementNeedAutologinWithResponse:response]);
        }
    }];;
}
+(NSDictionary *)encodeParameterWithDictionary:(NSDictionary *)dictionary{
    NSMutableDictionary * middleDic = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    [dictionary.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * key = (NSString *)obj;
        id value = dictionary[key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            [middleDic setObject:[self dictionaryTransilateToString:(NSDictionary *)value] forKey:key];
        }
    }];
    return middleDic;
}

+(NSString *)dictionaryTransilateToString:(NSDictionary *)dictionary{
    NSError * error = nil;
    NSData * data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (!data) {
        NSLog(@"%@",error);
    }
    else{
        return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+(NSURLSessionTask *)uploadImagesWithUrl:(NSString *)url parameter:(NSDictionary *)parameter name:(NSString *)name images:(NSArray<UIImage *> *)imageArray imageScale:(float)imageScale imageType:(NSString *)imageType fileNames:(NSArray<NSString *> *)fileNames progress:(DownloadOrUploadProgressBlock)progressBlock successBlock:(OptionalSuccessBlock)successBlock failBlock:(RequestToolFailBlock)failBlock{
    return [ZHNetworkingBase uploadImagesWithUrl:url parameter:parameter name:name images:imageArray imageScale:imageScale imageType:imageType fileNames:fileNames progress:^(NSProgress * _Nullable progress) {
        
    } successBlock:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, id  _Nonnull responseobject, BOOL reachable) {
        successBlock(response,responseobject,[ZHNetworkingBase Reachcble]);
    } failBlock:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error, BOOL cancel, BOOL reachale) {
        __block NSString * errorMessage = nil;
        //__block NSInteger errorCode = -1;
        __block NSInteger FailCode = -1;
        [ZHNetworkingError AnalysisError:error completeBlock:^(NSString * _Nonnull message,NSInteger optionalFailCode, NSInteger code) {
            errorMessage = message;
            //errorCode = code;
            FailCode = optionalFailCode;
        }];
        if (response.statusCode == 401&& FailCode == 1100) {
#warning 刷新token
        }
        else{
            failBlock(response,error,errorMessage,FailCode,response.statusCode,cancel,reachale,[ZHNetworkingResponse judegementNeedAutologinWithResponse:response]);
        }
    }];
}

@end
