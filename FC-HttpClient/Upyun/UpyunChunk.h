//
//  UpyunChunk.h
//  Pods
//
//  Created by fang on 2018/5/15.
//

#import <Foundation/Foundation.h>

@interface UpyunChunk : NSObject

@property (nonatomic, strong, readonly) NSArray *statusList;
@property (nonatomic, copy, readonly) NSString *saveToken;
@property (nonatomic, copy, readonly) NSString *tokenSecret;

+ (instancetype)feedWithDic:(NSDictionary *)dic;

- (int)getTodoIndex;
+ (NSString *)createPolicyWithParams:(NSDictionary *)params;
+ (NSString *)createSignatureWithToken:(NSString *)token params:(NSDictionary *)params;

@end
