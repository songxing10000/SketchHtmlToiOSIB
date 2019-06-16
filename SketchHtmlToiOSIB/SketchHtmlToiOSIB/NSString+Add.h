//
//  NSString+Add.h
//  SketchHtmlToiOSIB
//
//  Created by mac on 2019/6/16.
//  Copyright © 2019 dfpo. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Add)
/// 解析 JSON 字符串后的 字典
@property(nonatomic, strong, readonly) NSDictionary *dict;
@property(nonatomic, strong, class) NSString *randomid;
@end

NS_ASSUME_NONNULL_END
