//
//  ViewController+Add.m
//  SketchHtmlToiOSIB
//
//  Created by dfpo on 2018/12/22.
//  Copyright © 2018 dfpo. All rights reserved.
//

#import "ViewController+Add.h"
@implementation ViewController (Add)
#pragma mark - read save xml

- (NSXMLElement *)loadTemplateRootElementWithXmlFileName:(NSString *)xmlFileName {
    return (NSXMLElement *)[self loadTemplateDocumentFromXmlFileName:xmlFileName].rootElement;
}
- (NSXMLDocument *)loadTemplateDocumentFromXmlFileName:(NSString *)xmlFileName {
    
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
- (NBSKObject *)readHtmlAtPath:(NSString *)htmlFilePath {
    
    NSString *text = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *startStr = @"SMApp(";
    NSUInteger start = [text rangeOfString: startStr].location;
    if (start == NSNotFound) {
        NSLog(@"未找到标准的数据");
        return nil;
    }
    start += startStr.length;
    NSString *endStr = @") });";
    NSUInteger end = [text rangeOfString: endStr options:(NSLiteralSearch|NSBackwardsSearch) range:NSMakeRange(start, text.length - start)].location;
    if (end == NSNotFound) {
        NSLog(@"结束标志");
        return nil;
    }
    NSString *subString = [text substringWithRange:NSMakeRange(start, end - start)];
    return [NBSKObject objWithJSON:subString] ;
}

- (void)createSbDesPathAt:(NSString *)sbDesPath fromObj:(NBSKObject *)object {
    
    NSXMLDocument *sbDocument = [self loadTemplateDocumentFromXmlFileName:@"sb"];
    
    NSXMLElement *scenes =
    [self getFirstElementName:@"scenes" FromElement:sbDocument.rootElement];
    [self.hud show:YES];
    for (ArtboardsItem *vc in object.artboards) {
        NSXMLElement *vcElement = [self getVcElement];
        NSArray <SKLayer *> *views = vc.layers;
        for (SKLayer *view in views) {
            
            if (!view.objectID) {
                continue;
            }
            if (view.rect.x.intValue <= 16 &&
                view.rect.y.intValue <= 36 &&
                view.rect.width.intValue <= 9 &&
                view.rect.height.intValue <= 20 ) {
                /// 不添加把返回按钮
                continue;
            } else if (view.rect.y.intValue < 20 &&
                view.rect.height.intValue <= 20 ) {
                // 不添加状态栏上的控件
                continue;
            }
            NSString *viewType = view.type;
            NSXMLElement *subViewElement;
            NSString *vcTitle;
            if ([viewType isEqualToString:@"text"]) {
                NSXMLElement *labelElement = [self getlabelElement];
                [self setRect:view.rect ForElement:labelElement];
                [self setText:view.content ForElement:labelElement];
                //                [self setText:view.textAlign ForElement:labelElement];
                [self setPointSize:view.fontSize ForElement:labelElement];
                [self setTextColor:view.color.uiColor ForElement:labelElement];
                subViewElement = labelElement;
                if ([view.rect.y isEqualToString: @"31"]) {
                    //可能是标题
                    vcTitle = view.content;
                }
            }else if ([viewType isEqualToString:@"slice"]) {//图片
                NSXMLElement *imgElement = [self getImgVElement];
                [self setRect:view.rect ForElement:imgElement];
                // image="fff.png"
                subViewElement = imgElement;
                
            }else if ([viewType isEqualToString:@"shape"]) {//view
                
                NSXMLElement *viewElement = [self getViewElement];
                [self setRect:view.rect ForElement:viewElement];
                if (view.fills && view.fills.count > 0) {
                    
                    [self setviewBgColor:view.fills[0].color.uiColor ForElement:viewElement];
                }
                if (view.css && view.css.count > 0) {
                    [self setViewCss:view.css ForElement:viewElement];
                }
                subViewElement = viewElement;
                
            } else {
                NSLog(@"--未知类型--%@---", viewType);
            }
            if (view.opacity) {
                [self setAlpha:view.opacity ForElement:subViewElement];
            }
            if (vcTitle) {
                [self setVCLable:vcTitle forVCElement:vcElement];
            } else {
                [self setVCLable:vc.name forVCElement:vcElement];
                
            }
            if (subViewElement) {
                
                    [self addSubview:subViewElement inVC:vcElement fromSb:sbDocument];
                
                
            }
        }
        [scenes addChild: vcElement];
        self.hud.progress = scenes.childCount/object.artboards.count;
        self.hud.labelText = [NSString stringWithFormat:@"%tu/%tu",scenes.childCount,object.artboards.count];
    }
    
    [self saveXMLDoucment:sbDocument toPath:sbDesPath];
    [self.hud hide:YES];

}
/// 输出storyboard
- (BOOL)saveXMLDoucment:(NSXMLDocument *)XMLDoucment toPath:(NSString *)destPath {
    
    if (XMLDoucment == nil) {
        return NO;
    }
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        if ( ![[NSFileManager defaultManager] createFileAtPath:destPath contents:nil attributes:nil]){
            return NO;
        }
    }
    
    NSData *XMLData = [XMLDoucment XMLDataWithOptions:NSXMLNodePrettyPrint];
    if (![XMLData writeToFile:destPath atomically:YES]) {
        NSLog(@"Could not write document out...");
        return NO;
    }
    NSLog(@"输出成功：%@",destPath);
    
    return YES;
}
#pragma mark - get view add view

