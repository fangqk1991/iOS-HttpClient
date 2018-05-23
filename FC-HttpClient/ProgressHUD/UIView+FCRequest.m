//
//  UIView+FCRequest.m
//  Pods
//
//  Created by fang on 2018/5/17.
//

#import "UIView+FCRequest.h"
#import "FCRequest.h"
#import "MBProgressHUD.h"

@implementation UIView(FCRequest)

- (void)startRequest:(FCRequest *)request success:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    request.progressBlock = ^(NSProgress *progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.detailsLabel.text = [NSString stringWithFormat:@"%d%%", (int)(1.0 * progress.completedUnitCount / progress.totalUnitCount * 100)];
        });
    };
    
    [request asyncPost:^(id obj) {
        [hud hideAnimated:YES];
        
        if(successBlock)
        {
            successBlock(obj);
        }
    } failure:^(NSError *error) {
        [hud hideAnimated:YES];
        
        if(failureBlock)
        {
            failureBlock(error);
        }
    }];
}

@end
