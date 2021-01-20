//
//  TFNetworkProxy.m
//  tfcommon
//
//  Created by Bowen on 16/6/13.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import "ZBWNWProxy.h"
#import <AFNetworking/AFNetworking.h>
#import <objc/runtime.h>

@interface ZBWNWProxy ()

@property (nonatomic) NSMutableDictionary       *taskMap;               // task的字典。 key：task的内存字符串 ，value：task
@property (nonatomic) dispatch_queue_t          queue;                  // 同步队列，同步操作taskMap
@property (nonatomic) AFHTTPSessionManager      *sessionManager;        // 请求的sessionManager

#pragma mark- 回调在子线程中
@property (nonatomic) AFHTTPSessionManager      *synSessionManager;     // 请求的sessionManager
@property (nonatomic) dispatch_queue_t          queueForSyn;            // 回调queue

@end

@implementation ZBWNWProxy

#pragma mark- Public Methods

+ (NSString *)request:(NSURLRequest *)request
       uploadProgress:(void (^)(NSProgress *))uploadProgressBlock
     downloadProgress:(void (^)(NSProgress *))downloadProgressBlock
    completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler
{
    return [[ZBWNWProxy getInstance] _request:request
                              callbackToSubThread:NO
                                   uploadProgress:uploadProgressBlock
                                 downloadProgress:downloadProgressBlock
                                completionHandler:completionHandler];
}

+ (NSString *)request:(NSURLRequest *)request
  callbackToSubThread:(BOOL)callbackToSubThread
       uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock
     downloadProgress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
    completionHandler:(void (^)(NSURLResponse * response, id responseObject, NSError *error))completionHandler
{
    return [[ZBWNWProxy getInstance] _request:request
                              callbackToSubThread:callbackToSubThread
                                   uploadProgress:uploadProgressBlock
                                 downloadProgress:downloadProgressBlock
                                completionHandler:completionHandler];
}


+ (void)cancelWithIdentify:(NSString *)identifyStr
{
    if (!identifyStr) {
        return;
    }
    
    [[ZBWNWProxy getInstance] _cancelWithIdentify:identifyStr];
}

#pragma mark- Private Methods

+ (instancetype)getInstance
{
    static dispatch_once_t onceToken;
    static ZBWNWProxy *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[ZBWNWProxy alloc] init];
    });
    return instance;
}

- (NSString *)_request:(NSURLRequest *)request
   callbackToSubThread:(BOOL)callbackToSubThread
        uploadProgress:(void (^)(NSProgress *))uploadProgressBlock
      downloadProgress:(void (^)(NSProgress *))downloadProgressBlock
     completionHandler:(void (^)(NSURLResponse *, id, NSError *))completionHandler
{
    __block NSURLSessionDataTask *task = nil;
    __block NSString *identifyStr = nil;
    
    void (^completionBlock)(NSURLResponse *, id, NSError *) = ^(NSURLResponse *response, id respObj, NSError *error){
        completionHandler ? completionHandler(response, respObj, error) : nil;
        dispatch_async(self.queue, ^{
            [self.taskMap removeObjectForKey:identifyStr];
        });
    };
    
    Class sessionManagerClass = NSClassFromString(@"AFURLSessionManager");
    
    AFHTTPSessionManager *sessionManager = callbackToSubThread ? self.synSessionManager : self.sessionManager;
    
    // >=3.1.0 的版本
    if ([sessionManager respondsToSelector:@selector(dataTaskWithRequest:uploadProgress:downloadProgress:completionHandler:)]) {
        IMP imp = NULL;
        SEL sel = @selector(dataTaskWithRequest:uploadProgress:downloadProgress:completionHandler:);
        if (sessionManagerClass) {
            imp = class_getMethodImplementation(sessionManagerClass, sel);
        }
        if (imp) {
            NSURLSessionDataTask* (*oImp1)(id,SEL,NSURLRequest*, void (^)(NSProgress *),void (^)(NSProgress *),void (^)(NSURLResponse *, id _Nullable,  NSError * _Nullable)) = (NSURLSessionDataTask* (*)(id,SEL,NSURLRequest*, void (^)(NSProgress *),void (^)(NSProgress *),void (^)(NSURLResponse *, id _Nullable,  NSError * _Nullable)))imp;
            task = oImp1(sessionManager, sel, request, uploadProgressBlock, downloadProgressBlock, completionBlock);
        }
    } else if ([sessionManager respondsToSelector:@selector(dataTaskWithRequest:completionHandler:)]){
        // 2.6.3版本
        IMP imp = NULL;
        SEL sel = @selector(dataTaskWithRequest:completionHandler:);
        if (sessionManagerClass) {
            imp = class_getMethodImplementation(sessionManagerClass, sel);
        }
        if (imp) {
            NSURLSessionDataTask* (*oImp1)(id,SEL,NSURLRequest*,void (^)(NSURLResponse *, id _Nullable,  NSError * _Nullable)) = (NSURLSessionDataTask* (*)(id,SEL,NSURLRequest*,void (^)(NSURLResponse *, id _Nullable,  NSError * _Nullable)))imp;
            task = oImp1(sessionManager, sel, request, completionBlock);
        }
    }
    if (!task) {
        task = [sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:completionBlock];
//        task = [sessionManager dataTaskWithRequest:request completionHandler:completionBlock];
    }
    
    
    if (task) {
        [task resume];
        identifyStr = [self identifyOfTask:task];
        
        dispatch_sync(self.queue, ^{
            self.taskMap[identifyStr] = task;
        });
        
        return identifyStr;
    }
    
    return nil;
}

- (void)_cancelWithIdentify:(NSString *)identifyStr
{
    dispatch_async(self.queue, ^{
         NSURLSessionDataTask *task = self.taskMap[identifyStr];
        if (task) {
            [task cancel];
            [self.taskMap removeObjectForKey:identifyStr];
        }
    });
}

- (NSString *)identifyOfTask:(id)task
{
    return [NSString stringWithFormat:@"%p", task];
}

#pragma mark- Getter

- (AFHTTPSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _sessionManager;
}

- (NSMutableDictionary *)taskMap
{
    if (!_taskMap) {
        _taskMap = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    return _taskMap;
}

- (dispatch_queue_t)queue
{
    if (_queue == NULL) {
        _queue = dispatch_queue_create("com.TFNetworkProxy.taskQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}

- (dispatch_queue_t)queueForSyn
{
    if (!_queueForSyn) {
        _queueForSyn = dispatch_queue_create("com.TFNetworkProxy.queueForSyn", DISPATCH_QUEUE_SERIAL);
    }
    return _queueForSyn;
}

- (AFHTTPSessionManager *)synSessionManager
{
    if (!_synSessionManager) {
        _synSessionManager = [AFHTTPSessionManager manager];
        _synSessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _synSessionManager.completionQueue = self.queueForSyn;
    }
    return _synSessionManager;
}

@end
