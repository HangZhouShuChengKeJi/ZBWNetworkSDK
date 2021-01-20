//
//  ZBWNetworkSDK.m
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/9/20.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import "ZBWNetworkSDK.h"

@implementation ZBWNetworkSDK

+ (instancetype)instance
{
    static dispatch_once_t onceToken;
    static ZBWNetworkSDK *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ZBWNetworkSDK alloc] init];
    });
    return instance;
}

@end
