//
//  Father.m
//  Demo_Runtime
//
//  Created by gshopper on 2021/12/23.
//

#import "Father.h"

@implementation Father

- (void)eat {
    NSLog(@"self: %@", self);
    NSLog(@"func: %s", __func__);
}

@end
