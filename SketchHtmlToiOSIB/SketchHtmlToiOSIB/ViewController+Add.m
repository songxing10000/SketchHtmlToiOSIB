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

- (NSXMLElement *)rootElementWithXmlFileName:(NSString *)xmlFileName {
    return (NSXMLElement *)[self documentWithXmlFileName:xmlFileName].rootElement;
}
- (NSXMLDocument *)documentWithXmlFileName:(NSString *)xmlFileName {
    
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
- (NSString *)getHtmlFilePathFromPath:(NSString *)htmlFilePath {
    BOOL isDir = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL fileExists = [fm fileExistsAtPath:htmlFilePath isDirectory:&isDir];
    if (!fileExists) {
        NSLog(@"文件不存在 %@", htmlFilePath);
        return nil;
    }
    NSString *rightHtmlFilePath = htmlFilePath.mutableCopy;
    if (isDir) {
        /// 尝试查找传入文件夹内的 index.html
        // 获得当前文件夹path下面的所有内容（文件夹、文件）
        NSError *error = nil;
        NSArray<NSString *> *fileNames = [fm contentsOfDirectoryAtPath:htmlFilePath error:&error];
        if (error) {
            NSLog(@"出错了 %@", error);
            return nil;
        }
        /// 目标文件名
        NSString *desFileName = @"index.html";
        fileExists = [fileNames containsObject: desFileName];
        if (fileExists) {
            rightHtmlFilePath = [htmlFilePath stringByAppendingPathComponent:@"index.html"];
            return rightHtmlFilePath;
        }
    } else {
        if (![[htmlFilePath pathExtension] isEqualToString:@"html"]) {
            NSLog(@"应该传入html文件");
            return nil;
        }
    }
    return rightHtmlFilePath;
}
- (NSString *)jsonStrWithHtmlFileAtPath:(NSString *)htmlFilePath {
    
    NSString *rightHtmlFilePath = [self getHtmlFilePathFromPath:htmlFilePath];
    if(!rightHtmlFilePath) {
        NSLog(@"没找到html文件在路径 %@",htmlFilePath);
        return nil;
    }
    NSString *text = [NSString stringWithContentsOfFile:rightHtmlFilePath encoding:NSUTF8StringEncoding error:nil];
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
    return subString ;
}

- (void)createSBFileAtPath:(NSString *)sbDesPath withObj:(NBSKObject *)object {
    if (!sbDesPath || !object) {
        return;
    }
    NSXMLDocument *sbDocument = [self documentWithXmlFileName:@"sb"];
    
    NSXMLElement *scenes =
    [self getFirstElementByName:@"scenes" FromElement:sbDocument.rootElement];
    [self.hud show:YES];
    for (ArtboardsItem *vc in object.artboards) {
        NSXMLElement *vcElement = [self getNewVCElement];
        NSArray <SKLayer *> *views = vc.layers;
        for (SKLayer *view in views) {
            
            if (!view.objectID) {
                continue;
            }
            if (view.rect.x.intValue <= 16 &&
                view.rect.y.intValue <= 36 &&
                view.rect.width.intValue <= 9 &&
                view.rect.height.intValue <= 26 ) {
                /// 不添加把返回按钮
                continue;
            } else if (view.rect.y.intValue < 20 &&
                       view.rect.height.intValue <= 20 ) {
                // 不添加状态栏上的控件
                continue;
            }
            /// 控件类别 text为lable， slice为图片，shape为view
            NSString *viewType = view.type;
            NSXMLElement *subViewElement;
            NSString *vcTitle;
#pragma mark - UILabel
            if ([viewType isEqualToString:@"text"]) {
                NSXMLElement *labelElement = [self getNewlabelElement];
                [self setRect:view.rect forElement:labelElement];
                [self setText:view.content forLableElement:labelElement];
                //                [self setText:view.textAlign ForElement:labelElement];
                [self setPointSize:view.fontSize forLabelElement:labelElement];
                [self setTextColor:view.color.uiColor forLabelElement:labelElement];
                
                if ([view.rect.y isEqualToString: @"30"]||
                    [view.rect.y isEqualToString: @"31"]) {
                    //可能是标题
                    vcTitle = view.content;
                }
                /// 字的正常、中等、粗
                [self setTextRegularMediumBold:view.fontFace forLabelElement:labelElement];
                subViewElement = labelElement;
            }else if ([viewType isEqualToString:@"slice"]) {//图片
#pragma mark - UIImageView
                
                NSXMLElement *imgElement = [self getNewImageViewElement];
                [self setRect:view.rect forElement:imgElement];
                // image="fff.png"
                subViewElement = imgElement;
                
            }else if ([viewType isEqualToString:@"shape"]) {//view
#pragma mark - UIView
                
                NSXMLElement *viewElement = [self getNewViewElement];
                [self setRect:view.rect forElement:viewElement];
                if (view.fills && view.fills.count > 0) {
                    
                    [self setBgColor:view.fills[0].color.uiColor forViewElement:viewElement];
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
                [self setLable:vcTitle forVCElement:vcElement];
            } else {
                [self setLable:vc.name forVCElement:vcElement];
            }
            if (subViewElement) {
                
                [self addSubviewElement:subViewElement inVCElement:vcElement fromSbDocument:sbDocument];
            }
        }
        [scenes addChild: vcElement];
        self.hud.progress = (scenes.childCount+1)/(object.artboards.count+1);
        self.hud.labelText = [NSString stringWithFormat:@"%tu/%tu",scenes.childCount,object.artboards.count];
        if (scenes.childCount == object.artboards.count) {
            NSLog(@"----%@---", @"写入完成");
            [[NSWorkspace sharedWorkspace] selectFile:sbDesPath inFileViewerRootedAtPath:sbDesPath];

            [[NSWorkspace sharedWorkspace] openFile:sbDesPath withApplication:@"Xcode"];
        }
    
    }
    
    [self saveXMLDoucment:sbDocument toPath:sbDesPath];
    [self.hud hide:YES];
    
}
/// 输出storyboard
- (BOOL)saveXMLDoucment:(NSXMLDocument *)XMLDoucment toPath:(NSString *)destPath {
    
    if (XMLDoucment == nil) {
        return NO;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL fileExist = [fm fileExistsAtPath:destPath];
    if ( fileExist) {
        [fm removeItemAtPath:destPath error:nil];
    } else {
        if ( ![fm createFileAtPath:destPath contents:nil attributes:nil]){
            NSLog(@"创建文件失败 %@", destPath);
            return NO;
        }
    }
    
    NSData *XMLData = [XMLDoucment XMLDataWithOptions:NSXMLNodePrettyPrint];
    if (![XMLData writeToFile:destPath atomically:YES]) {
        NSLog(@"Could not write document out...");
        return NO;
    }
    return YES;
}
#pragma mark - get view add view

- (void)addSubviewElement:(NSXMLElement *)subViewElement inVCElement:(NSXMLElement *)vcElement fromSbDocument:(NSXMLDocument *)sbDocument{
    if (!subViewElement) {
        NSLog(@"未找到 %@", subViewElement);
        return;
    }
    if (!vcElement) {
        NSLog(@"未找到 %@", vcElement);
        return;
    }
    NSXMLElement *object = [self getFirstElementByName:@"objects" FromElement:vcElement];
    NSXMLElement *vc = [self getFirstElementByName:@"viewController" FromElement:object];
    NSXMLElement *view = [self getFirstElementByName:@"view" FromElement:vc];
    NSXMLElement *subViewSuperView = [self getFirstElementByName:@"subviews" FromElement:view];
    /// 限制加入子控件的个数
//    if (subViewSuperView.childCount > 80) {
        if ([subViewElement.name isEqualToString:@"label"]) {
            NSString *labelText = [subViewElement attributeForName:@"text"].stringValue;
            NSNumber *preCount = self.labelCountDict[labelText];
            if (!preCount || [preCount isEqual:@0]) {
                self.labelCountDict[labelText] = @1;
            } else {
                self.labelCountDict[labelText] = @(preCount.intValue + 1);
            }
            if (self.labelCountDict[labelText].intValue > 80) {
                NSLog(@"--%@--%@---", @"添加太多一样的label了", labelText);
                return;
            }
        }
//    }
    
    [subViewSuperView addChild:subViewElement];
/// 暂不处理图片信息
    return;
    if ([subViewElement.name isEqualToString:@"imageView"]) {
        //如果添加imageView 得<image name="fff.png" width="16" height="16"/>
        
        NSXMLElement *imageNode = [NSXMLElement elementWithName:@"image"];
        NSString *imgName = [subViewElement attributeForName:@"image"].stringValue;
        
        if (imgName && imgName.length > 0) {
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"name" stringValue: imgName]];
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"width" stringValue:@"16"]];
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"height" stringValue:@"16"]];
            NSXMLElement *resources =
            [self getFirstElementByName:@"resources" FromElement:sbDocument.rootElement];
            [resources addChild:imageNode.copy];
        }
    }
}
- (NSXMLElement *)getNewVCElement {
    NSXMLElement *vcElement = [self rootElementWithXmlFileName:@"vc"];
    [self setRandomIdForElement:vcElement];
    NSXMLElement *objects = [self getFirstElementByName:@"objects" FromElement:vcElement];
    NSXMLElement *placeholder = [self getFirstElementByName:@"placeholder" FromElement:objects];
    [self setRandomIdForElement:placeholder];
    
    NSXMLElement *viewController = [self getFirstElementByName:@"viewController" FromElement:objects];
    [self setRandomIdForElement:viewController];
    
    
    NSXMLElement *view = [self getFirstElementByName:@"view" FromElement:viewController];
    [self setRandomIdForElement:view];
    NSXMLElement *viewLayoutGuide = [self getFirstElementByName:@"viewLayoutGuide" FromElement:view];
    [self setRandomIdForElement:viewLayoutGuide];
    
    return vcElement.copy;
}
- (NSXMLElement *)getNewlabelElement {
    NSXMLElement *lableElement = [self rootElementWithXmlFileName:@"label"];
    [self setRandomIdForElement:lableElement];
    return lableElement.copy;
}
- (NSXMLElement *)getNewImageViewElement {
    NSXMLElement *imgVElement = [self rootElementWithXmlFileName:@"imgV"];
    [self setRandomIdForElement:imgVElement];
    return imgVElement.copy;
}
- (NSXMLElement *)getNewViewElement {
    NSXMLElement *viewElement = [self rootElementWithXmlFileName:@"view"];
    [self setRandomIdForElement:viewElement];
    return viewElement.copy;
}
- (void)setRandomIdForElement:(NSXMLElement *)element {
    NSArray<NSXMLNode *> *nodes = element.attributes;
    NSString *name = [element.name isEqualToString:@"scene"]?@"sceneID":@"id";
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: name]) {
            [node setStringValue:[self randomid]];
        }
    }
}




