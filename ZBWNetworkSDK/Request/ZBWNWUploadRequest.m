//
//  ZBWNWUploadRequest.m
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/11/8.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import "ZBWNWUploadRequest.h"
#import <UIKit/UIKit.h>

@implementation ZBWNWUploadRequest

- (NSMutableURLRequest *)assembleRequest
{
    return [ZBWNWUploadRequest requestFormUploadingData:self.data
                                                 toURL:[NSURL URLWithString:self.url]
                                          withFileName:self.fileName
                                          forFieldName:self.fieldName
                                withAdditionalPOSTData:self.additionalData];
}

- (ZBWNWResponse *)assembleResponse:(id)respondseObj httpResponse:(NSHTTPURLResponse *)httpResponse error:(NSError *)error
{
    return [[ZBWNWResponse alloc] init];
}


+ (NSMutableURLRequest *)requestFormUploadingData:(NSData *)data
                                            toURL:(NSURL *)url
                                     withFileName:(NSString *)fileName
                                     forFieldName:(NSString *)fieldName
                           withAdditionalPOSTData:(NSDictionary *)POSTdata

{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    //添加文件data
    NSString *boundary = [[NSProcessInfo processInfo] globallyUniqueString];
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSData *fieldBoundary = [[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *bodyEndBoundary = [[NSString stringWithFormat:@"--%@--",boundary] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *returnBoundary = [[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *postData = [[NSMutableData alloc] init];
    // body 开始
    [postData appendData:fieldBoundary];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName ?:@"empty_name", fileName ?: @"empty_file_name"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:data];
    // \r\n
    [postData appendData:returnBoundary];
    
    //添加额外的key value
    [POSTdata enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSData *value;
        if ([obj isKindOfClass:[NSString class]]) {
            value = [obj dataUsingEncoding:NSUTF8StringEncoding];
        } else if ([obj isKindOfClass:[NSData class]]){
            value = obj;
        } else if ([obj isKindOfClass:[UIImage class]]) {
            value = UIImagePNGRepresentation(obj);
        } else if ([obj isKindOfClass:[NSArray class]]) {
            value = [[(NSArray *)obj componentsJoinedByString:@","] dataUsingEncoding:NSUTF8StringEncoding];
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            value = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
        } else if ([obj respondsToSelector:@selector(stringValue)]) {
            value = [[obj stringValue] dataUsingEncoding:NSUTF8StringEncoding];
        } else {
            value = [[NSString stringWithFormat:@"%@", obj] dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        if (value) {
            [postData appendData:fieldBoundary];
            [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:value];
            // \r\n
            [postData appendData:returnBoundary];
        }
    }];
    
    // body 结束
    [postData appendData:bodyEndBoundary];
    
    [request setHTTPBody:postData];
    return request;
}

@end
