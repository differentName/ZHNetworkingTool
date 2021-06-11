//
//  ZHNetworkingError.h
//  ZHNetworking
//
//  Created by zenghong on 2019/5/28.
//  Copyright © 2019 zenghong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZHNetworkingError : NSObject

+(void)AnalysisError:(NSError * _Null_unspecified )error completeBlock:(void(^)(NSString * message,NSInteger optionalFailCode,NSInteger state))completeBlock;

+(BOOL)AnalysisRequestSuccess:(NSDictionary *)dictonary;

+(void)requestFail:(NSHTTPURLResponse *)response error:(NSError  * _Nullable)error message:(NSString *)message optionalFailCode:(NSInteger)optionalFailCode code:(NSInteger)code cancel:(BOOL)cancel reachale:(BOOL)reachale needAutoLogin:(BOOL)needAutoLogin;
@end

NS_ASSUME_NONNULL_END