- (void)addSubview:(NSXMLElement *)subViewElement inVC:(NSXMLElement *)vcElement fromSb:(NSXMLDocument *)sbDocument{
    if (!subViewElement) {
        NSLog(@"未找到 %@", subViewElement);
        return;
    }
    if (!vcElement) {
        NSLog(@"未找到 %@", vcElement);
        return;
    }
    NSXMLElement *object = [self getFirstElementName:@"objects" FromElement:vcElement];
    NSXMLElement *vc = [self getFirstElementName:@"viewController" FromElement:object];
    NSXMLElement *view = [self getFirstElementName:@"view" FromElement:vc];
    NSXMLElement *subView = [self getFirstElementName:@"subviews" FromElement:view];
    [subView addChild:subViewElement];
    if ([subViewElement.name isEqualToString:@"imageView"]) {
        //如果添加imageView 得<image name="fff.png" width="16" height="16"/>
        
        NSXMLElement *resources =
        [self getFirstElementName:@"resources" FromElement:sbDocument.rootElement];
        NSXMLElement *imageNode = [NSXMLElement elementWithName:@"image"];
        NSString *imgName = [subViewElement attributeForName:@"image"].stringValue;
        if (imgName && imgName.length > 0) {
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"name" stringValue: imgName]];
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"width" stringValue:@"16"]];
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"height" stringValue:@"16"]];
            [resources addChild:imageNode.copy];
        }
        
        
    }
}
- (NSXMLElement *)getVcElement {
    NSXMLElement *vcElement = [self loadTemplateRootElementWithXmlFileName:@"vc"];
    [self setRandomIdFromElement:vcElement];
    NSXMLElement *objects = [self getFirstElementName:@"objects" FromElement:vcElement];
    NSXMLElement *placeholder = [self getFirstElementName:@"placeholder" FromElement:objects];
    [self setRandomIdFromElement:placeholder];
    
    NSXMLElement *viewController = [self getFirstElementName:@"viewController" FromElement:objects];
    [self setRandomIdFromElement:viewController];
    
    
    NSXMLElement *view = [self getFirstElementName:@"view" FromElement:viewController];
    [self setRandomIdFromElement:view];
    NSXMLElement *viewLayoutGuide = [self getFirstElementName:@"viewLayoutGuide" FromElement:view];
    [self setRandomIdFromElement:viewLayoutGuide];
    
    return vcElement.copy;
}
- (NSXMLElement *)getlabelElement {
    NSXMLElement *lableElement = [self loadTemplateRootElementWithXmlFileName:@"label"];
    [self setRandomIdFromElement:lableElement];
    return lableElement.copy;
}
- (NSXMLElement *)getImgVElement {
    NSXMLElement *imgVElement = [self loadTemplateRootElementWithXmlFileName:@"imgV"];
    [self setRandomIdFromElement:imgVElement];
    return imgVElement.copy;
}
- (NSXMLElement *)getViewElement {
    NSXMLElement *viewElement = [self loadTemplateRootElementWithXmlFileName:@"view"];
    [self setRandomIdFromElement:viewElement];
    return viewElement.copy;
}
- (void)setRandomIdFromElement:(NSXMLElement *)element {
    NSArray<NSXMLNode *> *nodes = element.attributes;
    NSString *name = [element.name isEqualToString:@"scene"]?@"sceneID":@"id";
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: name]) {
            [node setStringValue:[self randomid]];
        }
    }
}




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
                /// 修复lable宽度，自动布局时，宽度自适应
                NSString *fixW = @(rect.width.integerValue+6).stringValue;
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
-(void)setVCLable:(NSString *)text forVCElement:(NSXMLElement *)element {
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
#pragma mark - id
-(NSString *)randomid {
    
    NSString *str1 = [self randomStrWithLength:3];
    NSString *str2 = [self randomStrWithLength:2];
    NSString *str3 = [self randomStrWithLength:3];
    return [@[str1, str2, str3] componentsJoinedByString:@"-"];
}
- (NSString *)randomStrWithLength:(NSUInteger)len {
    
    NSString * strAll = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSString * result = [[NSMutableString alloc]initWithCapacity:16];
    for (int i = 0; i < len; i++)
    {
        //获取随机数
        NSInteger index = arc4random() % (strAll.length-1);
        char tempStr = [strAll characterAtIndex:index];
        result = (NSMutableString *)[result stringByAppendingString:[NSString stringWithFormat:@"%c",tempStr]];
    }
    
    return result;
}
#pragma mark - other

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