- (NSXMLElement *)getFirstElementByName:(NSString *)elementName FromElement:(NSXMLElement *)element {
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
- (void)setRect:(SKRect *)rect forElement:(NSXMLElement *)element{
    NSXMLElement *rectElement = [self getFirstElementByName:@"rect" FromElement:(NSXMLElement *)element];
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
-(void)setText:(NSString *)text forLableElement:(NSXMLElement *)element{
    NSString *key = @"text";
    [self setValue: text forKey: key forElement: element];
}
-(void)setAlpha:(NSString *)alpha ForElement:(NSXMLElement *)element{
    if ([alpha isEqualToString:@"1"]) {
        return;
    }
    NSString *key = @"alpha";
    [self setValue:alpha forKey:key forElement:element];
}


-(void)setTextAlign:(NSString *)textAlign forLabelElement:(NSXMLElement *)element{
    #pragma mark - to do
    __unused NSString *key = @"textAlignment";
//    [self setValue:textAlign forKey:key forElement:element];
}
- (void)setPointSize:(NSString *)pointSize forLabelElement:(NSXMLElement *)element{
    NSString *input = pointSize;
    BOOL hasValue = input && input.length > 0;
    if (!hasValue) {
        return;
    }
    NSXMLElement *fontDescription = [self getFirstElementByName:@"fontDescription" FromElement:(NSXMLElement *)element];
    NSString *key = @"pointSize";
    [self setValue:pointSize forKey:key forElement:fontDescription];
}
-(void)setColor:(NSString *)textColor type:(NSString *)type ForElement:(NSXMLElement *)element {
    NSString *input = textColor;
    BOOL hasValue = input && input.length > 0;
    if (!hasValue) {
        return;
    }
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
-(void)setTextColor:(NSString *)textColor forLabelElement:(NSXMLElement *)element {
    [self setColor:textColor type:@"textColor" ForElement:element];
}

-(void)setBgColor:(NSString *)viewBgColor forViewElement:(NSXMLElement *)element {
    [self setColor:viewBgColor type:@"backgroundColor" ForElement:element];
    
}
-(void)setViewCss:(NSArray <NSString *> *)css ForElement:(NSXMLElement *)element {
#pragma mark - to do
    // ["border: 1px solid #295DFD;","border-radius: 4px;"]
    [css enumerateObjectsUsingBlock:^(NSString * _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([str hasPrefix:@"border:"]) {
            
        } else if ([str hasPrefix:@"border-radius:"]) {
            
        }
    }];
}
-(void)setLable:(NSString *)text forVCElement:(NSXMLElement *)element {
    NSString *input = text;
    BOOL hasValue = input && input.length > 0;
    if (!hasValue) {
        return;
    }
    NSXMLElement *objects =  [self getFirstElementByName:@"objects" FromElement:element];
    NSXMLElement *viewController =  [self getFirstElementByName:@"viewController" FromElement:objects];
    
    NSString *key = @"userLabel";
    [self setValue:text forKey:key forElement:viewController];
}
- (void)setValue:(NSString *)value forKey:(NSString *)key  forElement:(NSXMLElement *)element {
    if (!key || !value || !element) {
        return;
    }
    BOOL hasKey = [element attributeForName: key].name.length;
    if (hasKey) {
        NSString *valueStr = [element attributeForName: key].stringValue;
        if ([value isEqualToString:valueStr]) {
            return;
        }
        [element setAttributesAsDictionary: @{key:value}];
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

- (NSDictionary *)dicWithJsonStr:(NSString *)jsonString{
    if (!jsonString) {
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
- (void)setTextRegularMediumBold:(NSString *)style forLabelElement:(NSXMLElement *)labelElement {
    NSString *fontStyleName = style;
    if (fontStyleName && fontStyleName.length > 0) {
        NSString *regularStr = @"Regular";
        NSString *mediumStr = @"Medium";
        NSString *boldStr = @"Bold";
        if([fontStyleName hasSuffix: regularStr]) {
            fontStyleName = regularStr;
            /// 默认就是system，不用再次设置
            // <fontDescription key="fontDescription" type="system" pointSize="13"/>
            //            NSXMLElement *fontDescription = [self getFirstElementByName:@"fontDescription" FromElement:labelElement];
            //            [self setValue:@"system" forKey:@"type" forElement:fontDescription];
        } else  if([fontStyleName hasSuffix: mediumStr]) {
            fontStyleName = mediumStr;
        } else if([fontStyleName hasSuffix: boldStr]) {
            fontStyleName = boldStr;
            // <fontDescription key="fontDescription" type="boldSystem" pointSize="13"/>
            NSXMLElement *fontDescription = [self getFirstElementByName:@"fontDescription" FromElement:labelElement];
            [self setValue:@"boldSystem" forKey:@"type" forElement:fontDescription];
        }
    }
}
@end
