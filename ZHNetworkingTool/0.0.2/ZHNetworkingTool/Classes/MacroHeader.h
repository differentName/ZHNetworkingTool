//
//  MacroHeader.h
//  NetWorkingTool
//
//  Created by 高增洪 on 2021/6/11.
//

#ifndef MacroHeader_h
#define MacroHeader_h
/**域名*/
#define host  @"https://apis.fatcoupon.com/"

//字符串是否为空
#define NetworkingEmptyString(obj) (obj ==nil ||\
[obj isKindOfClass:[NSNull class]]||\
([obj isKindOfClass:[NSString class]]&&obj.length ==0)||\
([obj isKindOfClass:[NSString class]]&&[obj isEqualToString:@""])||\
([obj isKindOfClass:[NSString class]]&&[obj isEqualToString:@"<null>"])||\
![obj isKindOfClass:[NSString class]])


#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]



//控制测试时端口号
#ifndef __OPTIMIZE__
#define Request_PORT @""
#else
#define Request_PORT @""
#endif

#endif /* MacroHeader_h */
