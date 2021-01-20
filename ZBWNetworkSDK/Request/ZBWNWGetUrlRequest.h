//
//  ZBWNWGetUrlRequest.h
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/11/7.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import "ZBWNWRequest.h"


/**
 GET 请求
 */
@interface ZBWNWGetUrlRequest : ZBWNWRequest <ZBWNWRequestProtocol>

+ (instancetype)requestWithUrl:(NSString *)urlStr;

@end
