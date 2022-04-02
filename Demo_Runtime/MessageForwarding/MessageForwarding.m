//
//  MessageForwarding.m
//  Demo_Runtime
//
//  Created by gshopper on 2021/12/22.
//

#import "MessageForwarding.h"
#import "MessageForwardingTarget.h"

#import <objc/runtime.h>

@implementation MessageForwarding

//第一步
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    if ([NSStringFromSelector(sel) isEqualToString:@"test1"]) {
        BOOL isSuccess = class_addMethod([self class], sel, class_getMethodImplementation([self class], @selector(test_add)), method_getTypeEncoding(class_getInstanceMethod([self class], @selector(test_add))));
        if (isSuccess) {
            return YES;
        }
    }
    return [super resolveInstanceMethod:sel];
}

//第二步
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([NSStringFromSelector(aSelector) isEqualToString:@"test1"]) {
        return [MessageForwardingTarget new];
    }
    return [super forwardingTargetForSelector:aSelector];
}

//第三步
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    if (!methodSignature) {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return methodSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    MessageForwardingTarget *target = [MessageForwardingTarget new];
    SEL sel = anInvocation.selector;
    if ([target respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:target];
    }
}

//以上三步消息都没响应，则抛出异常
- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"消息无法响应，抛出异常");
    [super doesNotRecognizeSelector:aSelector];
}

- (void)test_add {
    NSLog(@"消息第一步转发成功");
}

@end
