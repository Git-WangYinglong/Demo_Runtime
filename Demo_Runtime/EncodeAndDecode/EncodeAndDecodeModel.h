//
//  EncodeAndDecodeModel.h
//  Demo_Runtime
//
//  Created by gshopper on 2021/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EncodeAndDecodeModel : NSObject<NSSecureCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *age;

@end

NS_ASSUME_NONNULL_END
