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
@property (nonatomic, strong) NSString *userAgent;

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

- (void)fc_loadDefaultSettings
{
    _requestType = FCRequestTypeJSON;
    _responseType = FCResponseTypeJSON;
    _userAgent = [NSString stringWithFormat:@"APP-iOS-%.1f", [[UIDevice currentDevice].systemVersion floatValue]];
}

- (void)fc_post:(NSString *)url params:(NSDictionary *)params success:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock
{
    AFHTTPSessionManager *manager = [self sessionManager];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
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

- (void)fc_syncPost:(NSString *)url params:(NSDictionary *)params
{
    if ([NSThread isMainThread]) {
        [NSException raise:NSInternalInconsistencyException format:@"[%@] Can not make a sync request on the main thread.", NSStringFromSelector(_cmd)];
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __weak typeof(self) weakSelf = self;
    
    AFHTTPSessionManager *manager = [self sessionManager];
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        weakSelf.response = responseObject;
        weakSelf.succ = YES;
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        weakSelf.error = error;
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (AFHTTPSessionManager *)sessionManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:_userAgent forHTTPHeaderField:@"User-Agent"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    return manager;
}

@end
