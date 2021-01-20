//
//  ZBWNWDelegate.h
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/9/20.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZBWNWRequest;
@class ZBWNWResponse;

@protocol  ZBWNWDelegate <NSObject>

@optional

- (void)request:(ZBWNWRequest *)request didFinishRequesting:(ZBWNWResponse *)response;
- (void)request:(ZBWNWRequest *)request uploadProgress:(NSProgress *)progress;
- (void)request:(ZBWNWRequest *)request downloadProgress:(NSProgress *)progress;

@end



@protocol ZBWNWValidatorDelegate <NSObject>

@end


@protocol ZBWNWInterceptorDelegate <NSObject>

@optional
- (void)request:(ZBWNWRequest *)request beforePerformSuccessWithResponse:(ZBWNWResponse *)response;
- (void)request:(ZBWNWRequest *)request afterPerformSuccessWithResponse:(ZBWNWResponse *)response;
//
- (void)request:(ZBWNWRequest *)request beforePerformFailWithResponse:(ZBWNWResponse *)response;
- (void)request:(ZBWNWRequest *)request afterPerformFailWithResponse:(ZBWNWResponse *)response;

- (BOOL)request:(ZBWNWRequest *)request shouldCallAPIWithParams:(NSDictionary *)params;
- (void)request:(ZBWNWRequest *)request afterCallingAPIWithParams:(NSDictionary *)params;

@end
