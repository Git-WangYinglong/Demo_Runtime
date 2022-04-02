//
//  ViewController.m
//  Demo_Runtime
//
//  Created by gshopper on 2021/12/21.
//

#import "ViewController.h"

#import "MessageForwarding.h"
#import "Father.h"
#import "Son.h"
#import "DictionaryModel.h"
#import "EncodeAndDecodeModel.h"

#import <objc/runtime.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"沙盒路径: %@", NSHomeDirectory());
    
    [self test_methodSwizzling];
}

- (void)test_runtime {
    //创建类: 成对出现，一个是返回值，一个是元类
    Class Person = objc_allocateClassPair([NSObject class], "Person", 0);
    //添加成员变量
    NSUInteger size;
    NSUInteger alignment;
    NSGetSizeAndAlignment("*", &size, &alignment);
    BOOL isSuccess = class_addIvar(Person, "_name", size, alignment, "*");
    if (isSuccess) {
        NSLog(@"class_addIvar: success");
    } else {
        NSLog(@"class_addIvar: failure");
    }
    //注册类: 创建成功才能注册，否则会报错
    if (NSStringFromClass(Person).length) {
        objc_registerClassPair(Person);
    }
    
    unsigned int varCount;
    //拷贝成员变量列表
    Ivar *varList = class_copyIvarList(Person, &varCount);
    for (int i = 0; i < varCount; i++) {
        NSLog(@"ivar_getName: %s", ivar_getName(varList[i]));
    }
    free(varList);
    
    //创建对象
    id p = class_createInstance(Person, sizeof(id));
    NSLog(@"class_createInstance: %@", p);
    
    id person = [[Person alloc] init];
    //获取成员变量
    Ivar nameIvar = class_getInstanceVariable(Person, "_name");
    //成员变量赋值
    object_setIvar(person, nameIvar, @"张三");
    //成员变量取值
    NSLog(@"object_getIvar: %@", object_getIvar(person, nameIvar));
    
    //添加属性
    objc_property_attribute_t type = {"T", "@\"NSString\""}; //type: 属性的类型，须放在第一位
    objc_property_attribute_t nonatomic = {"N", ""};         //nonatomic
    objc_property_attribute_t copy = {"C", ""};              //copy
    objc_property_attribute_t ivar_name = {"V", "_age"};     //ivar_name: 属性对应的成员变量，须放在最后一位
    objc_property_attribute_t attr[] = {type, nonatomic, copy, ivar_name};
    isSuccess = class_addProperty(Person, "age", attr, 4);   //此时还没有 setter 和 getter 方法
    if (isSuccess) {
        NSLog(@"class_addProperty: success");
    } else {
        NSLog(@"class_addProperty: failure");
        //替换属性
        class_replaceProperty(Person, "age", attr, 4);
    }
    
    //添加方法
    class_addMethod(Person, @selector(setAge:), class_getMethodImplementation([self class], @selector(setAge_vc:)), "v@:@");
    class_addMethod(Person, @selector(age), class_getMethodImplementation([self class], @selector(age_vc)), "@@:");
    //赋值: 触发 setAge_vc:
    [person setValue:@"18" forKey:@"age"];
    //取值: 触发 age_vc
    NSLog(@"valueForKey: %@", [person valueForKey:@"age"]);
    
    unsigned int propertyCount;
    //拷贝属性列表
    objc_property_t *properties = class_copyPropertyList(Person, &propertyCount);
    for (int i = 0; i < propertyCount; i++) {
        NSLog(@"property_getName: %s", property_getName(properties[i]));
        NSLog(@"property_getAttributes: %s", property_getAttributes(properties[i]));
    }
    free(properties);
    
    unsigned int methodCount;
    //拷贝方法列表
    Method *methodList = class_copyMethodList(Person, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        NSLog(@"method_getName: %s", sel_getName(method_getName(methodList[i])));
        NSLog(@"method_getTypeEncoding: %s", method_getTypeEncoding(methodList[i]));
    }
    free(methodList);
}

- (void)setAge_vc:(NSString *)age {
    objc_setAssociatedObject(self, @selector(age_vc), age, OBJC_ASSOCIATION_COPY);
}

- (id)age_vc {
    return objc_getAssociatedObject(self, @selector(age_vc));
}

- (void)test_methodSwizzling {
    Son *son = [Son alloc];
    [son eat];
    
    Father *father = [Father new];
    [father eat];
}

- (void)test_messageForwarding {
    MessageForwarding *mf = [MessageForwarding new];
    [mf performSelector:@selector(test)];
}

- (void)test_dictionaryModelConversion {
    NSDictionary *dic = @{@"name":@"张三", @"age":@"18"};
    DictionaryModel *model = [[DictionaryModel alloc] initWithDictionary:dic];
    NSLog(@"字典转模型: model.name = %@，model.age = %@", model.name, model.age);
    
    dic = [model modelConversionDictionary];
    NSLog(@"模型转字典: dic = %@", dic);
}

- (void)test_encodeAndDecode {
    EncodeAndDecodeModel *model = [EncodeAndDecodeModel new];
    model.name = @"张三";
    model.age = @"18";
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"archive.plist"];
    if (@available(iOS 11.0, *)) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model requiringSecureCoding:YES error:nil];
        [data writeToFile:filePath atomically:YES];
        
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        if (fileData) {
            EncodeAndDecodeModel *model = [NSKeyedUnarchiver unarchivedObjectOfClass:[EncodeAndDecodeModel class] fromData:fileData error:nil];
            NSLog(@"自动解档: model.name = %@，model.age = %@", model.name, model.age);
        }
    } else {
        [NSKeyedArchiver archiveRootObject:model toFile:filePath];
        EncodeAndDecodeModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        NSLog(@"自动解档: model.name = %@，model.age = %@", model.name, model.age);
    }
}

@end
