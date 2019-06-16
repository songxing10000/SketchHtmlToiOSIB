//
//  NSXMLElement+Add.m
//  SketchHtmlToiOSIB
//
//  Created by mac on 2019/6/16.
//  Copyright © 2019 dfpo. All rights reserved.
//

#import "NSXMLElement+Add.h"

@implementation NSXMLElement (Add)
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

- (void)setPointSize:(NSString *)pointSize {
    
    NSString *input = pointSize;
    BOOL hasValue = input && input.length > 0;
    if (!hasValue) {
        return;
    }
    NSXMLElement *fontDescription = [self firstElementByName:@"fontDescription"];
    NSString *key = @"pointSize";
    [fontDescription m_setValue:pointSize forKey:key];
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
@end
