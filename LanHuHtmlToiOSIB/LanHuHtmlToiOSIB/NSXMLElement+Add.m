//
//  NSXMLElement+Add.m
//  LanHuHtmlToiOSIB
//
//  Created by mac on 2019/6/16.
//  Copyright © 2019 dfpo. All rights reserved.
//

#import "NSXMLElement+Add.h"
#import "NSString+Add.h"
#import <objc/runtime.h>
@implementation NSXMLElement (Add)
static const char skRectKey = '\0';
- (_orgBounds *)skRect
{
    return objc_getAssociatedObject(self, &skRectKey);
}

-(void)setSkRect:(_orgBounds *)rect {
    objc_setAssociatedObject(self, &skRectKey, rect, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    NSXMLElement *rectElement = [self firstElementByName:@"rect"];
    NSArray<NSXMLNode *> *nodes = rectElement.attributes;
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"x"]) {
            [node setStringValue: @(rect.left * 0.5).stringValue];
        } else if ([node.name isEqualToString: @"y"]) {
            [node setStringValue: @(rect.top * 0.5).stringValue];
        } else if ([node.name isEqualToString: @"width"]) {
            CGFloat w = (rect.right - rect.left)*0.5;
            if ([self.name isEqualToString:@"label"]) {
                w += 2;
            }
            [node setStringValue: @(w).stringValue];
        } else if ([node.name isEqualToString: @"height"]) {
            CGFloat h = (rect.bottom-rect.top)*0.5;
            if ([self.name isEqualToString:@"label"]) {
                h += 7;
            }
            [node setStringValue: @(h).stringValue];
        }
    }
}

