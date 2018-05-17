//
//  FCRequest.m
//  AFNetworking
//
//  Created by fang on 2018/5/15.
//

#import "FCRequest.h"
#import "AFNetworking.h"

@interface FCRequest()

@property (nonatomic, readwrite) BOOL succ;
@property (nonatomic, strong, readwrite) id response;
@property (nonatomic, strong, readwrite) NSError *error;

@end

@implementation FCRequest

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        [self fc_loadDefaultSettings];
    }
    return self;
}

+ (instancetype)request
{
    return [[[self class] alloc] init];
}

+ (instancetype)requestWithURL:(NSString *)url params:(NSDictionary *)params
{
    FCRequest *request = [self request];
    request.url = url;
    request.params = params;
    return request;
}

- (void)fc_loadDefaultSettings
{
    _requestType = FCRequestTypeJSON;
    _responseType = FCResponseTypeJSON;
    _userAgent = [NSString stringWithFormat:@"APP-iOS-%.1f", [[UIDevice currentDevice].systemVersion floatValue]];
}

- (AFHTTPRequestSerializer *)fc_requestSerialize
{
    AFHTTPRequestSerializer *serialize = (_requestType == FCRequestTypeJSON) ? [AFJSONRequestSerializer serializer] : [AFHTTPRequestSerializer serializer];
    [serialize setValue:_userAgent forHTTPHeaderField:@"User-Agent"];
    return serialize;
}

- (AFHTTPResponseSerializer *)fc_responseSerialize
{
    AFHTTPResponseSerializer *serialize = (_responseType == FCResponseTypeJSON) ? [AFJSONResponseSerializer serializer] : [AFHTTPResponseSerializer serializer];
    [serialize setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil]];
    return serialize;
}

- (void)post:(NSString *)url params:(NSDictionary *)params success:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock
{
    self.url = url;
    self.params = params;
    
    [self asyncPost:successBlock failure:failureBlock];
}
- (void)asyncPost:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [self fc_requestSerialize];
    manager.responseSerializer = [self fc_responseSerialize];
    
    NSDictionary *params = _params;
    NSMutableDictionary *normalParams = [NSMutableDictionary dictionary];
    NSMutableDictionary *dataParams = [NSMutableDictionary dictionary];
    
    for (NSString *key in [params allKeys])
    {
        if([params[key] isKindOfClass:[NSData class]])
        {
            dataParams[key] = params[key];
        }
        else
        {
            normalParams[key] = params[key];
        }
    }
    
    if(dataParams.count > 0)
    {
        [manager POST:_url parameters:normalParams constructingBodyWithBlock:^(id<AFMultipartFormData> _Nonnull formData) {
            for (NSString *key in [dataParams allKeys])
            {
                [formData appendPartWithFileData:dataParams[key] name:key fileName:[NSString stringWithFormat:@"%@.xxx", key] mimeType:@"application/octet-stream"];
            }
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if(successBlock != nil)
            {
                successBlock(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(failureBlock != nil)
            {
                failureBlock(error);
            }
        }];
    }
    else
    {
        [manager POST:_url parameters:normalParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
            if(successBlock != nil)
            {
                successBlock(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(failureBlock != nil)
            {
                failureBlock(error);
            }
        }];
    }
}

- (void)syncPost:(NSString *)url params:(NSDictionary *)params
{
    self.url = url;
    self.params = params;
    [self syncPost];
}

- (void)syncPost
{
    if ([NSThread isMainThread]) {
        [NSException raise:NSInternalInconsistencyException format:@"[%@] Can not make a sync request on the main thread.", NSStringFromSelector(_cmd)];
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __weak typeof(self) weakSelf = self;
    
    [self post:_url params:_params success:^(id responseObject) {
        weakSelf.response = responseObject;
        weakSelf.succ = YES;
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSError *error) {
        weakSelf.error = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end
