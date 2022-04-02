//
//  DictionaryModel.m
//  Demo_Runtime
//
//  Created by gshopper on 2021 /12/23.
//

#import "DictionaryModel.h"

#import <objc/message.h>

@implementation DictionaryModel

//字典转模型
- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        for (NSString *key in dictionary.allKeys) {
            NSString *methodName = [NSString stringWithFormat:@"set%@:", key.capitalizedString];
            SEL sel = NSSelectorFromString(methodName);
            if (sel && [self respondsToSelector:sel]) {
                //调用 objc_msgSend 时需要进行一个类型强转，不然会报错
                ((void (*)(id, SEL, id))objc_msgSend)(self, sel, dictionary[key]);
            }
        }
    }
    return self;
}

//模型转字典
- (NSDictionary *)modelConversionDictionary {
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    if (propertyCount == 0) {
        return nil;
    }
    
    NSMutableDictionary *dicM = @{}.mutableCopy;
    for (int i = 0; i < propertyCount; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *key = [NSString stringWithUTF8String:propertyName];
        SEL sel = NSSelectorFromString(key);
        if (sel && [self respondsToSelector:sel]) {
            id value = ((id (*)(id, SEL))objc_msgSend)(self, sel);
            [dicM setValue:value forKey:key];
        }
    }
    free(properties);
    return dicM.copy;
}

@end