-(NSString *)text {
    return [self m_getValueForKey:@"text"];
}
-(void)setText:(NSString *)text {
    [self m_setValue:text forKey:@"text"];
}
-(NSString *)normalTitleColor {
    if (![self.name isEqualToString: @"button"]) {
        return @"";
    }
    /*
     <button >
     <state key="normal" title="进行个人认证">
     <color key="titleColor" red="0.602876575629404" green="0.40777175996932513" blue="0.31287945139627515" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
     </state>
     </button>
     */
    NSXMLElement *stateTextElement = [self firstElementByName:@"state"];
    return stateTextElement.titleColor;
}
-(void)setNormalTitleColor:(NSString *)normalTitleColor {
    if (![self.name isEqualToString: @"button"]) {
        return;
    }
    /*
     <button >
     <state key="normal" title="进行个人认证">
     <color key="titleColor" red="0.602876575629404" green="0.40777175996932513" blue="0.31287945139627515" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
     </state>
     </button>
     */
    NSXMLElement *stateTextElement = [self firstElementByName:@"state"];
    stateTextElement.titleColor = normalTitleColor;
}
-(NSString *)titleColor {
    return [self getColorType: @"titleColor"];
    
}
-(void)setTitleColor:(NSString *)titleColor {
    [self setColor:titleColor type:@"titleColor"];
    
}
-(NSString *)textColor {
    return [self getColorType: @"textColor"];
    
}
-(void)setTextColor:(NSString *)textColor {
    [self setColor:textColor type:@"textColor"];
}
-(NSString *)backgroundColor {
    return [self getColorType: @"backgroundColor"];
    
}
-(void)setBackgroundColor:(NSString *)backgroundColor {
    [self setColor:backgroundColor type:@"backgroundColor"];
}
- (NSXMLElement *)firstElementByName:(NSString *)elementName {
    NSArray<NSXMLElement *> *elements = [self elementsForName:elementName];
    if (elements.count >= 1) {
        return elements[0];
    }
    /*
     
     
     */
    NSLog(@"未找到 %@，创建空的", elementName);
    NSXMLElement *add = [NSXMLElement elementWithName:elementName];
    [self addChild:add.copy];
    return add ;
}
-(NSString *)fontSize {
    NSXMLElement *fontDescription = [self firstElementByName:@"fontDescription"];
    NSString *key = @"pointSize";
    return [fontDescription m_getValueForKey:key];
}
- (void)setFontSize:(NSString *)fontSize {
    
    NSString *input = fontSize;
    BOOL hasValue = input && input.length > 0;
    if (!hasValue) {
        return;
    }
    NSXMLElement *fontDescription = [self firstElementByName:@"fontDescription"];
    NSString *key = @"pointSize";
    [fontDescription m_setValue:fontSize forKey:key];
}
- (NSString *)m_getValueForKey:(NSString *)key   {
    if (!key || !self) {
        return @"";
    }
    BOOL hasKey = [self attributeForName: key].name.length;
    if (hasKey) {
        NSString *valueStr = [self attributeForName: key].stringValue;
        return valueStr;
    }
    return @"";
}
- (void)m_setValue:(NSString *)value forKey:(NSString *)key  {
    if (!key || !value || !self) {
        return;
    }
    BOOL hasKey = [self attributeForName: key].name.length;
    if (hasKey) {
        NSString *valueStr = [self attributeForName: key].stringValue;
        if ([value isEqualToString:valueStr]) {
            return;
        }
        [self setAttributesAsDictionary: @{key:value}];
    } else {
        [self addAttribute:[NSXMLNode attributeWithName:key stringValue: value]];
    }
}
-(NSString *)getColorType:(NSString *)type {
    NSString *input = type;
    BOOL hasValue = input && input.length > 0;
    if (!hasValue) {
        return @"";
    }
    NSArray<NSXMLElement *> *elements = (NSArray<NSXMLElement *> *)[self elementsForName:@"color"];
    NSXMLElement *desElement;
    for (NSXMLElement *colorE in elements) {
        NSArray<NSXMLNode *> *nodes = colorE.attributes;
        for (NSXMLNode * node in nodes) {
            if ([node.name isEqualToString:@"key"]) {
                if ([[node stringValue] isEqualToString:@"textColor"] &&
                    [type isEqualToString:@"textColor"]) {
                    desElement = colorE;
                    break;
                } else if ([[node stringValue] isEqualToString:@"backgroundColor"] &&
                           [type isEqualToString:@"backgroundColor"]) {
                    desElement = colorE;
                    break;
                } else if ([[node stringValue] isEqualToString:@"titleColor"] &&
                           [type isEqualToString:@"titleColor"]) {
                    desElement = colorE;
                    break;
                }
            }
        }
    }
    if (!desElement) {
        return @"";
    }
    NSXMLElement *rectElement = desElement;
    NSArray<NSXMLNode *> *nodes = rectElement.attributes;
    // (r:1.00 g:1.00 b:1.00 a:1.00)
    NSString *rS = @"";
    NSString *gS = @"";
    NSString *bS = @"";
    NSString *aS = @"";
    
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"red"]) {
            rS = node.stringValue;
        }else if ([node.name isEqualToString: @"green"]) {
            gS = node.stringValue;
        } else if ([node.name isEqualToString: @"blue"]) {
            bS = node.stringValue;
        } else if ([node.name isEqualToString: @"realphad"]) {
            aS = node.stringValue;
        }
        
    }
    return [NSString stringWithFormat:@"(r:%@ g:%@ b:%@ a:%@)", rS, gS, bS, aS];
}
-(void)setColor:(NSString *)textColor type:(NSString *)type {
    NSString *input = textColor;
    BOOL hasValue = input && input.length > 0;
    if (!hasValue) {
        return;
    }
    NSArray<NSXMLElement *> *elements = (NSArray<NSXMLElement *> *)[self elementsForName:@"color"];
    NSXMLElement *desElement;
    for (NSXMLElement *colorE in elements) {
        NSArray<NSXMLNode *> *nodes = colorE.attributes;
        for (NSXMLNode * node in nodes) {
            if ([node.name isEqualToString:@"key"]) {
                if ([[node stringValue] isEqualToString:@"textColor"] &&
                    [type isEqualToString:@"textColor"]) {
                    desElement = colorE;
                    break;
                } else if ([[node stringValue] isEqualToString:@"backgroundColor"] &&
                           [type isEqualToString:@"backgroundColor"]) {
                    desElement = colorE;
                    break;
                }
                else if ([[node stringValue] isEqualToString:@"titleColor"] &&
                         [type isEqualToString:@"titleColor"]) {
                    desElement = colorE;
                    break;
                }
            }
        }
    }
    if (!desElement) {
        return;
    }
    NSXMLElement *rectElement = desElement;
    NSArray<NSXMLNode *> *nodes = rectElement.attributes;
    NSString *rStr = nil;
    NSString *gStr = nil;
    NSString *bStr = nil;
    NSString *aStr = nil;
    
    NSString *key1Str = @"rgba(";
    NSString *key2Str = @"(r:";
    if ([textColor containsString: key1Str]) {
        // 这种情况 rgba(34,34,34,1)
        NSString *color = [textColor stringByReplacingOccurrencesOfString: key1Str withString:@""];
        color = [color stringByReplacingOccurrencesOfString: @")" withString:@""];
        NSArray<NSString *> *rgba = [color componentsSeparatedByString: @","];
        rStr = [self getColorValueFromStr: rgba[0]];
        gStr = [self getColorValueFromStr: rgba[1]];
        bStr = [self getColorValueFromStr: rgba[2]];
        aStr = rgba[3];
        if (![aStr isEqualToString: @"1"]) {
            if ([aStr hasPrefix: @"0."]) {
                // 0.27
                
            } else {
                
                NSAssert(false, @"这情况得兼容下");
            }
        }
        
    } else if ([textColor containsString: key2Str]){
        // 这种情况 (r:0.13 g:0.13 b:0.13 a:1.00)
        NSString *color = [textColor stringByReplacingOccurrencesOfString:@"(r:" withString:@""];
        color = [color stringByReplacingOccurrencesOfString:@".00)" withString:@""];
        color = [color stringByReplacingOccurrencesOfString:@"r:" withString:@""];
        color = [color stringByReplacingOccurrencesOfString:@"g:" withString:@""];
        color = [color stringByReplacingOccurrencesOfString:@"b:" withString:@""];
        color = [color stringByReplacingOccurrencesOfString:@"a:" withString:@""];
        NSArray<NSString *> *rgba = [color componentsSeparatedByString:@" "];
        rStr = rgba[0];
        gStr = rgba[1];
        bStr = rgba[2];
        aStr = [rgba[3] stringByReplacingOccurrencesOfString: @")" withString:@""];
        if ( aStr.length == 0 ) {
            // 修复可能出错的情况
            aStr = @"1";
        }
    }
    
    
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"red"]) {
            [node setStringValue: rStr];
        }else if ([node.name isEqualToString: @"green"]) {
            [node setStringValue: gStr];
        } else if ([node.name isEqualToString: @"blue"]) {
            [node setStringValue: bStr];
        } else if ([node.name isEqualToString: @"alpha"]) {
            [node setStringValue: aStr];
        }
    }
}
-(NSString *)fontStyle {
    NSXMLElement *fontDescription = [self firstElementByName:@"fontDescription"];
    return [fontDescription m_getValueForKey:@"name"];
}
-(void)setFontStyle:(NSString *)fontStyle {
    
    NSString *fontStyleName = fontStyle;
    if (fontStyleName && fontStyleName.length > 0) {
        /*
         label xml 中没有添加  type="system" ，如果添加以下两种字体会涉及删除 type="system" 这个东西，所以如果是系统的就加上这个key更容易处理，目前UI给的全是苹方字体
         苹方-简 常规体  PingFangSC-Regular
         <fontDescription key="fontDescription" name="PingFangSC-Regular" family="PingFang SC" pointSize="17"/>
         苹方-简 中黑体  PingFangSC-Medium
         <fontDescription key="fontDescription" name="PingFangSC-Medium" family="PingFang SC" pointSize="17"/>
         苹方-简 中粗体
         <fontDescription key="fontDescription" name="PingFangSC-Semibold" family="PingFang SC" pointSize="17"/>
         */
        NSXMLElement *fontDescription = [self firstElementByName:@"fontDescription"];
        if([fontStyleName isEqualToString: @"PingFangSC-Regular"] ||
           [fontStyleName isEqualToString: @"PingFang-SC-Regular"]) {
            [fontDescription m_setValue:@"PingFangSC-Regular" forKey:@"name"];
            [fontDescription m_setValue:@"PingFang SC" forKey:@"family"];
            
        } else if([fontStyleName isEqualToString: @"PingFangSC-Medium"] ||
                  [fontStyleName isEqualToString: @"PingFang-SC-Medium"]) {
            [fontDescription m_setValue:@"PingFangSC-Medium" forKey: @"name"];
            [fontDescription m_setValue:@"PingFang SC" forKey: @"family"];
            
        } else if([fontStyleName isEqualToString: @"PingFangSC-Semibold"] ||
                  [fontStyleName isEqualToString: @"PingFang-SC-Bold"] ||
                  [fontStyleName isEqualToString: @"PingFangSC-Bold"]) {
            [fontDescription m_setValue:@"PingFangSC-Semibold" forKey: @"name"];
            [fontDescription m_setValue:@"PingFang SC" forKey: @"family"];
        } else if([fontStyleName isEqualToString: @"PingFangSC-Light"]) {
            [fontDescription m_setValue:@"PingFangSC-Light" forKey: @"name"];
            [fontDescription m_setValue:@"PingFang SC" forKey: @"family"];
        } else if([fontStyleName isEqualToString: @"PingFangHK-Regular"]) {
            [fontDescription m_setValue:@"PingFangHK-Regular" forKey: @"name"];
            [fontDescription m_setValue:@"PingFang HK" forKey: @"family"];
        } else if([fontStyleName isEqualToString: @"PingFangHK-Medium"]) {
            [fontDescription m_setValue:@"PingFangHK-Medium" forKey: @"name"];
            [fontDescription m_setValue:@"PingFang HK" forKey: @"family"];
        } else if([fontStyleName isEqualToString: @"STHeitiSC-Light"]) {
            [fontDescription m_setValue:@"STHeitiSC-Light" forKey: @"name"];
            [fontDescription m_setValue:@"STHeiti SC" forKey: @"family"];
        }
        else if([fontStyleName isEqualToString: @"DINAlternate-Bold"]) {
            /*
             <fontDescription key="fontDescription" name="DINAlternate-Bold" family="DIN Alternate" pointSize="16"/>
             */
            [fontDescription m_setValue:@"DINAlternate-Bold" forKey: @"name"];
            [fontDescription m_setValue:@"DIN Alternate" forKey: @"family"];
        } else if([fontStyleName isEqualToString: @"Helvetica"]) {
            /*
             <fontDescription key="fontDescription" name="Helvetica" family="Helvetica" pointSize="16"/>
             */
            [fontDescription m_setValue:@"Helvetica" forKey: @"name"];
            [fontDescription m_setValue:@"Helvetica" forKey: @"family"];
        } else {
            
            NSLog(@"找不到字体：%@", fontStyleName);
        }
    }
}
/// 34 转换成 34/255
-(NSString*)getColorValueFromStr:(NSString *)input{
    if (![input containsString: @"."]) {
        // 整数
        return [NSString stringWithFormat:@"%.17f", [input intValue] / 255.0];
    }
    return  @"ff";
}

