//
//  FCViewController.m
//  FC-HttpClient
//
//  Created by fangqk1991 on 05/14/2018.
//  Copyright (c) 2018 fangqk1991. All rights reserved.
//

#import "FCViewController.h"
#import "FCRequest.h"
#import "FCAlertView.h"
#import "UIView+FCRequest.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "FCTypicalRequest.h"

@implementation FCViewController

static NSString * const kReuseCell = @"ReuseCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    __weak typeof(self) weakSelf = self;
    
    NSString *normalURL = @"https://service.fangcha.me/api/test/http/test_post_json";
    NSString *uploadURL = @"https://service.fangcha.me/api/test/http/test_post_files";
    NSString *delayURL = @"https://service.fangcha.me/api/test/http/test_delay";
    NSString *codeURL = @"https://service.fangcha.me/api/test/http/test_code";
    
    self.infos = @[
                   @[
                       @{
                           @"text": @"application/json",
                           @"event": ^{
                               NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss"};
                               FCRequest *request = [FCRequest requestWithURL:normalURL params:params];
                               request.requestType = FCRequestTypeJSON;
                               [request asyncPost:^(NSDictionary *data) {
                                   NSLog(@"%@", data);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       @{
                           @"text": @"application/x-www-form-urlencoded",
                           @"event": ^{
                               NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss"};
                               FCRequest *request = [FCRequest requestWithURL:normalURL params:params];
                               request.requestType = FCRequestTypeForm;
                               [request asyncPost:^(NSDictionary *data) {
                                   NSLog(@"%@", data);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       @{
                           @"text": @"multipart/form-data",
                           @"event": ^{
                               NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss", @"file_a": [@"file_a" dataUsingEncoding:NSUTF8StringEncoding]};
                               FCRequest *request = [FCRequest requestWithURL:uploadURL params:params];
                               request.requestType = FCRequestTypeForm;
                               request.progressBlock = ^(NSProgress *progress) {
                                   NSLog(@"progress: %@/%@", @(progress.completedUnitCount), @(progress.totalUnitCount));
                               };
                               [request asyncPost:^(NSDictionary *data) {
                                   NSLog(@"%@", data);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       @{
                           @"text": @"other response code",
                           @"event": ^{
                               FCRequest *request = [FCRequest requestWithURL:codeURL params:@{}];
                               [request asyncPost:^(NSDictionary *data) {
                                   NSLog(@"%@", data);
                               } failure:^(NSError *error) {
                                   NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                   NSLog(@"Error Body: %@", errorResponse);
                                   NSLog(@"Error localizedDescription: %@", [error localizedDescription]);
                               }];
                           }
                           },
                       @{
                           @"text": @"SyncRequest",
                           @"event": ^{
                               dispatch_block_t block = ^
                               {
                                   for(int i = 0; i < 5; ++i)
                                   {
                                       NSLog(@"Start SyncRequest %d", i);
                                       NSDictionary *params = @{@"index": @(i)};
                                       FCRequest *request = [FCRequest requestWithURL:normalURL params:params];
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
                           }
                           },
                       @{
                           @"text": @"FCTypicalRequest",
                           @"event": ^{
                               NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss"};
                               FCTypicalRequest *request = [FCTypicalRequest requestWithURL:normalURL params:params];
                               [request asyncPost:^(NSDictionary *data) {
                                   NSLog(@"%@", data);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       @{
                           @"text": @"GetRequest",
                           @"event": ^{
                               FCRequest *request = [[FCRequest alloc] initWithURL:@"https://cdn.fangcha.me/static/files/demo.json"];
                               request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
                               [request asyncGet:^(NSDictionary *data) {
                                   NSLog(@"%@", data);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       ],
                   @[
                       @{
                           @"text": @"With Loading",
                           @"event": ^{
                               FCRequest *request = [FCRequest requestWithURL:delayURL params:@{}];
                               request.requestType = FCRequestTypeForm;
                               [weakSelf.view startRequest:request success:^(NSDictionary *data) {
                                   NSLog(@"%@", data);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       @{
                           @"text": @"With Progress",
                           @"event": ^{
                               NSDictionary *params = @{@"file": [[self longText] dataUsingEncoding:NSUTF8StringEncoding]};
                               FCRequest *request = [FCRequest requestWithURL:uploadURL params:params];
                               request.requestType = FCRequestTypeForm;
                               [weakSelf.view startRequest:request success:^(NSDictionary *data) {
                                   NSLog(@"%@", data);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       ],
                   ];
    
}

- (NSString *)longText
{
    NSMutableString *str = [[NSMutableString alloc] initWithString:@"ABC"];
    for(int i = 0; i < 20; ++i)
    {
        [str appendString:str];
    }
    
    return str;
}

@end
