//
//  FCTypicalRequest.m
//  Pods
//
//  Created by fang on 2018/5/24.
//

#import "FCTypicalRequest.h"

@implementation FCTypicalRequest

- (void)asyncPost:(FCSuccBlock)successBlock failure:(FCFailBlock)failureBlock
{
    self.responseType = FCResponseTypeJSON;
    
    [super asyncPost:^(NSDictionary *dic) {
        if(dic[@"data"])
        {
            if(successBlock)
            {
                successBlock(dic[@"data"]);
            }
        }
        else
        {
            if(failureBlock)
            {
                NSError *error = [NSError errorWithDomain:@"me.fangcha.FCTypicalRequest" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"It isn't a typical response!"}];
                
                if([dic[@"error"] isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *errDic = dic[@"error"];
                    if(errDic[@"code"] != nil && errDic[@"msg"] != nil)
                    {
                        error = [NSError errorWithDomain:@"me.fangcha.FCTypicalRequest" code:[errDic[@"code"] intValue] userInfo:@{NSLocalizedDescriptionKey: errDic[@"msg"]}];
                    }
                }
                
                failureBlock(error);
            }
        }
    } failure:failureBlock];
}

@end
