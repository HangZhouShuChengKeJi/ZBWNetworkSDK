//
//  ZBWNetworkSDK.h
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/9/20.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBWNWRequest.h"
#import "ZBWNWResponse.h"


/**
 登录结果
 
 @param isSuccess 是否成功。在ZBWNWLoginHandleBlock中调用。
 */
typedef void (^ZBWNWLoginResultBlock)(BOOL isSuccess);

// 登录的具体实现
typedef void (^ZBWNWLoginHandleBlock) (ZBWNWLoginResultBlock);


@interface ZBWNetworkSDK : NSObject

@property (nonatomic, copy) ZBWNWLoginHandleBlock    loginHandleBlock;   // 登录实现

/**
 *  单例实例
 *
 */
+ (instancetype)instance;

@end
