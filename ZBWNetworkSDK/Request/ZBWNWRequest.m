//
//  ZBWNWRequest.m
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/9/20.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import "ZBWNWRequest.h"
#import "ZBWNWProxy.h"
#import "ZBWNetworkSDK.h"

dispatch_queue_t ZBWNw_requestQueue()
{
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue = nil;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.haihu.ZBWNwrequest.queue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

@interface ZBWNWRequest ()

@property (nonatomic, retain) NSMutableDictionary   *requestHeader;

@property (nonatomic, assign) NSInteger             retriedCount;
@property (nonatomic, copy) NSString                *identifyStr;

@property (nonatomic) NSOperation                   *operation;

@property (nonatomic, weak) NSThread                *syncThread;

@end

@implementation ZBWNWRequest

- (instancetype)init
{
    if (self = [super init]) {
        if ([self.class conformsToProtocol:@protocol(ZBWNWRequestProtocol)]) {
            self.requestProtocol = (id<ZBWNWRequestProtocol>)self;
        }
        self.timeOutInterval = 10.0;
    }
    return self;
}

- (void)setReqeustHeader:(NSString *)value forKey:(NSString *)key
{
    if (!key) {
        return;
    }
    if (!value) {
        [self.requestHeader removeObjectForKey:key];
    } else {
        [self.requestHeader setObject:value forKey:key];
    }
}


#pragma mark- 发起请求
- (void)request
{
    self.retriedCount = 0;
    // 登录检查
    if (self.autoLogin) {
        if([ZBWNetworkSDK instance].loginHandleBlock)
        {
            ZBWNWLoginResultBlock resultBlock = ^(BOOL isSucceed){
                if (isSucceed) {
                    // 接着请求
                    [self startRequest];
                } else {
                    // 取消请求
                }
            };
            [ZBWNetworkSDK instance].loginHandleBlock(resultBlock);
        }
    } else {
        [self startRequest];
    }
}

- (void)startRequest
{
    self.operation = [self startOperation];
}

- (NSOperation *)startOperation
{
    NSOperation *operation = [[NSOperation alloc] init];
    dispatch_async(ZBWNw_requestQueue(), ^{
        if (operation.isCancelled) {
            return;
        }
        NSMutableURLRequest *request = nil;
        if (self.requestProtocol && [self.requestProtocol respondsToSelector:@selector(assembleRequest)]) {
            request = [self.requestProtocol assembleRequest];
        }
        request.timeoutInterval = self.timeOutInterval;
        [self.requestHeader enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
        [request setHTTPMethod:request.HTTPBody.length > 0 ? @"POST" : @"GET"];
        
        if (operation.isCancelled) {
            return;
        }
        // 发起请求
        [self _request:request];
    });
    return operation;
}

- (void)_request:(NSURLRequest *)reqeust
{
    if (!reqeust) {
        return;
    }
    // 请求
    self.identifyStr = [ZBWNWProxy request:reqeust
                      callbackToSubThread:YES
                           uploadProgress:^(NSProgress *uploadProgress) {
                               if ([self.delegate respondsToSelector:@selector(request:uploadProgress:)]) {
                                   [self.delegate request:self uploadProgress:uploadProgress];
                               }
                               self.uploadProgressBlock ? self.uploadProgressBlock(uploadProgress) : nil;
                           }
                         downloadProgress:^(NSProgress *downloadProgress) {
                             if ([self.delegate respondsToSelector:@selector(request:downloadProgress:)]) {
                                 [self.delegate request:self downloadProgress:downloadProgress];
                             }
                             self.downloadProgressBlock ? self.downloadProgressBlock(downloadProgress) : nil;
                         }
                        completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                            [self onRequestCompletion:response responseObject:responseObject error:error];
                        }];
}

- (void)onRequestCompletion:(NSURLResponse *)response responseObject:(id)responseObject error:(NSError *)error
{
    // 已取消
    if (self.operation.isCancelled) {
        return;
    }
    
    // 是否重试
    if (error && self.retriedCount++ < self.retryTimes) {
        // 重试
        [self startRequest];
    }
    else {
        __weak typeof(self) weakSelf = self;
        dispatch_async(ZBWNw_requestQueue(), ^{
            ZBWNWResponse *resp = nil;
            if (self.requestProtocol && [self.requestProtocol respondsToSelector:@selector(assembleResponse:httpResponse:error:)]){
                resp = [self.requestProtocol assembleResponse:responseObject httpResponse:(NSHTTPURLResponse *)response error:error];
            } else {
                resp = [[ZBWNWResponse alloc] init];
                resp.respObject = responseObject;
                resp.isSuccess = error ? NO : YES;
            }
            resp.error = error;
            resp.respHeaders = [(NSHTTPURLResponse *)response allHeaderFields];
            resp.statusCode = [(NSHTTPURLResponse *)response statusCode];
            resp.request = self;
            
            if ([self.requestProtocol respondsToSelector:@selector(afterAssembleResponse:)]) {
                [self.requestProtocol afterAssembleResponse:resp];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.completeBlock ? weakSelf.completeBlock(resp) : nil;
                if ([self.delegate respondsToSelector:@selector(request:didFinishRequesting:)]) {
                    [self.delegate request:self didFinishRequesting:resp];
                }
            });
            
            // 如果是同步请求
            if (self.syncThread) {
                [self performSelector:@selector(releaseAsyRequest) onThread:self.syncThread withObject:nil waitUntilDone:NO];
            }
        });
    }
    
    //
}

#pragma mark- 异步请求

- (NSString *)synFlag
{
    return [NSString stringWithFormat:@"__Network_Need_Hold__%p",self];
}

- (void)syncRequest
{
    [self request];
    
    NSThread *currentThread = [NSThread currentThread];
    if (![currentThread isMainThread]) {
        [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSRunLoopCommonModes];
    }
    self.syncThread = currentThread;
    NSMutableDictionary *dic = [currentThread threadDictionary];
    NSString *key = [self synFlag];
    dic[key] = @"";
    id needHold = dic[key];
    while (needHold) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
        BOOL isHold = [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        NSAssert(isHold, @"");
#pragma clang diagnostic pop
        needHold = [currentThread threadDictionary][key];
    }
}

- (void)releaseAsyRequest
{
    [[[NSThread currentThread] threadDictionary] removeObjectForKey:[self synFlag]];
}

#pragma mark- 取消请求
- (void)cancel
{
    if (self.operation && !self.operation.cancelled) {
        [self.operation cancel];
    }
    [ZBWNWProxy cancelWithIdentify:self.identifyStr];
}

@end
