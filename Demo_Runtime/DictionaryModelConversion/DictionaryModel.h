//
//  DictionaryModel.h
//  Demo_Runtime
//
//  Created by gshopper on 2021/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DictionaryModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *age;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *)modelConversionDictionary;

@end

NS_ASSUME_NONNULL_END