+ (nullable NSXMLElement *)elementWithItem:(nonnull VisibleItem *)view {
    if (!view.visible) {
        return nil;
    }
    /// 控件类别 text为lable， slice为图片，shape为view
    NSString *viewType = view.type;
    /// 将要被添加的新的 view NSXMLElement 对象
    NSXMLElement *aNewWillBeAddedViewElement = nil;
    if (view.text) {
        
        
        if (([view.textInfo.text hasPrefix: @"请输入"] ||
             [view.textInfo.text hasPrefix: @"请填写"]) ) {
#pragma mark - UITextFiled
            // 输入框
            NSXMLElement *textFiledElement = [self getNewTextFiledElement];
            // placeholder
            [textFiledElement m_setValue: view.textInfo.text forKey: @"placeholder"];
            
            textFiledElement.fontSize = @(view.textInfo.size * 0.5).stringValue;
            textFiledElement.fontStyle = view.textInfo.fontPostScriptName;
            // placeholder 颜色xml内置
            // 正常情况下的文字颜色 xml内置
            
            //                    textFiledElement.textColor =
            //                    [NSString stringWithFormat:@"(r:%f g:%f b:%f a:1.00)",view.color.r/255.0, view.color.g/255.0, view.color.b/255.0];
            aNewWillBeAddedViewElement = textFiledElement;
        } else {
#pragma mark - UILabel
            
            // 文本
            NSXMLElement *labelElement = [self getNewlabelElement];
            labelElement.text = view.textInfo.text;
            if ([labelElement.text isEqualToString:@"设备检测"]) {
                NSLog(@"---%@---",@"ff");
            }
            labelElement.fontSize = @(view.textInfo.size * 0.5).stringValue;
            labelElement.fontStyle = view.textInfo.fontPostScriptName;
            
            labelElement.textColor =
            [NSString stringWithFormat:@"(r:%f g:%f b:%f a:1.00)",view.textInfo.color.red/255.0, view.textInfo.color.green/255.0, view.textInfo.color.blue/255.0];
            aNewWillBeAddedViewElement = labelElement;
        }
    }
    else if (view.isAsset) {
        //图片
#pragma mark - UIImageView
        NSXMLElement *imgElement = [self getNewImageViewElementWithImgName: view.name];
        aNewWillBeAddedViewElement = imgElement;
    }
    else if ([viewType isEqualToString:@"layerSection"]) {
#pragma mark - UIView
        NSXMLElement *viewElement = [self getNewViewElement];
        aNewWillBeAddedViewElement = viewElement;
    }
    else {
        // backgroundLayer layer shapeLayer adjustmentLayer
        NSLog(@"--未知类型控件--%@---", viewType);
    }
    aNewWillBeAddedViewElement.skRect = view.bounds;
    return  aNewWillBeAddedViewElement;
}
+ (void)setRandomIdForElement:(NSXMLElement *)element {
    NSArray<NSXMLNode *> *nodes = element.attributes;
    NSString *name = [element.name isEqualToString:@"scene"]?@"sceneID":@"id";
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: name]) {
            [node setStringValue:[NSString randomid]];
        }
    }
}

