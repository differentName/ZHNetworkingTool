//
//  ZHNetworkingBase.m
//  ZHNetworking
//
//  Created by zenghong on 2019/5/28.
//  Copyright © 2019 zenghong. All rights reserved.
//

#import "ZHNetworkingBase.h"
#import "MacroHeader.h"
#import <AFNetworking/AFNetworking-umbrella.h>
static AFHTTPSessionManager * manager = nil;
static NSMutableArray * _allSessionTask;
static NSString * _domainName;

@implementation ZHNetworkingBase

+(void)load{
    //开始监听网络
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
+(void)startNetworkingMonitorWithBlock:(void (^)(NetworkingState))stateBlock{
    AFNetworkReachabilityManager * manager = [AFNetworkReachabilityManager sharedManager];
    //    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                stateBlock ? stateBlock(NetworkingState_UnKnown) : nil;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                stateBlock ? stateBlock(NetworkingState_UnReachable) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                stateBlock ? stateBlock(NetworkingState_ReachableViaWAN) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                stateBlock ? stateBlock(NetworkingState_ReachableViaWIFI) : nil;
                break;
        }
    }];
}
+(BOOL)isViaWiFi{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}
+(BOOL)isViaWAN{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}
+(BOOL)Reachcble{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}
#pragma mark --初始化设置
+(void)initialize{
    manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 200;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*",nil];
}
#pragma mark --设置主域名
+(void)setupDomainWithString:(NSString *)domain{
    if (NetworkingEmptyString(domain)) {
        return;
    }
    _domainName = domain.copy;
}
#pragma mark --设置请求头
+(void)setValue:(NSString *)value forHTTPHeaderFiled:(NSString *)field{
    [manager.requestSerializer setValue:value forHTTPHeaderField:field];
}
#pragma mark --设置请求编码格式
+(void)setRequestSerializer:(RequestSerializer)requestSerializer{
    if (requestSerializer ==RequestSerializer_HTTP) {
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    if (requestSerializer == RequestSerializer_JSON) {
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
}
#pragma mark --设置响应编码格式
+(void)setResponseSerializer:(ResponseSerializer)responseSerializer{
    if (responseSerializer == ResponseSerializer_HTTP) {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    if (responseSerializer == ResponseSerializer_JSON) {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
}
+(void)setRequestTimeInterval:(NSTimeInterval)timeInterval{
    manager.requestSerializer.timeoutInterval = timeInterval;
}
#pragma mark --取消全部请求
+(void)cancelAllRequest{
    @synchronized (self) {
        [self.allSessionTask enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSURLSessionTask * task = (NSURLSessionTask *)obj;
            [task cancel];
        }];
        [self.allSessionTask removeAllObjects];
    }
}
#pragma mark --取消指定的请求
+(void)cancelRequestWithURL:(NSString *)url parameter:(NSDictionary *)parameter{
    @synchronized (self) {
        __block NSInteger index = -1;
        [self.allSessionTask enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSURLSessionTask * task = (NSURLSessionTask *)obj;
            if ([task.currentRequest.URL.absoluteString isEqualToString:url]) {
                index = idx;
                *stop = YES;
            }
        }];
        [self.allSessionTask removeObjectAtIndex:index];
    }
}
#pragma mark --存储着所有的请求task数组
+ (NSMutableArray *)allSessionTask {
    if (!_allSessionTask) {
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}
#pragma mark --下载文件
+(NSURLSessionTask *)downloadFileWithUrl:(NSString *)url filePath:(NSString *)filePath progress:(DownloadOrUploadProgressBlock)progress successBlock:(RequestSuccessBlock)successBlock failBlock:(RequestFailBlock)failBlock{
    url = [self jointUrlWithUrl:url].copy;
    if (NetworkingEmptyString(url)) {
        NSLog(@"url is empty");
        return nil;
    }
    NSURLRequest * request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    __block NSURLSessionDownloadTask * task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress ? progress(downloadProgress) : nil;
        });
    }destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //拼接缓存目录
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:filePath ? filePath : @"Download"];
        //打开文件管理器
        NSFileManager *fileManager = [NSFileManager defaultManager];
        //创建Download目录
        [fileManager createDirectoryAtPath:downloadDir withIntermediateDirectories:YES attributes:nil error:nil];
        //拼接文件路径
        NSString *fileTotalPath = [downloadDir stringByAppendingPathComponent:response.suggestedFilename];
        //返回文件位置的URL路径
        return [NSURL fileURLWithPath:fileTotalPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //请求是否被取消
        BOOL isCancel = NO;
        if (task.error.code ==NSURLErrorCancelled||![[self allSessionTask] containsObject:task]) {
            isCancel = YES;
        }
        NSURLRequest * request = task.currentRequest;
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        [[self allSessionTask] removeObject:task];
        if(failBlock && error) {failBlock(request,httpResponse,error,isCancel,[self Reachcble]) ; return ;};
        successBlock ? successBlock(request,httpResponse,filePath.absoluteString,[self Reachcble] /** NSURL->NSString*/) : nil;
    }];
    //开始下载
    [task resume];
    task? [[self allSessionTask] addObject:task] : nil ;
    return task;
}
#pragma mark --请求数据
+(NSURLSessionTask *)request:(RequestMethod)requestMethod url:(NSString *)url parameter:(NSDictionary *)parameter progressBlock:(DownloadOrUploadProgressBlock)progressBlock successBlock:(RequestSuccessBlock)sucessBlock failBlock:(RequestFailBlock)failBlock{
    url = [self jointUrlWithUrl:url].copy;
    if (NetworkingEmptyString(url)) {
        NSLog(@"url is empty");
        return nil;
    }
    if (requestMethod ==RequestMethod_Get) {
        
        __block NSURLSessionTask * task = [manager GET:url parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                progressBlock?progressBlock(downloadProgress):nil;
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
            NSURLRequest * request = task.currentRequest;
            [[self allSessionTask] removeObject:task];
            sucessBlock?sucessBlock(request,response,responseObject,[self Reachcble]):nil;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
            NSURLRequest * request = task.currentRequest;
            //请求是否被取消
            BOOL isCancel = NO;
            if (task.error.code ==NSURLErrorCancelled||![[self allSessionTask] containsObject:task]) {
                isCancel = YES;
            }
            [[self allSessionTask] removeObject:task];
            failBlock?failBlock(request,response,error,isCancel,[self Reachcble]):nil;
        }];
        task?[[self  allSessionTask] addObject:task]:nil;
        return  task;
    }else if(requestMethod == RequestMethod_Delete){
         __block NSURLSessionTask * task = [manager DELETE:url parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
            NSURLRequest * request = task.currentRequest;
            sucessBlock?sucessBlock(request,response,responseObject,[self Reachcble]):nil;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
            NSURLRequest * request = task.currentRequest;
            //请求是否被取消
            BOOL isCancel = NO;
            if (task.error.code ==NSURLErrorCancelled||![[self allSessionTask] containsObject:task]) {
                isCancel = YES;
            }
            [[self allSessionTask] removeObject:task];
            failBlock?failBlock(request,response,error,isCancel,[self Reachcble]):nil;
        }];
       
        task?[[self  allSessionTask] addObject:task]:nil;
        return  task;
    }else if(requestMethod == RequestMethod_Put){
        __block NSURLSessionTask * task = [manager PUT:url parameters:parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
            NSURLRequest * request = task.currentRequest;
            [[self allSessionTask] removeObject:task];
            sucessBlock?sucessBlock(request,response,responseObject,[self Reachcble]):nil;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
            NSURLRequest * request = task.currentRequest;
            //请求是否被取消
            BOOL isCancel = NO;
            if (task.error.code ==NSURLErrorCancelled||![[self allSessionTask] containsObject:task]) {
                isCancel = YES;
            }
            [[self allSessionTask] removeObject:task];
            failBlock?failBlock(request,response,error,isCancel,[self Reachcble]):nil;
        }];
        task?[[self  allSessionTask] addObject:task]:nil;
        return  task;
    }
    else{
        __block NSURLSessionTask * task = [manager POST:url parameters:parameter progress:^(NSProgress * _Nonnull uploadProgress) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                progressBlock?progressBlock(uploadProgress):nil;
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
            NSURLRequest * request = task.currentRequest;
            sucessBlock?sucessBlock(request,response,responseObject,[self Reachcble]):nil;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
            NSURLRequest * request = task.currentRequest;
            //请求是否被取消
            BOOL isCancel = NO;
            if (task.error.code ==NSURLErrorCancelled||![[self allSessionTask] containsObject:task]) {
                isCancel = YES;
            }
            [[self allSessionTask] removeObject:task];
            failBlock?failBlock(request,response,error,isCancel,[self Reachcble]):nil;
        }];
        task?[[self  allSessionTask] addObject:task]:nil;
        return  task;
    }
}
#pragma mark --下载文件
+(NSURLSessionTask *)uploadFileWithUrl:(NSString *)url name:(NSString *)name parameter:(NSDictionary *)parameter filePath:(NSString *)filePath progress:(DownloadOrUploadProgressBlock)progress successBlock:(RequestSuccessBlock)successBlock failBlock:(RequestFailBlock)failBlock{
    __block NSURLSessionTask * task = [manager POST:url parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:filePath] name:name error:&error];
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
        NSURLRequest * request = task.currentRequest;
        BOOL isCancel = NO;
        if (task.error.code ==NSURLErrorCancelled||![[self allSessionTask] containsObject:task]) {
            isCancel = YES;
        }
        (failBlock && error) ? failBlock(request,response,error,isCancel,[self Reachcble]) : nil;
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            progress?progress(uploadProgress):nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
        NSURLRequest * request = task.currentRequest;
        successBlock?successBlock(request,response,responseObject,[self Reachcble]):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
        NSURLRequest * request = task.currentRequest;
        //请求是否被取消
        BOOL isCancel = NO;
        if (task.error.code ==NSURLErrorCancelled||![[self allSessionTask] containsObject:task]) {
            isCancel = YES;
        }
        [[self allSessionTask] removeObject:task];
        failBlock?failBlock(request,response,error,isCancel,[self Reachcble]):nil;
    }];
    task?[[self  allSessionTask] addObject:task]:nil;
    return task;
}
#pragma mark --上传图片
+(NSURLSessionTask *)uploadImagesWithUrl:(NSString *)url parameter:(NSDictionary *)parameter name:(NSString *)name images:(NSArray<UIImage *> *)imageArray imageScale:(float)imageScale imageType:(NSString *)imageType fileNames:(NSArray<NSString *> *)fileNames progress:(DownloadOrUploadProgressBlock)progressBlock successBlock:(RequestSuccessBlock)successBlock failBlock:(RequestFailBlock)failBlock{
    url = [self jointUrlWithUrl:url].copy;
    __block NSURLSessionTask * task = [manager POST:url parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSUInteger i = 0; i < imageArray.count; i++) {
            // 图片经过等比压缩后得到的二进制文件
            NSData *imageData = UIImageJPEGRepresentation(imageArray[i], imageScale ?: 1.f);
            // 默认图片的文件名, 若fileNames为nil就使用
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = NSStringFormat(@"%@%ld.%@",str,i,imageType?:@"jpg");
            [formData appendPartWithFileData:imageData
                                        name:name
                                    fileName:fileNames ? NSStringFormat(@"%@.%@",fileNames[i],imageType?:@"jpg") : imageFileName
                                    mimeType:NSStringFormat(@"image/%@",imageType ?: @"jpg")];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            progressBlock?progressBlock(uploadProgress):nil;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
        NSURLRequest * request = task.currentRequest;
        successBlock?successBlock(request,response,responseObject,[self Reachcble]):nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)task.response;
        NSURLRequest * request = task.currentRequest;
        //请求是否被取消
        BOOL isCancel = NO;
        if (task.error.code ==NSURLErrorCancelled||![[self allSessionTask] containsObject:task]) {
            isCancel = YES;
        }
        [[self allSessionTask] removeObject:task];
        failBlock?failBlock(request,response,error,isCancel,[self Reachcble]):nil;
    }];
    task?[[self  allSessionTask] addObject:task]:nil;
    return task;
}
#pragma mark --设置请求链接
+(NSString *)jointUrlWithUrl:(NSString *)path{
    if (NetworkingEmptyString(path)) {
        return @"";
    }
    if (NetworkingEmptyString(_domainName)) {
        return path;
    }
    if ([path hasPrefix:@"http://"]||[path hasPrefix:@"https://"]) {
        return path;
    }
    else{
        if ([_domainName hasSuffix:@"/"]) {
            if ([path hasPrefix:@"/"]) {
                NSMutableString * middleString = [NSMutableString stringWithString:path];
                [middleString deleteCharactersInRange:NSMakeRange(0, 1)];
                if (!NetworkingEmptyString(Request_PORT)) {
                    return [NSString stringWithFormat:@"%@:%@%@",[_domainName substringWithRange:NSMakeRange(0, _domainName.length-1)],Request_PORT,path];
                }
                else{
                    return [NSString stringWithFormat:@"%@%@",_domainName,middleString];
                }
            }
            else{
                if (!NetworkingEmptyString(Request_PORT)) {
                    NSString * string = [NSString stringWithFormat:@"%@:%@/",[_domainName substringWithRange:NSMakeRange(0, _domainName.length-1)],Request_PORT];
                    return  [NSString stringWithFormat:@"%@%@",string,path];
                }
                return [NSString stringWithFormat:@"%@%@",_domainName,path];
            }
        }
        else{
            if ([path hasPrefix:@"/"]) {
                if (!NetworkingEmptyString(Request_PORT)) {
                    return  [NSString stringWithFormat:@"%@:%@%@",_domainName,Request_PORT,path];
                }
                return  [NSString stringWithFormat:@"%@%@",_domainName,path];
            }
            else{
                if (!NetworkingEmptyString(Request_PORT)) {
                    return  [NSString stringWithFormat:@"%@:%@/%@",_domainName,Request_PORT,path];
                }
                return  [NSString stringWithFormat:@"%@/%@",_domainName,path];
            }
        }
    }
}

@end
