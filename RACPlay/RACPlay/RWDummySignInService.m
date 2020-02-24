//
//  RWDummySignInService.m
//  RACPlay
//
//  Created by Gguomingyue on 2019/12/26.
//  Copyright © 2019 Gmingyue. All rights reserved.
//

#import "RWDummySignInService.h"
#import <UIKit/UIKit.h>

@implementation RWDummySignInService

- (void)signInWithUsername:(NSString *)username
                  password:(NSString *)password
                  complete:(RWSignInResponse)completeBlock
{
    UIActivityIndicatorView *actityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    actityView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    actityView.center = [[[UIApplication sharedApplication] keyWindow] center];
    [[[UIApplication sharedApplication] keyWindow] addSubview:actityView];
    [actityView startAnimating];
    double delayInSeconds = 5.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [actityView stopAnimating];
        BOOL success = [username isEqualToString:@"user"] && [password isEqualToString:@"password"];
        completeBlock(success);
    });
}

@end
