//
//  ZBWNWEnum.h
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/9/20.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZBWNWErrorType)
{
    ZBWNWErrorType_Unknown = 0,               // 未知
    ZBWNWErrorType_Not_Network = 1,           // 无可用网络
    ZBWNWErrorType_TimeOut,                   // 请求超时
    ZBWNWErrorType_NeedLogin,                 // 需要登录 （session失效、需要登录鉴权）
    ZBWNWErrorType_ParamInvalid               // 无效参数
};


typedef NS_ENUM(NSInteger, ZBWNWRequestType)
{
    ZBWNWRequestType_Get = 0,
    ZBWNWRequestType_Post
};
