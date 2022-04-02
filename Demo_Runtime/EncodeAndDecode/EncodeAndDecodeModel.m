//
//  EncodeAndDecodeModel.m
//  Demo_Runtime
//
//  Created by gshopper on 2021/12/23.
//

#import "EncodeAndDecodeModel.h"

#import <objc/runtime.h>

@implementation EncodeAndDecodeModel

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    unsigned int varCount;
    Ivar *varList = class_copyIvarList([self class], &varCount);
    for (int i = 0; i < varCount; i++) {
        const char *ivarName = ivar_getName(varList[i]);
        NSString *key = [NSString stringWithUTF8String:ivarName];
        id value = [self valueForKey:key];
        [coder encodeObject:value forKey:key];
    }
    free(varList);
    /*
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        const char *propertyName = property_getName(properties[i]);
        NSString *key = [NSString stringWithUTF8String:propertyName];
        id value = [self valueForKey:key];
        [coder encodeObject:value forKey:key];
    }
    free(properties);
     */
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        unsigned int varCount;
        Ivar *varList = class_copyIvarList([self class], &varCount);
        for (int i = 0; i < varCount; i++) {
            const char *ivarName = ivar_getName(varList[i]);
            NSString *key = [NSString stringWithUTF8String:ivarName];
            id value = [coder decodeObjectOfClass:[self class] forKey:key];
            [self setValue:value forKey:key];
        }
        free(varList);
        /*
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i++) {
            const char *propertyName = property_getName(properties[i]);
            NSString *key = [NSString stringWithUTF8String:propertyName];
            id value = [coder decodeObjectOfClass:[self class] forKey:key];
            [self setValue:value forKey:key];
        }
        free(properties);
         */
    }
    return self;
}

@end
