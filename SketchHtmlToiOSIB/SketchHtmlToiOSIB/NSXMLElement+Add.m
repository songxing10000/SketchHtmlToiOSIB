//
//  NSXMLElement+Add.m
//  SketchHtmlToiOSIB
//
//  Created by mac on 2019/6/16.
//  Copyright © 2019 dfpo. All rights reserved.
//

#import "NSXMLElement+Add.h"

@implementation NSXMLElement (Add)
-(CGRect)cgRect {
    SKRect *skRect = self.skRect;
    CGRect rect =
    CGRectMake(skRect.x.floatValue, skRect.y.floatValue, skRect.width.floatValue, skRect.height.floatValue);
    return rect;
}
-(void)setCgRect:(CGRect)cgRect {
    
}
-(SKRect *)skRect {
    SKRect *rect = [SKRect new];
    NSXMLElement *rectElement = [self firstElementByName:@"rect"];
    NSArray<NSXMLNode *> *nodes = rectElement.attributes;
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"x"]) {
            
            rect.x = node.stringValue;
        } else if ([node.name isEqualToString: @"y"]) {
            rect.y  = node.stringValue;
        } else if ([node.name isEqualToString: @"width"]) {
            rect.width = node.stringValue;
            if ([self.name isEqualToString:@"label"]) {
                /// 修复lable宽度，自动布局时，宽度自适应
                NSString *fixW = @(rect.width.integerValue+6).stringValue;
                rect.width =  fixW;
            }
        } else if ([node.name isEqualToString: @"height"]) {
            rect.height = node.stringValue;
        }
    }
    return rect;
}
-(void)setSkRect:(SKRect *)rect {
    NSXMLElement *rectElement = [self firstElementByName:@"rect"];
    NSArray<NSXMLNode *> *nodes = rectElement.attributes;
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"x"]) {
            [node setStringValue: rect.x];
        } else if ([node.name isEqualToString: @"y"]) {
            [node setStringValue: rect.y];
        } else if ([node.name isEqualToString: @"width"]) {
            [node setStringValue: rect.width];
            if ([self.name isEqualToString:@"label"]) {
                /// 修复lable宽度，自动布局时，宽度自适应
                NSString *fixW = @(rect.width.integerValue+6).stringValue;
                [node setStringValue: fixW];
            }
        } else if ([node.name isEqualToString: @"height"]) {
            [node setStringValue: rect.height];
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
    NSString *color = [textColor stringByReplacingOccurrencesOfString:@"(r:" withString:@""];
    color = [color stringByReplacingOccurrencesOfString:@".00)" withString:@""];
    color = [color stringByReplacingOccurrencesOfString:@"r:" withString:@""];
    color = [color stringByReplacingOccurrencesOfString:@"g:" withString:@""];
    color = [color stringByReplacingOccurrencesOfString:@"b:" withString:@""];
    color = [color stringByReplacingOccurrencesOfString:@"a:" withString:@""];
    NSArray<NSString *> *rgba = [color componentsSeparatedByString:@" "];
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"red"]) {
            [node setStringValue: rgba[0]];
        }else if ([node.name isEqualToString: @"green"]) {
            [node setStringValue: rgba[1]];
        } else if ([node.name isEqualToString: @"blue"]) {
            [node setStringValue: rgba[2]];
        } else if ([node.name isEqualToString: @"alpha"]) {
            NSString *alphaStr = [rgba[3] stringByReplacingOccurrencesOfString: @")" withString:@""];
            if ( alphaStr.length == 0 ) {
                // 修复可能出错的情况
                alphaStr = @"1";
            }
            [node setStringValue: alphaStr];
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
        if([fontStyleName isEqualToString: @"PingFangSC-Regular"]) {
            [fontDescription m_setValue:@"PingFangSC-Regular" forKey:@"name"];
            [fontDescription m_setValue:@"PingFang SC" forKey:@"family"];
            
        } else if([fontStyleName isEqualToString: @"PingFangSC-Medium"]) {
            [fontDescription m_setValue:@"PingFangSC-Medium" forKey: @"name"];
            [fontDescription m_setValue:@"PingFang SC" forKey: @"family"];
            
        } else if([fontStyleName isEqualToString: @"PingFangSC-Semibold"]) {
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
@end
