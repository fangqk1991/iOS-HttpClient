//
//  FCRequest.h
//  AFNetworking
//
//  Created by fang on 2018/5/15.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FCRequestType)
{
    FCRequestTypeForm = 1000,
    FCRequestTypeJSON = 2000,
};

typedef NS_ENUM(NSInteger, FCResponseType)
{
    FCResponseTypeText = 1000,
    FCResponseTypeJSON = 2000,
};

typedef void (^FCSuccBlock)(id obj);
typedef void (^FCFailBlock)(NSError *error);
typedef void (^FCProgressBlock)(NSProgress *progress);

@interface FCRequest : NSObject

@property (nonatomic, readwrite) FCRequestType requestType;
@property (nonatomic, readwrite) FCResponseType responseType;

@property (nonatomic, readonly) NSString *url;
@property (nonatomic, readonly) NSDictionary *params;

@property (nonatomic, readonly) BOOL succ;
@property (nonatomic, strong, readonly) id response;
@property (nonatomic, strong, readonly) NSError *error;
@property (nonatomic, strong, readwrite) NSString *userAgent;

@property (nonatomic, copy) FCProgressBlock progressBlock;

- (instancetype)initWithURL:(NSString *)url;
- (instancetype)initWithURL:(NSString *)url params:(NSDictionary *)params;
+ (instancetype)requestWithURL:(NSString *)url params:(NSDictionary *)params;

- (void)asyncPost:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock;
- (void)syncPost;

- (void)asyncGet:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock;
- (void)syncGet;

@end
