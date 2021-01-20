//
//  ZBWNWRequest.h
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/9/20.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBWNWResponse.h"
#import "ZBWNWDelegate.h"
#import "ZBWNWEnum.h"



/**
 请求的接口类。
 */
@protocol ZBWNWRequestProtocol <NSObject>

@required
// 组装request
- (NSMutableURLRequest *)assembleRequest;
// 组装response
- (ZBWNWResponse *)assembleResponse:(id)respondseObj httpResponse:(NSHTTPURLResponse *)httpResponse error:(NSError *)error;

@optional
- (void)afterAssembleResponse:(ZBWNWResponse*)resp;

@end


@class ZBWNWRequest;

typedef void(^ZBWNWRequestResultBlock) (ZBWNWResponse *response);
typedef void(^ZBWNWProgressBlock) (NSProgress *progress);


/**
 ZBWNWRequest ：网络请求request类。
 */
@interface ZBWNWRequest : NSObject

//@property (nonatomic, copy) NSString            *serverIdentify;        // 服务器标识
@property (nonatomic, copy) NSString                    *url;                   // url
@property (nonatomic, copy) NSString                    *apiName;               // api名
@property (nonatomic, copy) NSDictionary                *bizParamDic;           // 业务参数
@property (nonatomic, copy) NSDictionary                *commonParamDic;        // 公共参数

@property (nonatomic, assign) ZBWNWRequestType           type;
@property (nonatomic, assign) BOOL                      needSign;               // 是否需要签名 【默认为YES】
@property (nonatomic, assign) BOOL                      autoLogin;
@property (nonatomic, assign) BOOL                      needEncrypt;            // 是否需要加密
@property (nonatomic, unsafe_unretained)Class           responseClass;          // 反序列化类

@property (nonatomic, assign) NSTimeInterval            timeOutInterval;        // 超时时长, 默认10s
@property (nonatomic, assign) NSInteger                 retryTimes;             // 默认为0，即超时后不重试

@property (nonatomic, weak) id<ZBWNWRequestProtocol>     requestProtocol;


#pragma mark- 回调方式
@property (nonatomic, weak) id<ZBWNWDelegate>            delegate;                  // 【delegate】方式

@property (nonatomic, copy)ZBWNWRequestResultBlock       completeBlock;              // 完成回调
@property (nonatomic, copy)ZBWNWProgressBlock            uploadProgressBlock;        // 上传进度回调
@property (nonatomic, copy)ZBWNWProgressBlock            downloadProgressBlock;      // 下载进度回调

#pragma mark- http header fields
- (void)setReqeustHeader:(NSString *)value forKey:(NSString *)key;

#pragma mark- 发起请求
- (void)request;

- (void)syncRequest;

#pragma mark- 取消请求
- (void)cancel;




@end
