//
//  TFNetworkProxy.h
//  tfcommon
//
//  Created by Bowen on 16/6/13.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBWNWProxy : NSObject

+ (NSString *)request:(NSURLRequest *)request
       uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock
     downloadProgress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
    completionHandler:(void (^)(NSURLResponse * response, id responseObject, NSError *error))completionHandler;

+ (NSString *)request:(NSURLRequest *)request
  callbackToSubThread:(BOOL)callbackToSubThread
       uploadProgress:(void (^)(NSProgress *uploadProgress))uploadProgressBlock
     downloadProgress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
    completionHandler:(void (^)(NSURLResponse * response, id responseObject, NSError *error))completionHandler;

+ (void)cancelWithIdentify:(NSString *)identifyStr;

@end