+ (NSXMLElement *)rootElementWithXmlFileName:(NSString *)xmlFileName {
    return (NSXMLElement *)[self documentWithXmlFileName:xmlFileName].rootElement;
}
+ (NSXMLDocument *)documentWithXmlFileName:(NSString *)xmlFileName {
    
    NSError *error = nil;
    
    NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:xmlFileName
                                                            ofType:@"xml"];
    if (!xmlFilePath) {
        NSLog(@"找不到xml文件%@", xmlFileName);
        return [NSXMLDocument document];
    }
    NSData *xmlData = [NSData dataWithContentsOfFile:xmlFilePath options: 0 error: &error];
    if (error) {
        NSLog(@"error = %@",error);
        return [NSXMLDocument document];
    }
    NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithData:xmlData options:NSXMLNodePreserveWhitespace error:&error];
    return xmlDocument;
}


+ (NSXMLElement *)getNewVCElement {
    NSXMLElement *vcElement = [NSXMLElement rootElementWithXmlFileName:@"vc"];
    [NSXMLElement setRandomIdForElement:vcElement];
    NSXMLElement *objects = [vcElement firstElementByName:@"objects"];
    NSXMLElement *placeholder = [objects firstElementByName:@"placeholder"];
    [NSXMLElement setRandomIdForElement:placeholder];
    
    NSXMLElement *viewController = [objects firstElementByName:@"viewController"];
    [NSXMLElement setRandomIdForElement:viewController];
    
    
    NSXMLElement *view = [viewController firstElementByName:@"view" ];
    [NSXMLElement setRandomIdForElement:view];
    NSXMLElement *viewLayoutGuide = [view firstElementByName:@"viewLayoutGuide" ];
    [NSXMLElement setRandomIdForElement:viewLayoutGuide];
    
    return vcElement.copy;
}
+ (NSXMLElement *)getNewTextFiledElement {
    NSXMLElement *textFiledElement = [NSXMLElement rootElementWithXmlFileName:@"textField"];
    [NSXMLElement setRandomIdForElement:textFiledElement];
    return textFiledElement.copy;
}
+ (NSXMLElement *)getNewlabelElement {
    NSXMLElement *lableElement = [NSXMLElement rootElementWithXmlFileName:@"label"];
    [NSXMLElement setRandomIdForElement:lableElement];
    return lableElement.copy;
}
+ (NSXMLElement *)getNewButtonElement {
    NSXMLElement *lableElement = [NSXMLElement rootElementWithXmlFileName:@"button"];
    [NSXMLElement setRandomIdForElement:lableElement];
    return lableElement.copy;
}
/// name imageView"
+ (NSXMLElement *)getNewImageViewElementWithImgName:(NSString *)imgName {
    NSXMLElement *imgVElement = [NSXMLElement rootElementWithXmlFileName:@"imageView"];
    [imgVElement m_setValue: imgName forKey: @"image"];
    [NSXMLElement setRandomIdForElement:imgVElement];
    return imgVElement.copy;
}
+ (NSXMLElement *)getNewViewElement {
    NSXMLElement *viewElement = [NSXMLElement rootElementWithXmlFileName:@"view"];
    [NSXMLElement setRandomIdForElement:viewElement];
    return viewElement.copy;
}
@end
