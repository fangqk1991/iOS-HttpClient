//
//  MyUpyunFile.h
//  FC-HttpClient_Example
//
//  Created by fang on 2018/5/15.
//  Copyright © 2018 fangqk1991. All rights reserved.
//

#import "UpyunFile.h"

@interface MyUpyunFile : UpyunFile

+ (instancetype)fileWithImage:(UIImage *)image;
+ (instancetype)fileWithText:(NSString *)text;

@end
