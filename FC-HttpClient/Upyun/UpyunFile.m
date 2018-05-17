//
//  UpyunFile.m
//  AFNetworking
//
//  Created by fang on 2018/5/15.
//

#import "UpyunFile.h"
#import <CommonCrypto/CommonDigest.h>
#import "UpyunChunk.h"
#import "FCRequest.h"

@interface UpyunFile()

@property (nonatomic, readwrite, copy) NSString *fileExt;

@property (nonatomic, strong) NSData *data;
@property (nonatomic, readwrite) NSUInteger blockSize;

@property (nonatomic, readwrite, copy) NSString *remoteURL;
@property (nonatomic, readwrite, copy) NSString *expiration;
@property (nonatomic, readwrite, copy) NSString *policy;
@property (nonatomic, readwrite, copy) NSString *signature;
@property (nonatomic, readwrite, copy) NSString *upyunAPI;

@end

@implementation UpyunFile

- (NSString *)md5HashWithData:(NSData *)data
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( data.bytes, (int)data.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (instancetype)initWithData:(NSData *)data fileExt:(NSString *)fileExt
{
    self = [self init];
    if(self)
    {
        _blockSize = 1024 * 1024;
        _data = data;
        self.fileExt = fileExt;
    }
    return self;
}

- (NSUInteger)fileSize
{
    return [_data length];
}

- (BOOL)syncUpload
{
    NSString *fileHash = [self md5HashWithData:_data];
    NSUInteger fileSize = [self fileSize];
    NSUInteger blockCount = ceil(fileSize * 1.0 / _blockSize);
    
    [self getMetadataWithBlockCount:blockCount fileSize:fileSize fileHash:fileHash fileExt:_fileExt callback:^(NSString *remoteURL, NSString *expiration, NSString *policy, NSString *signature, NSString *upyunAPI) {
        self.remoteURL = remoteURL;
        self.expiration = expiration;
        self.policy = policy;
        self.signature = signature;
        self.upyunAPI = upyunAPI;
    }];
    
    if(_remoteURL == nil
       || _expiration == nil
       || _policy == nil
       || _signature == nil
       || _upyunAPI == nil)
    {
        return NO;
    }
    
    return [self uploadToUpyun];
}

- (void)asyncUploadWithSuccess:(void(^)(NSString *))successBlock failure:(void(^)(NSError *))failureBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BOOL succ = [self syncUpload];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(succ)
            {
                if(successBlock != nil)
                {
                    successBlock([self remoteURL]);
                }
            }
            else
            {
                if(failureBlock != nil)
                {
                    NSError *error = [NSError errorWithDomain:@"Async.Upload" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"上传失败"}];
                    failureBlock(error);
                }
            }
        });
    });
}

- (void)getMetadataWithBlockCount:(NSUInteger)blockCount fileSize:(NSUInteger)fileSize fileHash:(NSString *)fileHash fileExt:(NSString *)fileExt callback:(UpyunMetadataCallback)callback
{
    [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (BOOL)uploadToUpyun
{
    // Init upload
    UpyunChunk *currentItem = nil;
    {
        FCRequest *request = [FCRequest requestWithURL:_upyunAPI params:@{@"policy": _policy, @"signature": _signature}];
        request.requestType = FCRequestTypeForm;
        request.responseType = FCRequestTypeJSON;
        [request syncPost];
        if(!request.succ)
        {
            return NO;
        }
        currentItem = [UpyunChunk feedWithDic:request.response];
    }
    
    NSUInteger fileSize = [self fileSize];
    
    // Upload blocks
    while(currentItem != nil)
    {
        NSArray *todoBlockIndices = [currentItem todoBlockIndices];
        
        if(todoBlockIndices.count == 0)
        {
            break;
        }
        
        int curIndex = [todoBlockIndices[0] intValue];
        NSUInteger start = curIndex * self.blockSize;
        NSUInteger end = start + self.blockSize;
        end = (end > fileSize ? fileSize : end);
        
        NSData *packet = [_data subdataWithRange:NSMakeRange(start, end - start)];
        
        NSDictionary *policyParameters = @{@"save_token": currentItem.saveToken,
                                           @"expiration": _expiration,
                                           @"block_index": @(curIndex),
                                           @"block_hash": [self md5HashWithData:packet]};
        NSString *policy = [UpyunChunk createPolicyWithParams:policyParameters];
        NSString *signature = [UpyunChunk createSignatureWithToken:currentItem.tokenSecret params:policyParameters];
        
        FCRequest *request = [FCRequest requestWithURL:_upyunAPI params:@{@"policy": policy, @"signature": signature, @"file": packet}];
        request.requestType = FCRequestTypeForm;
        request.responseType = FCRequestTypeJSON;
        [request syncPost];
        if(!request.succ)
        {
            return NO;
        }
        currentItem = [UpyunChunk feedWithDic:request.response];
    }
    
    // Upload submit
    if(currentItem != nil)
    {
        NSDictionary *policyParameters = @{@"save_token": currentItem.saveToken,
                                           @"expiration": _expiration};
        NSString *policy = [UpyunChunk createPolicyWithParams:policyParameters];
        NSString *signature = [UpyunChunk createSignatureWithToken:currentItem.tokenSecret params:policyParameters];
        
        FCRequest *request = [FCRequest requestWithURL:_upyunAPI params:@{@"policy": policy, @"signature": signature}];
        request.requestType = FCRequestTypeForm;
        request.responseType = FCRequestTypeJSON;
        [request syncPost];
        if(request.succ)
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)description
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"remoteURL"] = _remoteURL;
    dic[@"expiration"] = _expiration;
    dic[@"policy"] = _policy;
    dic[@"signature"] = _signature;
    return [NSString stringWithFormat:@"<%@: %p>\n %@", NSStringFromClass([self class]), self, dic];
}

@end
