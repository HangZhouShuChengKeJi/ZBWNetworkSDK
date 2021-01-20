//
//  ZBWNWGetUrlRequest.m
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/11/7.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import "ZBWNWGetUrlRequest.h"

@implementation ZBWNWGetUrlRequest

+ (instancetype)requestWithUrl:(NSString *)urlStr
{
    ZBWNWGetUrlRequest *request = [[ZBWNWGetUrlRequest alloc] init];
    request.apiName = [urlStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return request;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.type = ZBWNWRequestType_Get;
    }
    return self;
}


#pragma mark- ZBWNWRequestProtocol

- (NSMutableURLRequest *)assembleRequest
{
    return [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.apiName]
                                        cachePolicy:0
                                    timeoutInterval:self.timeOutInterval];
}

- (ZBWNWResponse *)assembleResponse:(id)respondseObj httpResponse:(NSHTTPURLResponse *)httpResponse error:(NSError *)error
{
    ZBWNWResponse *resp = [[ZBWNWResponse alloc] init];
    resp.isSuccess = error == NULL;
    resp.respObject = respondseObj;
    return resp;
}


@end
