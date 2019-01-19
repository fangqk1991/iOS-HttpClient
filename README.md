# 简介
这是一个基于 [AFNetworking](https://github.com/AFNetworking/AFNetworking) 进行封装的网络请求框架，支持异步、同步请求。

<!--
[![CI Status](https://img.shields.io/travis/fangqk1991/FC-HttpClient.svg?style=flat)](https://travis-ci.org/fangqk1991/FC-HttpClient)
[![Version](https://img.shields.io/cocoapods/v/FC-HttpClient.svg?style=flat)](https://cocoapods.org/pods/FC-HttpClient)
[![License](https://img.shields.io/cocoapods/l/FC-HttpClient.svg?style=flat)](https://cocoapods.org/pods/FC-HttpClient)
[![Platform](https://img.shields.io/cocoapods/p/FC-HttpClient.svg?style=flat)](https://cocoapods.org/pods/FC-HttpClient)
-->

## 依赖
* iOS 8+
* [AFNetworking 3](https://github.com/AFNetworking/AFNetworking)
* [MBProgressHUD 1.1 [可选]](https://github.com/jdg/MBProgressHUD)

## 安装
FC-HttpClient 使用 [CocoaPods](https://cocoapods.org) 进行安装.

编辑 `podfile`

```ruby
target 'MyApp' do
	...
	
    pod 'FC-HttpClient', :git => 'https://github.com/fangqk1991/iOS-HttpClient.git', :tag => '0.3.0'
    
    # Use ProgressHUD
    # pod 'FC-HttpClient/ProgressHUD', :git => 'https://github.com/fangqk1991/iOS-HttpClient.git', :tag => '0.3.0'
end
```

运行

```
pod install
```

## 使用
```
#import "FCRequest.h"
```

* `FCRequest` 请求与响应的内容格式默认均采用 `application/json` 格式，内容格式可通过 `requestType` 和 `responseType` 进行设定。
* 缓存策略可通过 `cachePolicy` 进行设定，默认设定为 `NSURLRequestUseProtocolCachePolicy`

### POST

```
// POST application/json
NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss"};
FCRequest *request = [FCRequest requestWithURL:URL params:params];
request.requestType = FCRequestTypeJSON;
[request asyncPost:^(NSDictionary *data) {
   NSLog(@"%@", data);
} failure:^(NSError *error) {
   NSLog(@"Error: %@", error.localizedDescription);
}];
```

```
// POST application/x-www-form-urlencoded
NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss"};
FCRequest *request = [FCRequest requestWithURL:URL params:params];
request.requestType = FCRequestTypeForm;
[request asyncPost:^(NSDictionary *data) {
   NSLog(@"%@", data);
} failure:^(NSError *error) {
   NSLog(@"Error: %@", error.localizedDescription);
}];
```

```
// POST multipart/form-data
NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss", @"file_a": [@"file_a" dataUsingEncoding:NSUTF8StringEncoding]};
FCRequest *request = [FCRequest requestWithURL:UPLOAD_URL params:params];
request.requestType = FCRequestTypeForm;
request.progressBlock = ^(NSProgress *progress) {
   NSLog(@"progress: %@/%@", @(progress.completedUnitCount), @(progress.totalUnitCount));
};
[request asyncPost:^(NSDictionary *data) {
   NSLog(@"%@", data);
} failure:^(NSError *error) {
   NSLog(@"Error: %@", error.localizedDescription);
}];
```

### Error

```
// other response code
FCRequest *request = [FCRequest requestWithURL:URL params:@{}];
[request asyncPost:^(NSDictionary *data) {
   NSLog(@"%@", data);
} failure:^(NSError *error) {
   NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
   NSLog(@"Error Body: %@", errorResponse);
   NSLog(@"Error localizedDescription: %@", [error localizedDescription]);
}];
```

### SyncRequest
请勿在主线程中执行同步请求

```
// SyncRequest
dispatch_block_t block = ^
{
   for(int i = 0; i < 5; ++i)
   {
       NSLog(@"Start SyncRequest %d", i);
       NSDictionary *params = @{@"index": @(i)};
       FCRequest *request = [FCRequest requestWithURL:URL params:params];
       request.requestType = FCRequestTypeJSON;
       [request syncPost];
       NSLog(@"Response: %@", request.response);
   }
   
   dispatch_block_t block = ^
   {
       [FCAlertView alertInVC:weakSelf message:@"Please see log"];
   };
   
   dispatch_async(dispatch_get_main_queue(), block);
};

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
```

### Get 请求
```
// GetRequest
FCRequest *request = [[FCRequest alloc] initWithURL:SOME_URL];
request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
[request asyncGet:^(NSDictionary *data) {
   NSLog(@"%@", data);
} failure:^(NSError *error) {
   NSLog(@"Error: %@", error.localizedDescription);
}];
```


#### FCTypicalRequest
```
#import "FCTypicalRequest.h"
```

`FCTypicalRequest` 在 `FCRequest` 的基础上，将 Response 锁定为 JSON 格式

正确返回时，一定包含 `data` 字段，其值可以是任意合法类型。

```
{
	"data": "字符串|数字|字典|数组|空值"
}
```

错误信息返回时，一定包含 `error` 字段，`error` 中包含 `code` 和 `msg`；一定不含 `data` 字段，其格式为

```
{
	"error": {
		"code": -1,
		"msg": "some error message"
	}
}
```

这样，返回正确的情况下，回调将收到 `data` 字段下的内容；通常，这是业务真正想要的数据

```
// FCTypicalRequest
NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss"};
FCTypicalRequest *request = [FCTypicalRequest requestWithURL:URL params:params];
[request asyncPost:^(NSDictionary *data) {
   NSLog(@"%@", data);
} failure:^(NSError *error) {
   NSLog(@"Error: %@", error.localizedDescription);
}];
```

### ProgressHUD
```
#import "UIView+FCRequest.h"
```

```
// With Loading
FCRequest *request = [FCRequest requestWithURL:delayURL params:@{}];
request.requestType = FCRequestTypeForm;
[self.view startRequest:request success:^(NSDictionary *data) {
   NSLog(@"%@", data);
} failure:^(NSError *error) {
   NSLog(@"Error: %@", error.localizedDescription);
}];
```

```
// With Progress
NSDictionary *params = @{@"file": [[self longText] dataUsingEncoding:NSUTF8StringEncoding]};
FCRequest *request = [FCRequest requestWithURL:uploadURL params:params];
request.requestType = FCRequestTypeForm;
[weakSelf.view startRequest:request success:^(NSDictionary *data) {
   NSLog(@"%@", data);
} failure:^(NSError *error) {
   NSLog(@"Error: %@", error.localizedDescription);
}];
```

## Author

fangqk1991, me@fangqk.com

## License

FC-HttpClient is available under the MIT license. See the LICENSE file for more info.
