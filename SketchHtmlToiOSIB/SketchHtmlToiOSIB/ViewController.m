//
//  ViewController.m
//  SketchHtmlToiOSIB
//
//  Created by dfpo on 2018/12/22.
//  Copyright © 2018 dfpo. All rights reserved.
//

#import "ViewController.h"
#import "NBSKObject.h"
#import "ViewController+Add.h"




@implementation ViewController
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
- (void)readTempXml {
    
    NSXMLDocument *sbDocument = [self loadTemplateDocumentFromXmlFileName:@"sb"];
    NSXMLElement *vcElement = [self getVcElement];
    NSXMLElement *labelElement = [self getlabelElement];
    NSXMLElement *viewElement = [self getViewElement];
    NSXMLElement *imgVElement = [self getImgVElement];
    
    
    NSXMLElement *scenes =
    [self getFirstElementName:@"scenes" FromElement:sbDocument.rootElement];
    
    // 考虑 sceneID id 重复
    // 往vc追加控件
    [self addSubview:labelElement inVC:vcElement fromSb:sbDocument];
    
    [self addSubview:viewElement inVC:vcElement fromSb:sbDocument];
    
    [self addSubview:imgVElement inVC:vcElement fromSb:sbDocument];
    // 往sb追加vc
    [scenes addChild:vcElement];
    
    //    [scenes addChild:[self getVcElement]];
    //    [scenes addChild:[self getVcElement]];
    
    NSString *storyboardDestPath = @"/Users/dfpo/Downloads/temp.storyboard";
    [self saveXMLDoucment:sbDocument toPath:storyboardDestPath];
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
#pragma mark - 解析html

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
- (void)readHtml {
    
    NSString *htmlFilePath = @"/Users/dfpo/Downloads/222/index.html";
    NSString *text = [NSString stringWithContentsOfFile:htmlFilePath encoding:NSUTF8StringEncoding error:nil];
    NSString *startStr = @"SMApp(";
    NSUInteger start = [text rangeOfString: startStr].location;
    if (start == NSNotFound) {
        NSLog(@"未找到标准的数据");
        return;
    }
    start += startStr.length;
    NSString *endStr = @") });";
    NSUInteger end = [text rangeOfString: endStr options:(NSLiteralSearch|NSBackwardsSearch) range:NSMakeRange(start, text.length - start)].location;
    if (end == NSNotFound) {
        NSLog(@"结束标志");
        return;
    }
    NSString *subString = [text substringWithRange:NSMakeRange(start, end - start)];
    [self createSbDocumentFromObj:[NBSKObject objWithJSON:subString] ];
}
- (void)createSbDocumentFromObj:(NBSKObject *)object {
    NSXMLDocument *sbDocument = [self loadTemplateDocumentFromXmlFileName:@"sb"];
    
    NSXMLElement *scenes =
    [self getFirstElementName:@"scenes" FromElement:sbDocument.rootElement];
    
    for (ArtboardsItem *vc in object.artboards) {
        NSXMLElement *vcElement = [self getVcElement];
        NSArray <SKLayer *> *views = vc.layers;
        for (SKLayer *view in views) {
            
            if (!view.objectID) {
                continue;
            }
            if (view.rect.x.intValue <= 16 &&
                view.rect.y.intValue <= 36 &&
                view.rect.height.intValue <= 20 ) {
                /// zt
                continue;
            }
            if (view.rect.y.intValue < 20 &&
                view.rect.height.intValue <= 20 ) {
                /// zt
                continue;
            }
            if (view.rect.width.intValue <= 343 &&
                view.rect.height.intValue <= 127 ) {
                /// zt
                NSLog(@"----%@---", @"f");
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
                [self setVCLable:vcTitle ForElement:vcElement];
            } else {
                [self setVCLable:vc.name ForElement:vcElement];

            }
            if (subViewElement) {
                [self addSubview:subViewElement inVC:vcElement fromSb:sbDocument];
                
            }
        }
        [scenes addChild: vcElement];
    }




//    NSXMLElement *vcElement = [self getVcElement];
//    NSXMLElement *labelElement = [self getlabelElement];
//    NSXMLElement *viewElement = [self getViewElement];
//    NSXMLElement *imgVElement = [self getImgVElement];
// 往vc追加控件
//    [self addSubview:labelElement inVC:vcElement fromSb:sbDocument];
//
//    [self addSubview:viewElement inVC:vcElement fromSb:sbDocument];
//
//    [self addSubview:imgVElement inVC:vcElement fromSb:sbDocument];
// 往sb追加vc
//    [scenes addChild:vcElement];

//    [scenes addChild:[self getVcElement]];
//    [scenes addChild:[self getVcElement]];

    NSString *storyboardDestPath = @"/Users/dfpo/Downloads/temp.storyboard";
    [self saveXMLDoucment:sbDocument toPath:storyboardDestPath];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self readHtml];
    //    [self readTempXml];
    
    return;
    NSError *error = nil;
    
    NSString *filePath = @"/Users/dfpo/Downloads/Main.storyboard";
    NSData *xmlData = [NSData dataWithContentsOfFile:filePath options: 0 error: &error];
    if (error) {
        NSLog(@"error = %@",error);
        return;
    }
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:xmlData options:NSXMLNodePreserveWhitespace error:&error];
    NSXMLElement *rootElement = document.rootElement;
    if (error) {
        NSLog(@"error = %@",error);
    }
    for (NSXMLElement *subElement in rootElement.children) {
        if ([subElement.name isEqualToString:@"scenes"]) {
            // 所有的控制器
            /*
             <scenes>
             <!--View Controller-->
             <scene sceneID="tne-QT-ifu">
             </scene>
             */
            for (NSXMLElement *subElement in rootElement.children) {
                if ([subElement.name isEqualToString:@"scene"]) {
                    /// 每个控制器
                }
            }
        } else {
            if ([subElement.name isEqualToString:@"resources"]) {
                // 图片资源,index.html同级的assets文件夹内存在所有文件夹
                // 不过有可能，有些本来应该切图的， 美工没切，assets内就没有
                /*
                 <resources>
                 <image name="fff.png" width="16" height="16"/>
                 </resources>
                 */
                
            }
        }
    }
}

