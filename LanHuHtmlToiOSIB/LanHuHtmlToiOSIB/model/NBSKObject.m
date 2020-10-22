#import "NBSKObject.h"

@implementation NBSKObject
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"visible": [VisibleItem class]
    };
}
@end
#pragma mark - 蓝湖
@implementation Protection
@end
@implementation _orgBounds
@end
@implementation VisibleItem
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
        @"layers": [VisibleItem class]
    };
}
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"bounds":@[@"bounds", @"_orgBounds"]};
}
@end

@implementation BlendOptions
@end
@implementation LHImage
@end

@implementation Color
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"red": @"r",
             @"green" : @"g",
             @"blue": @"b"
    };
}
@end 


@implementation TextStyle
@end


@implementation TextStyleRangeItem
@end


@implementation Bounds
@end


@implementation BoundingBox
@end


@implementation Transform
@end


@implementation Base
@end


@implementation TextShapeItem
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"m_char": @"char"};
}

@end


@implementation TextInfo
@end
