//
//  ZBWNWResponse.h
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/9/20.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZBWNWResponse : NSObject

@property (nonatomic, assign) BOOL  isSuccess;
//@property (nonatomic, assign) APIErrorType  errorType;
@property (nonatomic, copy) NSString *errTip;
@property (nonatomic) id respObject;

@property (nonatomic) NSError *error;
// HTTP返回码和头部
@property (nonatomic, assign) NSInteger   statusCode;
@property (nonatomic, copy)NSDictionary *respHeaders;

@end
