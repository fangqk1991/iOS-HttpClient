//
//  UpyunChunk.m
//  Pods
//
//  Created by fang on 2018/5/15.
//

#import "UpyunChunk.h"
#import <CommonCrypto/CommonDigest.h>

@interface UpyunChunk()

@property (nonatomic, strong, readwrite) NSArray *statusList;
@property (nonatomic, copy, readwrite) NSString *saveToken;
@property (nonatomic, copy, readwrite) NSString *tokenSecret;

@end

@implementation UpyunChunk

static NSString * const kStatusList = @"status";
static NSString * const kSaveToken = @"save_token";
static NSString * const kTokenSecret = @"token_secret";

+ (instancetype)feedWithDic:(NSDictionary *)dic
{
    BOOL isValid = [[self class] checkValidDic:dic];
    if(!isValid)
    {
        return nil;
    }
    
    UpyunChunk *obj = [[UpyunChunk alloc] init];
    obj.statusList = dic[kStatusList];
    obj.saveToken = dic[kSaveToken];
    obj.tokenSecret = dic[kTokenSecret];
    
    return obj;
}

- (NSArray *)todoBlockIndices
{
    NSMutableArray *indices = [NSMutableArray array];
    for (int i = 0; i < _statusList.count; i++)
    {
        if (![_statusList[i] boolValue])
        {
            [indices addObject:@(i)];
        }
    }
    
    return indices;
}

+ (NSString *)createPolicyWithParams:(NSDictionary *)params
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+ (NSString *)createSignatureWithToken:(NSString *)token params:(NSDictionary *)params
{
    NSString *signature = @"";
    NSArray *keys = [params allKeys];
    keys = [keys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString * key in keys) {
        NSString * value = params[key];
        signature = [NSString stringWithFormat:@"%@%@%@", signature, key, value];
    }
    signature = [signature stringByAppendingString:token];
    return [self md5:signature];
}

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

#pragma mark - check valid

+ (BOOL)checkValidDic:(NSDictionary *)dic
{
    if(dic == nil || ![dic isKindOfClass:[NSDictionary class]])
    {
        return NO;
    }
    
    if(![dic[kStatusList] isKindOfClass:[NSArray class]])
    {
        NSLog(@"status list error");
        return NO;
    }
    
    if(![dic[kSaveToken] isKindOfClass:[NSString class]])
    {
        NSLog(@"save token error");
        return NO;
    }
    
    if(![dic[kTokenSecret] isKindOfClass:[NSString class]])
    {
        NSLog(@"token secret error");
        return NO;
    }
    return YES;
}

- (BOOL)isValid
{
    if(_statusList == nil
       || _saveToken == nil
       || _tokenSecret == nil)
    {
        return NO;
    }
    
    return YES;
}


@end
