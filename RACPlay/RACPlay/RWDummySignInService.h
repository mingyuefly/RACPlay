//
//  RWDummySignInService.h
//  RACPlay
//
//  Created by Gguomingyue on 2019/12/26.
//  Copyright © 2019 Gmingyue. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^RWSignInResponse)(BOOL);

@interface RWDummySignInService : NSObject

- (void)signInWithUsername:(NSString *)username
                  password:(NSString *)password
                  complete:(RWSignInResponse)completeBlock;

@end

NS_ASSUME_NONNULL_END
