
#import <Cocoa/Cocoa.h>

@interface SXBaseModel : NSObject

/// [[self alloc] init];
+(instancetype)new;
/**
 获取模型
 @param json `NSDictionary`或 JSON字符串 或 `NSData`.
 @return 模型
 */
+ (instancetype)objWithJSON:(id)json;
/// 字典数组转模型数组
+ (NSMutableArray *)objsFromDicts:(NSArray<NSDictionary*>*)dicts;


/// 字典或者数组
@property(nonatomic, readonly) id dict;
/// JSON字符串
@property(nonatomic, copy,readonly) NSString *JSONString;
@end
