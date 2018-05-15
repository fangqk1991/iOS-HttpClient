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

@implementation FCViewController

static NSString * const kReuseCell = @"ReuseCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    __weak __typeof(self)weakSelf = self;
    
    self.infos = @[
                   @[
                       @{
                           @"text": @"post json",
                           @"event": ^{
                               FCRequest *request = [FCRequest request];
                               [request post:@"https://service.fangcha.me/api/test/http/test_post_json" params:nil success:^(id obj) {
                                   NSLog(@"%@", obj);
                               } failure:^(NSError *error) {
                                   NSLog(@"Error: %@", error.localizedDescription);
                               }];
                           }
                           },
                       ],
                   ];
    
}

@end
