#import "NBSKObject.h"

@implementation SKRect
@end
@implementation SKBorder
@end
@implementation SKFill
@end

@implementation SKShadow
@end
@implementation SKColor
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"colorHex": @"color-hex",
             @"argbHex": @"argb-hex",
             @"cssRgba": @"css-rgba",
             @"uiColor": @"ui-color",
             
             
    };
}
@end


@implementation SKLayer
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"borders" : [SKBorder class],
             @"fills" : [SKFill class],
             @"shadows": [SKShadow class]
    };
}
@end


@implementation NotesItem
@end


@implementation ArtboardsItem
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"layers" : [SKLayer class]
    };
}
@end




@implementation ExportableItem
@end


@implementation SlicesItem
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"exportable" : [ExportableItem class]
    };
}


@end


@implementation ColorsItem
@end


@implementation NBSKObject
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"artboards" : [ArtboardsItem class],
             @"slices" : [SlicesItem class],
             @"colors" : [ColorsItem class],
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