// 修改 并返回结果
//- (void)modifyColorModel:(WDColorModel *)objColorModel {
//
//        NSData *xmlData = [NSData dataWithContentsOfFile:filePath];
//        NSXMLDocument *document = [self parsedDataFromData:xmlData colorModel:objColorModel];
//        // 存储新的
//        BOOL result = [self saveXMLFile:filePath xmlDoucment:document];
//        if (!result) {
//            NSLog(@"修改之后，文件保存失败！。。。");
//        }
//}

// 获取 XMLDocument
//- (NSXMLDocument *)parsedDataFromData:(NSData *)data colorModel:(WDColorModel *)objColorModel {
//
//    NSError *error = nil;
//    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data options:NSXMLNodePreserveWhitespace error:&error];
//    NSXMLElement *rootElement = document.rootElement;
//    [self parsedXMLElement:rootElement objColorModel:objColorModel];
//
//    if (error) {
//        NSLog(@"error = %@",error);
//    }
//    return document;
//}

// 修改元素
//- (void)parsedXMLElement:(NSXMLElement *)element objColorModel:(WDColorModel *)objColorModel {
//    for (NSXMLElement *subElement in element.children) {
//        if ([subElement.name isEqualToString:@"color"]) {
//            WDColorModel *obj = [WDColorModel colorModelWithArray:subElement.attributes];
//            if ([obj isEqual:self.targetColorModel]) {
//                [self updateXMLNodelWithNode:subElement color:objColorModel];
//            }
//        }
//        [self parsedXMLElement:subElement objColorModel:objColorModel];
//    }
//}

// 更新 NSXMLElement
//- (void)updateXMLNodelWithNode:(NSXMLElement *)subElement color:(WDColorModel *)obj {
//    self.modifiedNum++;
//
//    NSArray *array = subElement.attributes;
//    for (NSXMLNode *node in array) {
//        if ([node.name isEqualToString:@"red"]) {
//            [node setStringValue:obj.red];
//        }
//        else if ([node.name isEqualToString:@"green"]) {
//            [node setStringValue:obj.green];
//        }
//        else if ([node.name isEqualToString:@"blue"]) {
//            [node setStringValue:obj.blue];
//        }
//    }
//}

// 创建新的 NSXMLElement
//- (NSXMLElement *)creatXMLNodel:(WDColorModel *)obj {
//
//    NSXMLElement *subNode = [NSXMLElement elementWithName:@"color"];
//    [subNode addAttribute:[NSXMLNode attributeWithName:@"key" stringValue:obj.key]];
//    [subNode addAttribute:[NSXMLNode attributeWithName:@"red" stringValue:obj.red]];
//    [subNode addAttribute:[NSXMLNode attributeWithName:@"green" stringValue:obj.green]];
//    [subNode addAttribute:[NSXMLNode attributeWithName:@"blue" stringValue:obj.blue]];
//    [subNode addAttribute:[NSXMLNode attributeWithName:@"alpha" stringValue:obj.alpha]];
//    [subNode addAttribute:[NSXMLNode attributeWithName:@"colorSpace" stringValue:obj.colorSpace]];
//
//    if (obj.customColorSpace.length > 0) {
//        // Xcode8 以后
//        [subNode addAttribute:[NSXMLNode attributeWithName:@"customColorSpace" stringValue:obj.customColorSpace]];
//    }
//    return subNode;
//}


@end

