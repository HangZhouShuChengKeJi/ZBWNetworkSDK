//
//  ZBWNWUploadRequest.h
//  ZBWNetworkSDK
//
//  Created by Bowen on 16/11/8.
//  Copyright © 2016年 Bowen. All rights reserved.
//

#import "ZBWNWRequest.h"

/**
 Upload上传数据
 */
@interface ZBWNWUploadRequest : ZBWNWRequest<ZBWNWRequestProtocol>

@property (nonatomic,retain) NSData         *data;              // 数据
@property (nonatomic, copy) NSDictionary    *additionalData;    // 附加数据
@property (nonatomic, copy) NSString        *fileName;          // filename
@property (nonatomic, copy) NSString        *fieldName;         // fieldName

@end
