//
//  FCRequest.m
//  AFNetworking
//
//  Created by fang on 2018/5/15.
//

#import "FCRequest.h"
#import "AFNetworking.h"

@interface FCRequest()

@property (nonatomic, readwrite) NSString *url;
@property (nonatomic, readwrite) NSDictionary *params;

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

- (instancetype)initWithURL:(NSString *)url
{
    return [self initWithURL:url params:nil];
}

- (instancetype)initWithURL:(NSString *)url params:(NSDictionary *)params
{
    self = [self init];
    
    if(self)
    {
        self.url = url;
        self.params = params;
        
        if(self.params == nil)
        {
            self.params = @{};
        }
    }
    
    return self;
}

+ (instancetype)requestWithURL:(NSString *)url params:(NSDictionary *)params
{
    return [[[self class] alloc] initWithURL:url params:params];
}

- (void)fc_loadDefaultSettings
{
    _cachePolicy = NSURLRequestUseProtocolCachePolicy;
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

- (void)asyncPost:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [self fc_requestSerialize];
    manager.requestSerializer.cachePolicy = _cachePolicy;
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
        } progress:_progressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)syncPost
{
    if ([NSThread isMainThread]) {
        [NSException raise:NSInternalInconsistencyException format:@"[%@] Can not make a sync request on the main thread.", NSStringFromSelector(_cmd)];
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __weak typeof(self) weakSelf = self;
    
    [self asyncPost:^(id responseObject) {
        weakSelf.response = responseObject;
        weakSelf.succ = YES;
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSError *error) {
        weakSelf.error = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)asyncGet:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [self fc_requestSerialize];
    manager.requestSerializer.cachePolicy = _cachePolicy;
    manager.responseSerializer = [self fc_responseSerialize];
    
    [manager GET:_url parameters:_params progress:_progressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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

- (void)syncGet
{
    if ([NSThread isMainThread]) {
        [NSException raise:NSInternalInconsistencyException format:@"[%@] Can not make a sync request on the main thread.", NSStringFromSelector(_cmd)];
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __weak typeof(self) weakSelf = self;
    
    [self asyncGet:^(id responseObject) {
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
