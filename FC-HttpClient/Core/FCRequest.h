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
    FCRequestTypeFormData = 1001,
    FCRequestTypeJSON = 2000,
};

typedef NS_ENUM(NSInteger, FCResponseType)
{
    FCResponseTypeText = 0,
    FCResponseTypeJSON = 2000,
};

typedef void (^FCSuccBlock)(id obj);
typedef void (^FCFailBlock)(NSError *error);

@interface FCRequest : NSObject

@property (nonatomic, readwrite) FCRequestType requestType;
@property (nonatomic, readwrite) FCResponseType responseType;

@property (nonatomic, readonly) BOOL succ;
@property (nonatomic, strong, readonly) id response;
@property (nonatomic, strong, readonly) NSError *error;

+ (instancetype)request;

- (void)post:(NSString *)url params:(NSDictionary *)params success:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock;
- (void)syncPost:(NSString *)url params:(NSDictionary *)params;

@end