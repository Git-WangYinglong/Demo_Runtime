//
//  Son+Category.m
//  Demo_Runtime
//
//  Created by gshopper on 2021/12/23.
//

#import "Son+Category.h"

#import <objc/runtime.h>

@implementation Son (Category)

+ (void)load {
    Method method1 = class_getInstanceMethod(self, @selector(eat));
    Method method2 = class_getInstanceMethod(self, @selector(anotherEat));
    //只能在 SEL 没有 IMP 指向时才可以添加成功
    BOOL isAddMethod = class_addMethod(self, @selector(eat), method_getImplementation(method2), method_getTypeEncoding(method2));
    if (isAddMethod) {
        //替换某个类的方法的实现，不管 SEL 有没有 IMP 实现，都可以添加成功
        //替换父类的方法时，只有在子类里面调用才有效，实际上是在子类里面重写了父类的方法
        class_replaceMethod(self, @selector(anotherEat), method_getImplementation(method1), method_getTypeEncoding(method1));
    } else {
        //交换方法的实现，当获取的方法来自于父类时，也会照成父类调用时被触发
        //由于方法的实现来自于父类，所以实际是交换的父类的方法的实现
        method_exchangeImplementations(method1, method2);
    }
}

- (void)anotherEat {
    [self anotherEat];
    NSLog(@"self: %@", self);
    NSLog(@"func: %s", __func__);
}

@end
