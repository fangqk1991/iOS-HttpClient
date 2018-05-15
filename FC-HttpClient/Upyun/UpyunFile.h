//
//  UpyunFile.h
//  AFNetworking
//
//  Created by fang on 2018/5/15.
//

#import <Foundation/Foundation.h>

typedef void (^UpyunMetadataCallback)(NSString *remotePath, NSString *expiration, NSString *policy, NSString *signature, NSString *upyunAPI);

@interface UpyunFile : NSObject

@property (nonatomic, readonly, copy) NSString *remotePath;

- (instancetype)initWithData:(NSData *)data fileExt:(NSString *)fileExt;

- (NSUInteger)fileSize;

- (BOOL)syncUpload;
- (void)asyncUploadWithSuccess:(void(^)(NSString *))successBlock failure:(void(^)(NSError *))failureBlock;

@end
