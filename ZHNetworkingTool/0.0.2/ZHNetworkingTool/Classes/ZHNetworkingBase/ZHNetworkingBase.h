//
//  ZHNetworkingBase.h
//  ZHNetworking
//
//  Created by zenghong on 2019/5/28.
//  Copyright © 2019 zenghong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
/**请求的编码格式*/
typedef NS_ENUM(NSInteger,RequestSerializer){
    RequestSerializer_HTTP, //二进制
    RequestSerializer_JSON //json格式
};
//**响应的编码格式*/
typedef NS_ENUM(NSInteger,ResponseSerializer){
 ResponseSerializer_HTTP,
 ResponseSerializer_JSON
};
typedef NS_ENUM(NSInteger,NetworkingState){
    NetworkingState_UnKnown, //为止
    NetworkingState_UnReachable, //没有网络
    NetworkingState_ReachableViaWAN, //流量
    NetworkingState_ReachableViaWIFI //wifi
};
typedef NS_ENUM(NSInteger,RequestMethod){
    RequestMethod_Get,
    RequestMethod_Post,
    RequestMethod_Put,
    RequestMethod_Delete
};
//**请求成功的回调*/
typedef void(^RequestSuccessBlock)(NSURLRequest * _Nonnull request,NSHTTPURLResponse * _Nonnull response,_Nonnull id responseobject,BOOL reachable);
//**请求失败的回调*/
typedef void(^RequestFailBlock)(NSURLRequest * _Nonnull request,NSHTTPURLResponse * _Nonnull response,NSError * _Nonnull error,BOOL cancel,BOOL reachale);
//**w网络状态的回调*/
typedef void(^NetworkingStateBlock)(NetworkingState state);
//**下载进度的回调*/
typedef void(^DownloadOrUploadProgressBlock)(NSProgress * _Nullable progress);

NS_ASSUME_NONNULL_BEGIN

@interface ZHNetworkingBase : NSObject
/**
 是否有网
 
 @return 是否有网络
 */
+(BOOL)Reachcble;

//**手机网络*/
+(BOOL)isViaWAN;

/**
 是否是wifi
 
 @return wifi
 */
+(BOOL)isViaWiFi;

/**
 取消全部的网络请求
 */
+(void)cancelAllRequest;

/**
 取消指定的网络请求
 
 @param url 请求链接
 @param parameter 参数
 */
+(void)cancelRequestWithURL:(NSString *)url parameter:(NSDictionary *)parameter;


/**
 设置主域名
 
 @param domain 域名
 */
+(void)setupDomainWithString:(nonnull NSString *)domain;

+(NSString *)jointUrlWithUrl:(NSString *)path;

/**
 设置超时时间
 
 @param timeInterval 超时时间
 */
+(void)setRequestTimeInterval:(NSTimeInterval)timeInterval;

/**
 设置请求编码方式
 
 @param requestSerializer 编码方式
 */
+(void)setRequestSerializer:(RequestSerializer)requestSerializer;

/**
 设置响应编码方式
 
 @param responseSerializer 响应编码方式
 */
+(void)setResponseSerializer:(ResponseSerializer)responseSerializer;

/**
 设置请求头
 
 @param value 值
 @param field 键
 */
+(void)setValue:(NSString *)value forHTTPHeaderFiled:(NSString *)field;
/**
 请求
 
 @param requestMethod 请求方式
 @param url 请求链接
 @param parameter 参数
 @param progressBlock 请求进度
 @param sucessBlock 成功的回调
 @param failBlock 失败的回调
 @return task
 */
+( NSURLSessionTask * _Null_unspecified)request:(RequestMethod)requestMethod
                                            url:(NSString * _Nonnull)url
                                      parameter:(NSDictionary *)parameter
                                  progressBlock:(DownloadOrUploadProgressBlock)progressBlock
                                   successBlock:(RequestSuccessBlock)sucessBlock
                                      failBlock:(RequestFailBlock)failBlock;

/**
 开始监听网络
 
 @param stateBlock 网络状态
 */
+(void)startNetworkingMonitorWithBlock:(void(^)(NetworkingState state))stateBlock;

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
                                               successBlock:(RequestSuccessBlock)successBlock
                                                  failBlock:(RequestFailBlock)failBlock;


/**
 上传文件
 
 @param url 请求的链接
 @param name 存储文件的路径名称
 @param parameter 参数
 @param filePath 文件在本机的存储路径
 @param progress 上传进度
 @param successBlock 成功的回调
 @param failBlock 失败的回调
 @return task
 */
+( NSURLSessionTask * _Null_unspecified)uploadFileWithUrl:(NSString *)url
                                                     name:(NSString * _Nonnull)name
                                                parameter:(NSDictionary *)parameter
                                                 filePath:(NSString *)filePath
                                                 progress:(DownloadOrUploadProgressBlock)progress
                                             successBlock:(RequestSuccessBlock)successBlock
                                                failBlock:(RequestFailBlock)failBlock;


/**
 下载文件
 
 @param url 下载的地址
 @param filePath 文件存储路径
 @param progress 进度
 @param successBlock 成功的回调
 @param failBlock 失败的回调
 @return task
 */
+( NSURLSessionTask * _Null_unspecified)downloadFileWithUrl:(NSString *)url
                                                   filePath:(NSString * _Nonnull)filePath
                                                   progress:(DownloadOrUploadProgressBlock)progress
                                               successBlock:(RequestSuccessBlock)successBlock
                                                  failBlock:(RequestFailBlock)failBlock;

/**
 暂停下载
 
 @param url 请求的地址
 @param filePath 文件的存储路径
 @param progress 进度
 @param successBlock 成功的回调
 @param failBlock 失败的回调
 @return task
 */
+( NSURLSessionTask * _Null_unspecified)stopDownloadFileWithURL:(NSString *)url
                                                       filePath:(NSString *_Nonnull)filePath
                                                       progress:(DownloadOrUploadProgressBlock)progress
                                                   successBlock:(RequestSuccessBlock)successBlock
                                                      failBlock:(RequestFailBlock)failBlock;
@end

NS_ASSUME_NONNULL_END
