
#import "SXBaseModel.h"
#import <YYModel.h>

@implementation SXBaseModel

+ (instancetype)objWithJSON:(id)json {
    return [[self class] yy_modelWithJSON:json];
}
+ (NSArray *)objsFromDicts:(NSArray<NSDictionary*>*)dicts {
    
    return [NSArray yy_modelArrayWithClass:[self class] json:dicts];
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
