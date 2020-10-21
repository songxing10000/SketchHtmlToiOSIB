
#import "SXBaseModel.h"


@interface SKRect :SXBaseModel
@property (nonatomic , copy) NSString              *x;
@property (nonatomic , copy) NSString              *y;
@property (nonatomic , copy) NSString              *width;
@property (nonatomic , copy) NSString              *height;

@end


@interface SKColor :SXBaseModel
/// 182
@property (nonatomic , assign) NSInteger              r;
/// 183
@property (nonatomic , assign) NSInteger              g;
/// 184
@property (nonatomic , assign) NSInteger              b;
/// 1
@property (nonatomic , assign) NSInteger              a;
/// #B6B7B8 100%
@property (nonatomic , copy) NSString              * colorHex;
/// #FFB6B7B8
@property (nonatomic , copy) NSString              * argbHex;
/// rgba(182,183,184,1)
@property (nonatomic , copy) NSString              * cssRgba;
/// (r:0.71 g:0.72 b:0.72 a:1.00)
@property (nonatomic , copy) NSString              * uiColor;

@end

@interface SKBorder :SXBaseModel
/// 如 color
@property (nonatomic , copy) NSString              * fillType;
/// 如 center
@property (nonatomic , copy) NSString              * position;
@property (nonatomic , copy) NSString              * thickness;
/**
 *
 */
@property (nonatomic , strong) SKColor * color;

@end
@interface SKFill :SXBaseModel
/// 如 color
@property (nonatomic , copy) NSString              * fillType;
@property (nonatomic , strong) SKColor * color;

@end
@interface SKShadow :SXBaseModel
/// 如 outer
@property (nonatomic , copy) NSString              * type;
@property (nonatomic , copy) NSString              * offsetX;
@property (nonatomic , copy) NSString              * offsetY;
@property (nonatomic , copy) NSString              * blurRadius;

@property (nonatomic , copy) NSString              * spread;
@property (nonatomic , strong) SKColor * color;

@end
@interface SKLayer :SXBaseModel
@property (nonatomic , copy) NSString              * objectID;
/// 控件类别 text为lable， slice为图片，shape为view
@property (nonatomic , copy) NSString              * type;
/// 如，bg背景，大view
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , strong) SKRect              * rect;
@property (nonatomic , assign) NSInteger              rotation;
@property (nonatomic , assign) NSInteger              radius;

@property (nonatomic , strong) NSArray <SKBorder *> * borders;
@property (nonatomic , strong) NSArray <SKFill *> * fills;
@property (nonatomic , strong) NSArray <SKShadow *> * shadows;

/// 背色的透明度
@property (nonatomic , copy) NSString              *opacity;
@property (nonatomic , copy) NSString              * styleName;
/// 为lable时，要显示的文字
@property (nonatomic , copy) NSString              * content;
@property (nonatomic , strong) SKColor              * color;
@property (nonatomic , copy) NSString              *fontSize;
/// PingFangSC-Regular
@property (nonatomic , copy) NSString              * fontFace;
/// left
@property (nonatomic , copy) NSString              * textAlign;
/// -0.3135295
@property (nonatomic , assign) CGFloat              letterSpacing;
@property (nonatomic , assign) NSInteger              lineHeight;
/// css样式，如，     "background: #295DFD;" "border: 1px solid #295DFD;","border-radius: 4px;" "font-family: PingFangSC-Semibold;","font-size: 17px;","color: #295DFD;","letter-spacing: -0.54px;"
@property (nonatomic , strong) NSArray <NSString *>              * css;

@end


@interface NotesItem :SXBaseModel

@end


@interface ArtboardsItem :SXBaseModel
/// 控件集合
@property (nonatomic , strong) NSArray <SKLayer *>              * layers;
@property (nonatomic , copy) NSString              * pageName;
@property (nonatomic , copy) NSString              * pageObjectID;
/// 页面名字
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * slug;
@property (nonatomic , copy) NSString              * objectID;
@property (nonatomic , assign) NSInteger              width;
@property (nonatomic , assign) NSInteger              height;
/// 页面 图片 整体 预览
@property (nonatomic , copy) NSString              * imagePath;

@end



@interface ExportableItem :SXBaseModel
/// 图片名
@property (nonatomic , copy) NSString              * name;
/// 图片格式 ，如，png
@property (nonatomic , copy) NSString              * format;
/// 图片路径 ，如， 进入@2x.png
@property (nonatomic , copy) NSString              * path;

@end


@interface SlicesItem :SXBaseModel
/// 图片名
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * objectID;
@property (nonatomic , strong) SKRect              * rect;
@property (nonatomic , strong) NSArray <ExportableItem *>              * exportable;

@end


@interface ColorsItem :SXBaseModel

@end


@interface NBSKObject :SXBaseModel
/// 1
@property (nonatomic , copy) NSString              * scale;
/// px
@property (nonatomic , copy) NSString              * unit;
/// color-hex
@property (nonatomic , copy) NSString              * colorFormat;
/// 页面集合
@property (nonatomic , strong) NSArray <ArtboardsItem *>              * artboards;
/// 切图
@property (nonatomic , strong) NSArray <SlicesItem *>              * slices;
@property (nonatomic , strong) NSArray <ColorsItem *>              * colors;

@end
