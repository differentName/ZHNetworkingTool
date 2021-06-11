//
//  ZHNetworkingTool.h
//  ZHNetworking
//
//  Created by zenghong on 2019/5/28.
//  Copyright © 2019 zenghong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHNetworkingBase.h"
NS_ASSUME_NONNULL_BEGIN
//**请求完成且操作成功*/
typedef void(^OptionalSuccessBlock)(NSHTTPURLResponse * response,id responseobject,BOOL reachable);
//**请求失败*/
typedef void(^RequestToolFailBlock)(NSHTTPURLResponse * response,NSError * error,NSString * message,NSInteger optionalFailCode,NSInteger code,BOOL cancel,BOOL reachale,BOOL needAutoLogin);
//**请求成功操作失败*/
typedef void(^OptionalFailBlock)(NSHTTPURLResponse * response,NSString * message,NSInteger optionalFailCode,NSInteger code,BOOL cancel,BOOL reachale,BOOL needAutoLogin);
@interface ZHNetworkingTool : NSObject

/**
 有网络
 */
+(void)ZH_IsReachable;

/**
 流量
 */
+(void)ZH_IsViaWAN;

/**
 wifi
 */
+(void)ZH_IsViaWiFi;

/**
 设置请求的编码格式
 
 @param requestSerializer 编码格式
 */
+(void)ZH_SetRequestSerializer:(RequestSerializer)requestSerializer;

/**
 设置响应的编码格式
 
 @param responseSerilizer 编码格式
 */
+(void)ZH_SetResponseSerializer:(ResponseSerializer)responseSerilizer;

/**
 设置自动登录次数
 
 @param times 次数
 */
+(void)ZH_SetAutoLoginTimes:(NSInteger)times;

/**
 设置请求超时时间
 
 @param timeInterval 超时间
 */
+(void)ZH_SetRequestTimeInterval:(NSTimeInterval)timeInterval;

/**
 请求数据
 
 @param method 请求方式
 @param url 请求链接
 @param parameter 参数
 @param encode 是否需要编码
 @param containSuccess 是否包含success 字段
 @param setToken 是否需要设置token
 @param progressBlock 进度
 @param successBlock 操作成功的回调
 @param optionalFailBlock 操作失败的回调
 @param failBlock 请求失败的回调
 */
+(void)requestWithMethod:(RequestMethod)method
                     url:(NSString *)url
               parameter:(NSDictionary *)parameter
                  encode:(BOOL)encode
          containSuccess:(BOOL)containSuccess
                setToken:(BOOL)setToken
           progressBlock:(DownloadOrUploadProgressBlock)progressBlock
            successBlock:(OptionalSuccessBlock)successBlock
       optionalFailBlock:(OptionalFailBlock)optionalFailBlock
               failBlock:(RequestToolFailBlock)failBlock;

/**
 自动登录
 */
+(void)autoLogin;

/**
 刷新token
 
 @param method 请求方式
 @param url 链接
 @param parameter 参数
 @param encode 是否处理参数
 @param containSuccess 是否包含success
 @param progressBlock 请求的进度
 @param successBlock 操作成功的回调
 @param optionalFailBlock 操作失败的回调
 @param failBlock 请求失败的回调
 */
+(void)requestRefreshTokenWithMethod:(RequestMethod)method
                                 url:(NSString *)url
                           parameter:(NSDictionary *)parameter
                              encode:(BOOL)encode
                      containSuccess:(BOOL)containSuccess
                       progressBlock:(DownloadOrUploadProgressBlock)progressBlock
                        successBlock:(OptionalSuccessBlock)successBlock
                   optionalFailBlock:(OptionalFailBlock)optionalFailBlock
                           failBlock:(RequestToolFailBlock)failBlock;


/**
 上传一张或多张图片
 
 @param url 请求的链接
 @param parameter 参数
 @param name 存储文件的名称
 @param imageArray 图片
 @param imageScale 图片的压缩比例
 @param imageType  图片格式
 @param fileNames 图片名称
 @param progressBlock 进度
 @param successBlock 成功的回调
 @param failBlock 失败的回调
 @return task
 */
+( NSURLSessionTask * _Null_unspecified)uploadImagesWithUrl:(NSString *)url
                                                  parameter:(NSDictionary *)parameter
                                                       name:(NSString *)name
                                                     images:( NSArray<UIImage *> * _Nonnull)imageArray
                                                 imageScale:(float)imageScale
                                                  imageType:(NSString *)imageType
                                                  fileNames:(NSArray<NSString *>*)fileNames
                                                   progress:(DownloadOrUploadProgressBlock)progressBlock
                                               successBlock:(OptionalSuccessBlock)successBlock
                                                  failBlock:(RequestToolFailBlock)failBlock;
@end

NS_ASSUME_NONNULL_END
