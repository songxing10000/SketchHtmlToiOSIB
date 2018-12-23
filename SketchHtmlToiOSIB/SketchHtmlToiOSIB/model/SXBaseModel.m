
#import "SXBaseModel.h"
#import <YYModel.h>

@implementation SXBaseModel
+(instancetype)new {
    return [[self alloc] init];
}
+ (instancetype)objWithJSON:(id)json {
    __block NSDictionary *temDict = nil;
    if ([json isKindOfClass:[NSDictionary class]] ||
        [json isKindOfClass:[NSString class]] ||
        [json isKindOfClass:[NSData class]]) {
        
        temDict = json;
    } else if ([json isKindOfClass:[NSArray class]]) {
        
        [(NSArray *)json enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[NSDictionary class]]) {
                
                if ([[obj allKeys] count] > [[temDict allKeys] count]) {
                    
                    temDict = obj;
                }
            } else if ([obj isKindOfClass:[NSString class]]) {
                temDict = obj;
                *stop = YES;
            } else if ([obj isKindOfClass:[NSData class]]) {
                temDict = obj;
                *stop = YES;
            }
        }];
    }

    return [[self class] yy_modelWithJSON:json];
}
+ (NSMutableArray *)objsFromDicts:(NSArray<NSDictionary*>*)dicts {
    __block NSArray *temArr = nil;
    if ([dicts isKindOfClass:[NSArray class]]) {
        
        temArr = dicts;
    } else if ([dicts isKindOfClass:[NSDictionary class]]) {
        
        [(NSDictionary *)dicts enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[NSArray class]]) {
                
                temArr = obj;
                *stop = YES;
            }
        }];
    }
    return [NSArray yy_modelArrayWithClass:[self class] json:temArr].mutableCopy;
}
- (NSString *)description {
    return [self yy_modelDescription];
}
- (id)dict {
    return [self yy_modelToJSONObject];
}
-(NSString *)JSONString {
    return [self yy_modelToJSONString];

}
@end
