//
//  MyUpyunFile.m
//  FC-HttpClient_Example
//
//  Created by fang on 2018/5/15.
//  Copyright © 2018 fangqk1991. All rights reserved.
//

#import "MyUpyunFile.h"
#import "FCRequest.h"

@implementation MyUpyunFile

+ (instancetype)fileWithImage:(UIImage *)image
{
    if(image == nil)
    {
        return nil;
    }
    
    NSData *data = UIImageJPEGRepresentation(image, 0.9f);
    return [[MyUpyunFile alloc] initWithData:data fileExt:@"jpg"];
}

+ (instancetype)fileWithText:(NSString *)text
{
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    return [[MyUpyunFile alloc] initWithData:data fileExt:@"txt"];
}

- (void)getMetadataWithBlockCount:(NSUInteger)blockCount fileSize:(NSUInteger)fileSize fileHash:(NSString *)fileHash fileExt:(NSString *)fileExt callback:(UpyunMetadataCallback)callback
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"file_blocks"] = @(blockCount);
    parameters[@"file_size"] = @(fileSize);
    parameters[@"file_hash"] = fileHash;
    parameters[@"file_ext"] = fileExt;
    
    FCRequest *request = [FCRequest requestWithURL:@"https://service.fangcha.me/api/upload/upyun_metadata" params:parameters];
    [request syncPost];
    if(request.succ)
    {
        NSDictionary *response = request.response;
        if(response[@"data"])
        {
            NSDictionary *dic = response[@"data"];
            callback(dic[@"remote_url"], dic[@"expiration"], dic[@"policy"], dic[@"signature"], dic[@"upyun_api"]);
        }
    }
    else
    {
        NSLog(@"%@", request.error.localizedDescription);
    }
}

@end
