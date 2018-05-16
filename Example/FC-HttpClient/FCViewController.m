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
#import "MyUpyunFile.h"

@implementation FCViewController

static NSString * const kReuseCell = @"ReuseCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    __weak typeof(self) weakSelf = self;

    NSString *url = @"https://service.fangcha.me/api/test/http/test_post_json";
    NSString *uploadURL = @"https://service.fangcha.me/api/test/http/test_post_files";
    
    self.infos = @[
                   @[
                       @{
                           @"text": @"application/json",
                           @"event": ^{
                               NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss"};
                               FCRequest *request = [FCRequest request];
                               request.requestType = FCRequestTypeJSON;
                               [request post:url params:params success:^(id obj) {
                                   NSLog(@"%@", obj);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       @{
                           @"text": @"application/x-www-form-urlencoded",
                           @"event": ^{
                               NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss"};
                               FCRequest *request = [FCRequest request];
                               request.requestType = FCRequestTypeForm;
                               [request post:url params:params success:^(id obj) {
                                   NSLog(@"%@", obj);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       @{
                           @"text": @"multipart/form-data",
                           @"event": ^{
                               NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss", @"file_a": [@"file_a" dataUsingEncoding:NSUTF8StringEncoding], @"file_b": [@"file_b" dataUsingEncoding:NSUTF8StringEncoding]};
                               FCRequest *request = [FCRequest request];
                               request.requestType = FCRequestTypeForm;
                               [request post:uploadURL params:params success:^(id obj) {
                                   NSLog(@"%@", obj);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       ],
                   @[
                       @{
                           @"text": @"SyncRequest",
                           @"event": ^{
                               dispatch_block_t block = ^
                               {
                                   for(int i = 0; i < 5; ++i)
                                   {
                                       NSLog(@"Start SyncRequest %d", i);
                                       NSDictionary *params = @{@"index": @(i)};
                                       FCRequest *request = [FCRequest request];
                                       request.requestType = FCRequestTypeJSON;
                                       [request syncPost:url params:params];
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
                       ],
                   @[
                       @{
                           @"text": @"Upyun Upload",
                           @"event": ^{
                               MyUpyunFile *file = [MyUpyunFile fileWithText:@"Test"];
                               [file asyncUploadWithSuccess:^(NSString *remoteURL) {
                                   [FCAlertView alertInVC:weakSelf message:remoteURL];
                                   NSLog(@"%@", remoteURL);
                               } failure:^(NSError *error) {
                                   NSLog(@"%@", error.localizedDescription);
                               }];
                           }
                           },
                       ],
                   ];
    
}

@end
