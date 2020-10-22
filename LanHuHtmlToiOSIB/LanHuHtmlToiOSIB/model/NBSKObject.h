
#import "SXBaseModel.h"



#pragma mark - 蓝湖
@interface Color :SXBaseModel
@property (nonatomic , assign) CGFloat              red;
@property (nonatomic , assign) CGFloat              green;
@property (nonatomic , assign) CGFloat              blue;

@end


@interface TextStyle :SXBaseModel
@property (nonatomic , copy) NSString              * fontName;
@property (nonatomic , copy) NSString              * fontStyleName;
@property (nonatomic , assign) NSInteger              size;
@property (nonatomic , copy) NSString              * fontPostScriptName;
@property (nonatomic , assign) BOOL              autoLeading;
@property (nonatomic , copy) NSString              * fontCaps;
@property (nonatomic , copy) NSString              * japaneseAlternate;
@property (nonatomic , assign) NSInteger              impliedFontSize;
@property (nonatomic , assign) NSInteger              impliedLeading;
@property (nonatomic , assign) NSInteger              impliedBaselineShift;
@property (nonatomic , assign) BOOL              contextualLigatures;
@property (nonatomic , assign) NSInteger              markYDistFromBaseline;
@property (nonatomic , strong) Color              * color;
@property (nonatomic , assign) NSInteger              fontTechnology;
@property (nonatomic , assign) NSInteger              leading;
@property (nonatomic , assign) NSInteger              tracking;

@end


@interface TextStyleRangeItem :SXBaseModel
@property (nonatomic , assign) NSInteger              from;
@property (nonatomic , assign) NSInteger              to;
@property (nonatomic , strong) TextStyle              * textStyle;

@end


@interface Bounds :SXBaseModel
@property (nonatomic , assign) NSInteger              left;
@property (nonatomic , assign) CGFloat              top;
@property (nonatomic , assign) NSInteger              right;
@property (nonatomic , assign) CGFloat              bottom;

@end


@interface BoundingBox :SXBaseModel
@property (nonatomic , assign) CGFloat              left;
@property (nonatomic , assign) CGFloat              top;
@property (nonatomic , assign) CGFloat              right;
@property (nonatomic , assign) CGFloat              bottom;

@end


@interface Transform :SXBaseModel
@property (nonatomic , assign) NSInteger              xx;
@property (nonatomic , assign) NSInteger              xy;
@property (nonatomic , assign) NSInteger              yx;
@property (nonatomic , assign) NSInteger              yy;
@property (nonatomic , assign) NSInteger              tx;
@property (nonatomic , assign) NSInteger              ty;

@end


@interface Base :SXBaseModel
@property (nonatomic , assign) NSInteger              horizontal;
@property (nonatomic , assign) NSInteger              vertical;

@end


@interface TextShapeItem :SXBaseModel
@property (nonatomic , copy) NSString              * m_char;
@property (nonatomic , copy) NSString              * orientation;
@property (nonatomic , strong) Transform              * transform;
@property (nonatomic , assign) NSInteger              rowCount;
@property (nonatomic , assign) NSInteger              columnCount;
@property (nonatomic , assign) BOOL              rowMajorOrder;
@property (nonatomic , assign) NSInteger              rowGutter;
@property (nonatomic , assign) NSInteger              columnGutter;
@property (nonatomic , assign) NSInteger              spacing;
@property (nonatomic , copy) NSString              * frameBaselineAlignment;
@property (nonatomic , assign) NSInteger              firstBaselineMinimum;
@property (nonatomic , strong) Base              * base;

@end


@interface TextInfo :SXBaseModel
/// 字内容，如 购课记录
@property (nonatomic , copy) NSString              * text;
/// 颜色
@property (nonatomic , strong) Color              * color;
/// 字号，得除2
@property (nonatomic , assign) NSInteger              size;
/// 如 "PingFang-SC-Bold"
@property (nonatomic , copy) NSString              * fontPostScriptName;
/// 粗
@property (nonatomic , assign) BOOL              bold;
@property (nonatomic , assign) BOOL              italic;
@property (nonatomic , copy) NSString              * justification;
@property (nonatomic , assign) NSInteger              leading;
@property (nonatomic , assign) NSInteger              tracking;
@property (nonatomic , strong) NSArray <TextStyleRangeItem *>              * textStyleRange;
@property (nonatomic , copy) NSString              * fontName;
@property (nonatomic , copy) NSString              * fontStyleName;
@property (nonatomic , copy) NSString              * antiAlias;
@property (nonatomic , strong) Bounds              * bounds;
@property (nonatomic , strong) BoundingBox              * boundingBox;
@property (nonatomic , strong) NSArray <TextShapeItem *>              * textShape;

@end
@interface LHImage:SXBaseModel
/// "orgUrl":"https://lanhu.oss-cn-beijing.aliyuncs.com/ps9abb82c7082de24d-6f91-4492-ae05-c7f818e4b45e"
@property(nonatomic, copy) NSString *orgUrl;
/// "base":"iOS @2x",
@property(nonatomic, copy) NSString *base;
/// "png_xxxhd":"https://lanhu.oss-cn-beijing.aliyuncs.com/pscce0b307a9f36f70-4735-4578-a31e-ab5dd7af7455"
@property(nonatomic, copy) NSString *png_xxxhd;
 

@end
@interface BlendOptions: SXBaseModel
/// passThrough
@property(nonatomic, copy) NSString *mode;
@end
@interface Protection :SXBaseModel
@property (nonatomic , assign) BOOL              transparency;
@property (nonatomic , assign) BOOL              position;
@property (nonatomic , assign) BOOL              artboardAutonest;

@end
@interface _orgBounds :SXBaseModel
@property (nonatomic , assign) NSInteger              top;
@property (nonatomic , assign) NSInteger              left;
@property (nonatomic , assign) NSInteger              bottom;
@property (nonatomic , assign) NSInteger              right;

@end
@interface VisibleItem :SXBaseModel
/// 是否是文字
@property(nonatomic) BOOL text;
@property(nonatomic) TextInfo *textInfo;


@property(nonatomic) LHImage *images;
@property (nonatomic , assign) NSInteger              id;
@property (nonatomic , assign) NSInteger              index;
@property(nonatomic) NSArray<VisibleItem *> *layers;
/// layerSection  shapeLayer backgroundLayer
@property (nonatomic , copy) NSString              * type;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , strong) Protection              * protection;
/// 是否可见
@property (nonatomic , assign) BOOL              visible;
@property (nonatomic , assign) BOOL              clipped;
@property (nonatomic , assign) BOOL              pixels;
@property (nonatomic , strong) _orgBounds              * bounds;
@property(nonatomic) BlendOptions *blendOptions;
@property (nonatomic , assign) NSInteger              width;
@property (nonatomic , assign) NSInteger              height;
@property (nonatomic , assign) NSInteger              top;
@property (nonatomic , assign) NSInteger              left;

@property (nonatomic , assign) BOOL              generatorSettings;
@property (nonatomic , assign) BOOL              isAsset;
@property (nonatomic , assign) BOOL              isSlice;
@property(nonatomic) BOOL _hit_delete;
@end

@interface NBSKObject :SXBaseModel
@property (nonatomic , assign) NSInteger              id;

/// 是否是单个页面
@property (nonatomic , assign) BOOL              isPage;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , assign) NSInteger              resolution;
@property (nonatomic , strong) NSArray <VisibleItem *>              * visible;
@property (nonatomic , assign) BOOL              isAsset;
@property (nonatomic , assign) BOOL              isSlice;
@property (nonatomic , assign) NSInteger              web_id;
@end
