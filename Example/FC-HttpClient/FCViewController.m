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
#import "UIView+FCRequest.h"
#import "AFNetworking.h"
#import "NSLogger.h"
#import "MBProgressHUD.h"

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
                               [request asyncPost:^(id obj) {
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
                               FCRequest *request = [FCRequest requestWithURL:normalURL params:params];
                               request.requestType = FCRequestTypeForm;
                               [request asyncPost:^(id obj) {
                                   NSLog(@"%@", obj);
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
                                   LoggerApp(3, @"progress: %@/%@", @(progress.completedUnitCount), @(progress.totalUnitCount));
                               };
                               [request asyncPost:^(id obj) {
                                   LoggerApp(3, @"%@", obj);
                               } failure:^(NSError *error) {
                                   LoggerError(3, @"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       @{
                           @"text": @"other response code",
                           @"event": ^{
                               NSDictionary *params = @{@"my_num": @(123), @"my_str": @"sss"};
                               FCRequest *request = [FCRequest requestWithURL:codeURL params:params];
                               request.requestType = FCRequestTypeJSON;
                               [request asyncPost:^(id obj) {
                                   NSLog(@"%@", obj);
                               } failure:^(NSError *error) {
                                   NSString *errorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
                                   NSLog(@"Error Body: %@", errorResponse);
                                   NSLog(@"Error localizedDescription: %@", [error localizedDescription]);
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
                       ],
                   @[
                       @{
                           @"text": @"Upyun Upload",
                           @"event": ^{
                               MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                               hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
                               
                               MyUpyunFile *file = [MyUpyunFile fileWithText:[self longText]];
                               file.progressBlock = ^(float progress) {
                                   LoggerApp(3, @"%.2f", progress);
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       hud.progress = progress;
                                       hud.detailsLabel.text = [NSString stringWithFormat:@"%d%%", (int)(progress * 100)];
                                   });
                               };
                               [file asyncUploadWithSuccess:^(NSString *remoteURL) {
                                   hud.detailsLabel.text = @"上传成功";
                                   [hud hideAnimated:YES afterDelay:1.2f];
                                   LoggerApp(3, @"%@", remoteURL);
                               } failure:^(NSError *error) {
                                   [hud hideAnimated:YES];
                                   LoggerError(3, @"Error: %@", error.localizedDescription);
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
                               [weakSelf.view startRequest:request success:^(id obj) {
                                   LoggerApp(3, @"%@", obj);
                               } failure:^(NSError *error) {
                                   LoggerError(3, @"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       @{
                           @"text": @"With Progress",
                           @"event": ^{
                               NSDictionary *params = @{@"file": [[self longText] dataUsingEncoding:NSUTF8StringEncoding]};
                               FCRequest *request = [FCRequest requestWithURL:uploadURL params:params];
                               request.requestType = FCRequestTypeForm;
                               [weakSelf.view startRequest:request success:^(id obj) {
                                   LoggerApp(3, @"%@", obj);
                               } failure:^(NSError *error) {
                                   LoggerError(3, @"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       ],
                   ];
    
}

- (NSString *)longText
{
    NSMutableString *str = [[NSMutableString alloc] initWithString:@"ABCDEFG"];
    for(int i = 0; i < 20; ++i)
    {
        [str appendString:str];
    }
    
    return str;
}

@end
