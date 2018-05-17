//
//  UIView+FCRequest.h
//  Pods
//
//  Created by fang on 2018/5/17.
//

#import <UIKit/UIKit.h>
#import "FCRequest.h"

@interface UIView(FCRequest)

- (void)startRequest:(FCRequest *)request success:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock;

@end
