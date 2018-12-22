//
//  ViewController+Add.m
//  SketchHtmlToiOSIB
//
//  Created by dfpo on 2018/12/22.
//  Copyright © 2018 dfpo. All rights reserved.
//

#import "ViewController+Add.h"

@implementation ViewController (Add)
- (NSXMLElement *)getFirstElementName:(NSString *)elementName FromElement:(NSXMLElement *)element {
    NSArray<NSXMLElement *> *elements = (NSArray<NSXMLElement *> *)[element elementsForName:elementName];
    if (elements.count >= 1) {
        return elements[0];
    }
    /*
     
     
     */
    NSLog(@"未找到 %@，创建空的", elementName);
    NSXMLElement *add = [NSXMLElement elementWithName:elementName];
    [element addChild:add.copy];
    return add ;
}
- (void)setRect:(SKRect *)rect ForElement:(NSXMLElement *)element{
    NSXMLElement *rectElement = [self getFirstElementName:@"rect" FromElement:(NSXMLElement *)element];
    NSArray<NSXMLNode *> *nodes = rectElement.attributes;
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"x"]) {
            [node setStringValue: rect.x];
        } else if ([node.name isEqualToString: @"y"]) {
            [node setStringValue: rect.y];
        } else if ([node.name isEqualToString: @"width"]) {
            [node setStringValue: rect.width];
            if ([element.name isEqualToString:@"label"]) {
                NSString *fixW = @(rect.width.integerValue+4).stringValue;
                [node setStringValue: fixW];
            }
        } else if ([node.name isEqualToString: @"height"]) {
            [node setStringValue: rect.height];
        }
    }
}
-(void)setText:(NSString *)text ForElement:(NSXMLElement *)element{
    
    NSArray<NSXMLNode *> *nodes = element.attributes;
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"text"]) {
            [node setStringValue: text];
        }
    }
}
-(void)setAlpha:(NSString *)alpha ForElement:(NSXMLElement *)element{
    if ([alpha isEqualToString:@"1"]) {
        return;
    }
    NSString *key = @"alpha";
    [self setValue:alpha forKey:key forElement:element];
}


-(void)setTextAlign:(NSString *)textAlign ForElement:(NSXMLElement *)element{
    
    NSArray<NSXMLNode *> *nodes = element.attributes;
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"textAlignment"]) {
//            [node setStringValue: text];
#pragma mark - to do
        }
    }
}
- (void)setPointSize:(NSString *)pointSize ForElement:(NSXMLElement *)element{
    NSXMLElement *rectElement = [self getFirstElementName:@"fontDescription" FromElement:(NSXMLElement *)element];
    NSArray<NSXMLNode *> *nodes = rectElement.attributes;
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"pointSize"]) {
            [node setStringValue: pointSize];
        }
    }
}
-(void)setColor:(NSString *)textColor type:(NSString *)type ForElement:(NSXMLElement *)element {
    NSArray<NSXMLElement *> *elements = (NSArray<NSXMLElement *> *)[element elementsForName:@"color"];
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
        } else if ([node.name isEqualToString: @"realphad"]) {
            [node setStringValue: rgba[3]];
        }
        
    }
}
-(void)setTextColor:(NSString *)textColor ForElement:(NSXMLElement *)element {
    [self setColor:textColor type:@"textColor" ForElement:element];
}
-(void)setviewBgColor:(NSString *)viewBgColor ForElement:(NSXMLElement *)element {
    if (!viewBgColor) {
        return;
    }
    [self setColor:viewBgColor type:@"backgroundColor" ForElement:element];

}
-(void)setViewCss:(NSArray <NSString *> *)css ForElement:(NSXMLElement *)element {
    // ["border: 1px solid #295DFD;","border-radius: 4px;"]
    [css enumerateObjectsUsingBlock:^(NSString * _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([str hasPrefix:@"border:"]) {
            
        } else if ([str hasPrefix:@"border-radius:"]) {
            
        }
    }];
}
-(void)setVCLable:(NSString *)text ForElement:(NSXMLElement *)element {
    NSXMLElement *objects =  [self getFirstElementName:@"objects" FromElement:element];
     NSXMLElement *viewController =  [self getFirstElementName:@"viewController" FromElement:objects];
    
    NSString *key = @"userLabel";
    [self setValue:text forKey:key forElement:viewController];
}
- (void)setValue:(NSString *)value forKey:(NSString *)key  forElement:(NSXMLElement *)element {
    if (!key || !value) {
        return;
    }
    BOOL hasAlphaKey = [element attributeForName: key].name.length;
    NSDictionary *alphaDic = @{key:value};
    if (hasAlphaKey) {
        [element setAttributesAsDictionary: alphaDic];
    } else {
        [element addAttribute:[NSXMLNode attributeWithName:key stringValue: value]];
    }
}

@end
