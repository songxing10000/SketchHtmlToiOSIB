//
//  ViewController+Add.m
//  LanHuHtmlToiOSIB
//
//  Created by dfpo on 2018/12/22.
//  Copyright © 2018 dfpo. All rights reserved.
//

#import "ViewController+Add.h"
#import "NSXMLElement+Add.h"
#import "NSString+Add.h"

/**
 在路径创建文件夹
 
 @param folderFilePath 要创建的文件夹的全路径
 @param needRemoveOld 如果之前存在，需要删除老的不
 */
void createFolderAtPath(NSString *folderFilePath, BOOL needRemoveOld) {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isFileExists = [fm fileExistsAtPath: folderFilePath isDirectory: &isDir];
    if (isFileExists) {
        if (!isDir) {
            [fm createDirectoryAtPath:folderFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        } else {
            if (needRemoveOld) {
                [fm removeItemAtPath: folderFilePath error:nil];
                [fm createDirectoryAtPath: folderFilePath withIntermediateDirectories:YES attributes:nil error:nil];
            } else {
                
            }
        }
    } else {
        [fm createDirectoryAtPath:folderFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

/**
 复制文件到另一处
 
 @param copyFilePath 要复制的源文件
 @param filePath 要复制文件去哪个位置
 @param needRemoveOld 如果之前存在，需要删除老的不
 */
void copyFileToPath(NSString *copyFilePath, NSString *filePath, BOOL needRemoveOld) {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isFileExists = [fm fileExistsAtPath: filePath isDirectory: &isDir];
    if (isFileExists) {
        if (!isDir) {
            if (needRemoveOld) {
                [fm removeItemAtPath: filePath error:nil];
                [fm copyItemAtPath:copyFilePath toPath:filePath error:nil];
            } else {
                
            }
        } else {
            [fm copyItemAtPath:copyFilePath toPath:filePath error:nil];
        }
    } else {
        
        [fm copyItemAtPath:copyFilePath toPath:filePath error:nil];
    }
}

@implementation ViewController (Add)

- (NSString *)getHtmlFilePathFromPath:(NSString *)htmlFilePath {
    BOOL isDir = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL fileExists = [fm fileExistsAtPath:htmlFilePath isDirectory:&isDir];
    if (!fileExists) {
        NSLog(@"文件不存在 %@", htmlFilePath);
        return nil;
    }
    NSString *rightHtmlFilePath = htmlFilePath.mutableCopy;
    if (!isDir) {
        // 蓝湖的是 类似这种的，  *- 蓝湖.htm
        BOOL isLH = [htmlFilePath hasSuffix: @"蓝湖.htm"];
        if (!isLH) {
            if (![[htmlFilePath pathExtension] isEqualToString:@"html"] ||
                ![[htmlFilePath pathExtension] isEqualToString:@"htm"]) {
                NSLog(@"应该传入html文件");
                return nil;
            }
        }
    } else {
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
    BOOL isLH = [text containsString: @"https://lanhuapp.com"];
    NSString *startStr = isLH ? @"\">{" : @"SMApp(";
    NSUInteger start = [text rangeOfString: startStr].location;
    NSUInteger startLen = [text rangeOfString: startStr].length;
    
    if (start == NSNotFound) {
        if (isLH) {
            // 解析到的是蓝湖
            
        } else {
            NSLog(@"未找到标准的数据");
            return nil;
        }
    }
    if (startLen <= 0) {
        NSLog(@"未找到标准的数据");
        return  nil;
    }
    start += startStr.length;
    // }</span> <div
    NSString *endStr = isLH ? @"}</span> <div data" : @") });";
    NSUInteger end = [text rangeOfString: endStr options:(NSLiteralSearch|NSBackwardsSearch) range:NSMakeRange(start, text.length - start)].location;
    if (end == NSNotFound) {
        NSLog(@"结束标志");
        return nil;
    }
    NSString *subString = [text substringWithRange:NSMakeRange(start, end - start)];
    // 针对蓝湖
    // 首部加上 [
    // 尾部去除
    /*
     ,
     "isAsset": false,
     "isSlice": false,
     "web_id": 1,
     "multiple_checked": false,
     "skip_select": false
     }
     */
    if (isLH) {
        subString = [subString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        subString = [subString stringByReplacingOccurrencesOfString:@" " withString:@""];
        subString = [NSString stringWithFormat: @"{%@}", subString];
    }
    return subString ;
}

- (void)addSubViewElement:(NSXMLElement *)subViewElement subViewItem:(VisibleItem *)subViewItem inSuperViewElement:(NSXMLElement *)superViewElement fromSbDocument:(NSXMLDocument *)sbDocument{
    if (!subViewElement) {
        NSLog(@"未找到 %@", subViewElement);
        return;
    }
    if (!superViewElement) {
        NSLog(@"未找到 %@", superViewElement);
        return;
    }
    NSXMLElement *subViewSuperView = [superViewElement firstElementByName:@"subviews" ];
    
    
    [subViewSuperView addChild:subViewElement];
    
    if ([subViewElement.name isEqualToString:@"imageView"]) {
        //如果添加imageView 得<image name="fff.png" width="16" height="16"/>
        
        NSXMLElement *imageNode = [NSXMLElement elementWithName:@"image"];
        NSString *imgName = [subViewElement attributeForName:@"image"].stringValue;
        
        if (imgName && imgName.length > 0) {
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"name" stringValue: imgName]];
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"width" stringValue:@"16"]];
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"height" stringValue:@"16"]];
            NSXMLElement *resources =
            [sbDocument.rootElement firstElementByName:@"resources"];
            NSMutableArray<NSString *> *imgNames = [NSMutableArray array];
            for (NSXMLElement * obj in [resources children]) {
                [imgNames addObject: [obj m_getValueForKey:@"name"]];
            }
            
            if (![imgNames containsObject: imgName]) {
                [resources addChild:imageNode.copy];
            }
        }
    }
}


- (void)createSubViewWithViewItem:(VisibleItem *)viewItem  viewElement:(NSXMLElement *)viewElement  fromSbDocument:(NSXMLDocument *)sbDocument {
    if (!viewItem || !viewElement || viewItem.layers.count <= 0) {
        return;
    }
    
    [viewItem.layers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(VisibleItem * _Nonnull subViewItem, NSUInteger idx, BOOL * _Nonnull stop) {
       
        NSXMLElement *subViewElement = [NSXMLElement elementWithItem:subViewItem];
        // frame 转换
        _orgBounds *rightF = [_orgBounds new];
        rightF.top = labs(subViewItem.bounds.top- viewElement.skRect.top);
        rightF.left = labs(viewElement.skRect.left - subViewItem.bounds.left) ;
        rightF.bottom = subViewElement.skRect.bottom - subViewElement.skRect.top + rightF.top;
        rightF.right = subViewElement.skRect.right - subViewElement.skRect.left + rightF.left;
        
        subViewElement.skRect = rightF;
        
        [self addSubViewElement:subViewElement subViewItem:subViewItem inSuperViewElement:viewElement fromSbDocument: sbDocument];
        if (subViewItem.layers.count > 0) {
            [self createSubViewWithViewItem:subViewItem viewElement:subViewElement fromSbDocument:sbDocument];
        }
    }];
}
- (void)createSBFileAtPath:(NSString *)sbDesPath withObj:(NBSKObject *)object htmlFilePath:(NSString *)htmlFilePath {
    
    if (!sbDesPath || !object) {
        return;
    }
    
    NSXMLDocument *sbDocument = [NSXMLElement documentWithXmlFileName:@"sb"];
    NSXMLElement *vcElement = [NSXMLElement getNewVCElement];
    NSArray <VisibleItem *> *viewItems = object.visible;
    [self changeVCSizeForVCElement:vcElement vcViews:viewItems];
    
    for (VisibleItem *viewItem in viewItems) {
        NSXMLElement *viewElement = [NSXMLElement elementWithItem:viewItem];
        [self addSubviewElement: viewElement
                    inVCElement: vcElement
                 fromSbDocument: sbDocument];
        // 尝试生成viewElement的子控件
        [self createSubViewWithViewItem:viewItem viewElement:viewElement fromSbDocument:sbDocument];
    }
    NSXMLElement *scenes = [sbDocument.rootElement firstElementByName:@"scenes"];
    [scenes addChild: vcElement];
    
    NSLog(@"----%@---", @"写入完成");
    
    NSString *proFilePath = [sbDesPath stringByReplacingOccurrencesOfString:@".storyboard" withString:@".xcodeproj"];
    NSString *copyToFolderFilePath = [sbDesPath stringByReplacingOccurrencesOfString:@"temp.storyboard" withString:@"temp.xcassets/temp"];
    [[NSFileManager defaultManager] removeItemAtPath: copyToFolderFilePath error: nil];
    // 在桌面生成temp.xcodeproj临时工程关联temp.storyboard和temp.xcassets
    [self createTempProjectAtPath: proFilePath basisSBFileAtPath: sbDesPath htmlFilePath: htmlFilePath];
    // 生成json
    [self createJSONFileInImagesetFromCopyToFolderFilePath: copyToFolderFilePath];
    
    [self saveXMLDoucment:sbDocument toPath:sbDesPath];
    
    // 打开临时工程
    [[NSWorkspace sharedWorkspace] selectFile:proFilePath inFileViewerRootedAtPath:proFilePath];
    [[NSWorkspace sharedWorkspace] openFile:proFilePath withApplication:@"Xcode"];
}

/**
 根据创建sb文件的位置，创建temp.xcodeproj文件和temp.xcassets文件
 
 @param proFilePath 在哪个位置创建temp.xcodeproj文件
 @param sbDesPath sb文件创建的位置
 @param htmlFilePath 输入的html文件的位置，会根据此位置抓取图片至temp.xcassets文件，生成对应JSON描述文件
 */
- (void)createTempProjectAtPath:(NSString *)proFilePath basisSBFileAtPath:(NSString *)sbDesPath htmlFilePath:(NSString *)htmlFilePath  {
    
    createFolderAtPath(proFilePath, NO);
    
    // move file
    NSString *fil1Path = [[NSBundle mainBundle] pathForResource: @"project"
                                                         ofType:@"pbxproj"];
    NSString *path1 = [proFilePath stringByAppendingPathComponent: @"project.pbxproj"];
    NSString *path1Content =
    [NSString stringWithContentsOfFile:fil1Path encoding:NSUTF8StringEncoding error:nil];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:path1 error: nil];
    NSError *error;
    [path1Content writeToFile:path1 atomically:YES encoding:NSUTF8StringEncoding error: &error];
    if(error != nil) {
        NSLog(@"---%@---", error.localizedDescription);
    }
    
    // 生成图片夹
    
    
    
    //            NSString *htmlFileName = @"index.html";
    //            NSString *htmlFilePath = [NSString stringWithFormat: @"/Users/mac/Desktop/f/%@", htmlFileName];
    NSString *assetsFileName = @"assets";
    NSString *assetsFilePath =
    [htmlFilePath stringByReplacingOccurrencesOfString: @"index.html" withString: assetsFileName];
    // Spec Export - Sketch Measure 2.3.html
    if (![htmlFilePath containsString: @"index.html"]) {
        assetsFilePath =
        [htmlFilePath stringByReplacingOccurrencesOfString: @".html" withString: @"_files"];
    }
    BOOL isDir = NO;
    BOOL hasThisFolder =
    [fm fileExistsAtPath: assetsFilePath isDirectory: &isDir] && isDir ;
    if (!hasThisFolder) {
        return ;
    }
    NSString *copyToFolderFilePath = [sbDesPath stringByReplacingOccurrencesOfString:@"temp.storyboard" withString:@"temp.xcassets/temp"];
    NSDirectoryEnumerator *myDirectoryEnumerator = [fm enumeratorAtPath: assetsFilePath];
    NSString *assetsFolderInnerfileName = nil;
    while((assetsFolderInnerfileName = [myDirectoryEnumerator nextObject]))
    {
        BOOL isDir = YES;
        NSString *assetsFolderInnerfilePath = [assetsFilePath stringByAppendingPathComponent: assetsFolderInnerfileName];
        BOOL isFileExist = [fm fileExistsAtPath:assetsFolderInnerfilePath isDirectory:&isDir];
        if (!isFileExist) {
            
            //                return nil;
        } else {
            if (isDir) {
                NSLog(@"---%@---", assetsFolderInnerfileName);
                
            } else {
                
                NSString *makeFolderName =
                [[[[assetsFolderInnerfileName stringByReplacingOccurrencesOfString: @"@2x.png" withString:@""] stringByReplacingOccurrencesOfString: @"@3x.png" withString:@""]  stringByReplacingOccurrencesOfString: @".png" withString:@""] stringByAppendingString: @".imageset"];
                NSString *makeFolderFilePath =
                [copyToFolderFilePath stringByAppendingPathComponent: makeFolderName];
                BOOL isDir = YES;
                BOOL isFileExist = [fm fileExistsAtPath: makeFolderFilePath isDirectory:&isDir];
                NSString *assetsFolderInnerfileNewFilePath = [makeFolderFilePath stringByAppendingPathComponent: assetsFolderInnerfileName];
                /// 删除之前老的，直接用新的
                if ([fm fileExistsAtPath: assetsFolderInnerfileNewFilePath]) {
                    [fm removeItemAtPath:assetsFolderInnerfileNewFilePath error:nil];
                }
                if (isFileExist) {
                    
                    if (isDir) {
                        NSError *er = nil;
                        [fm copyItemAtPath:assetsFolderInnerfilePath toPath: assetsFolderInnerfileNewFilePath error: &er];
                        if (er != nil) {
                            NSLog(@"---%@---", er.localizedDescription);
                        }
                    } else {
                        [fm createDirectoryAtPath:makeFolderFilePath withIntermediateDirectories:YES attributes:nil error:nil];
                        NSLog(@"---%@---", makeFolderFilePath);
                        
                        [fm copyItemAtPath:assetsFolderInnerfilePath toPath:assetsFolderInnerfileNewFilePath error:nil];
                    }
                } else {
                    [fm createDirectoryAtPath:makeFolderFilePath withIntermediateDirectories:YES attributes:nil error:nil];
                    NSLog(@"---%@---", makeFolderFilePath);
                    
                    [fm copyItemAtPath:assetsFolderInnerfilePath toPath:assetsFolderInnerfileNewFilePath error:nil];
                }
                
            }
        }
        
    }
}
- (void)createJSONFileInImagesetFromCopyToFolderFilePath:(NSString *)copyToFolderFilePath {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *copyToFolderInnerFileNames = [fm contentsOfDirectoryAtPath: copyToFolderFilePath error: nil];
    
    [copyToFolderInnerFileNames enumerateObjectsUsingBlock:^(NSString * _Nonnull copyToFolderInnerFileName, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        NSString *copyToFolderInnerFilePath = [copyToFolderFilePath stringByAppendingPathComponent: copyToFolderInnerFileName];
        BOOL isDir = NO;
        [fm fileExistsAtPath:copyToFolderInnerFilePath isDirectory: &isDir];
        if (isDir) {
            NSArray<NSString *> *copyToFolderInnerFileFolderInnerFileNames = [fm contentsOfDirectoryAtPath: copyToFolderInnerFilePath error: nil];
            NSMutableDictionary *contentsJSONDict =
            @{
                @"images" : @[
                        @{
                            @"idiom" : @"universal",
                            @"scale" : @"1x"
                        },
                        @{
                            @"idiom" : @"universal",
                            @"scale" : @"2x"
                        },
                        @{
                            @"idiom" : @"universal",
                            @"scale" : @"3x"
                        }
                ],
                @"info" : @{
                        @"version" : @1,
                        @"author" : @"xcode"
                }
            }.mutableCopy;
            [copyToFolderInnerFileFolderInnerFileNames enumerateObjectsUsingBlock:^(NSString * _Nonnull copyToFolderInnerFileFolderInnerFileName, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([copyToFolderInnerFileFolderInnerFileName hasSuffix:@".png"]) {
                    NSString *JSONFilePath = [copyToFolderInnerFilePath stringByAppendingPathComponent:  @"Contents.json"];
                    NSUInteger idx = 0;
                    if ([copyToFolderInnerFileFolderInnerFileName hasSuffix:@"@3x.png"]) {
                        //       "filename" : "编辑@2x.png",
                        idx = 2;
                    } else if ([copyToFolderInnerFileFolderInnerFileName hasSuffix:@"@2x.png"]) {
                        idx = 1;
                    }
                    NSMutableArray *muArr = [contentsJSONDict[@"images"] mutableCopy];
                    NSMutableDictionary *muDict = [muArr[idx] mutableCopy];
                    muDict[@"filename"] = copyToFolderInnerFileFolderInnerFileName;
                    muArr[idx] = muDict;
                    contentsJSONDict[@"images"] = muArr;
                    
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: contentsJSONDict options:NSJSONWritingPrettyPrinted error: nil];
                    NSString *JSONString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    if ([fm fileExistsAtPath:JSONFilePath]) {
                        [fm removeItemAtPath:JSONFilePath error:nil];
                    }
                    [JSONString writeToFile:JSONFilePath atomically:YES encoding: NSUTF8StringEncoding error:nil];
                }
            }];
        }
    }];
    
}
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
- (NSXMLElement *)getSubViewElementInVCElement:(NSXMLElement *)vcElement {
    if (!vcElement) {
        NSLog(@"未找到 %@", vcElement);
        return nil;
    }
    NSXMLElement *object = [vcElement firstElementByName:@"objects"];
    NSXMLElement *vc = [object firstElementByName:@"viewController" ];
    NSXMLElement *view = [vc firstElementByName:@"view"];
    NSXMLElement *subViewSuperView = [view firstElementByName:@"subviews"];
    return subViewSuperView;
}

- (NSXMLElement *)getSubViewElementInElement:(NSXMLElement *)viewElement {
    if (!viewElement) {
        NSLog(@"未找到 %@", viewElement);
        return nil;
    }
    NSXMLElement *subViewSuperView = [viewElement firstElementByName:@"subviews"];
    return subViewSuperView;
}

- (void)addSubviewElement:(NSXMLElement *)subViewElement inVCElement:(NSXMLElement *)vcElement fromSbDocument:(NSXMLDocument *)sbDocument{
    if (!subViewElement) {
        NSLog(@"未找到 %@", subViewElement);
        return;
    }
    if (!vcElement) {
        NSLog(@"未找到 %@", vcElement);
        return;
    }
    NSXMLElement *object = [vcElement firstElementByName:@"objects" ];
    NSXMLElement *vc = [object firstElementByName:@"viewController" ];
    NSXMLElement *view = [vc firstElementByName:@"view"];
    NSXMLElement *subViewSuperView = [view firstElementByName:@"subviews"];
    
    
    [subViewSuperView addChild:subViewElement];
    
    if ([subViewElement.name isEqualToString:@"imageView"]) {
        //如果添加imageView 得<image name="fff.png" width="16" height="16"/>
        
        NSXMLElement *imageNode = [NSXMLElement elementWithName:@"image"];
        NSString *imgName = [subViewElement attributeForName:@"image"].stringValue;
        
        if (imgName && imgName.length > 0) {
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"name" stringValue: imgName]];
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"width" stringValue:@"16"]];
            [imageNode addAttribute:[NSXMLNode attributeWithName:@"height" stringValue:@"16"]];
            NSXMLElement *resources =
            [sbDocument.rootElement firstElementByName:@"resources"];
            NSMutableArray<NSString *> *imgNames = [NSMutableArray array];
            for (NSXMLElement * obj in [resources children]) {
                [imgNames addObject: [obj m_getValueForKey:@"name"]];
            }
            
            if (![imgNames containsObject: imgName]) {
                [resources addChild:imageNode.copy];
            }
        }
    }
}
#pragma mark - 从xml文件加载出 NSXMLElement 对象

#pragma mark - 对 NSXMLElement 对象设置相关属性


-(void)setNormalText:(NSString *)text forButtonElement:(NSXMLElement *)element {
    if (![element.name isEqualToString: @"button"]) {
        return;
    }
    NSXMLElement *stateTextElement = [element firstElementByName:@"state"];
    NSArray<NSXMLNode *> *nodes = stateTextElement.attributes;
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: @"key"]) {
            // 状态
        } else if ([node.name isEqualToString: @"title"]) {
            // 文字内容
            [node setStringValue: text];
        }
    }
}

-(void)setAlpha:(NSString *)alpha ForElement:(NSXMLElement *)element{
    if ([alpha isEqualToString:@"1"]) {
        return;
    }
    NSString *key = @"alpha";
    [element m_setValue:alpha forKey:key];
}


-(void)setViewCss:(NSArray <NSString *> *)css ForElement:(NSXMLElement *)element {
    if (css.count > 1 && [css[0] hasPrefix: @"opacity: 0."]) {
        // 需要设置弹窗背景颜色
        NSXMLElement *colorE = [element firstElementByName: @"color"];
        NSString *keyValue = [colorE m_getValueForKey: @"key"];
        if ([keyValue isEqualToString: @"backgroundColor"]) {
            NSString *cssStr = [css[0] stringByReplacingOccurrencesOfString: @";" withString: @""];
            NSString *colorAlpha = [cssStr componentsSeparatedByString: @":"][1];
            [colorE m_setValue: colorAlpha forKey: @"alpha"];
        }
        
    }
#pragma mark - to do
    // ["border: 1px solid #295DFD;","border-radius: 4px;"]
    NSLog(@"---%@---", css);
    [css enumerateObjectsUsingBlock:^(NSString * _Nonnull str, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([str hasPrefix:@"border:"]) {
            
        } else if ([str hasPrefix:@"border-radius:"]) {
            
        }
    }];
}
-(void)setLable:(NSString *)text forVCElement:(NSXMLElement *)element {
    
    NSXMLElement *objects =  [element firstElementByName: @"objects" ];
    NSXMLElement *viewController =  [objects firstElementByName: @"viewController" ];
    [viewController m_setValue: text forKey: @"userLabel"];
}
/// 如页面太长，改变页面长度
- (void)changeVCSizeForVCElement:(NSXMLElement *)vcElement vcViews:(NSArray <VisibleItem *> *)views {
    /// 设计稿 375*667
    CGFloat screenH = 667;
    
    NSMutableArray<NSNumber *> *viewBottoms = @[].mutableCopy;
    for (VisibleItem *sub in views) {
        if (sub.bounds && sub.bounds.bottom) {
            [viewBottoms addObject: @(sub.bounds.bottom*0.5)];
        }
    }
    
    CGFloat max =[[viewBottoms valueForKeyPath:@"@max.floatValue"] floatValue];
    if (screenH < max) {
        // 这里可以先添加一个scrollView在根view上，再添加其他子控件
        
        NSXMLElement *object = [vcElement firstElementByName:@"objects"];
        NSXMLElement *vc = [object firstElementByName:@"viewController"];
        NSArray<NSXMLElement *> *elements = (NSArray<NSXMLElement *> *)[vc elementsForName:@"size"];
        NSXMLElement *size;
        NSString *maxStr = @(max+20).stringValue;
        if (elements.count >= 1) {
            size =  elements[0];
            [size m_setValue:@"freeformSize" forKey:@"key"];
            [size m_setValue:@"375" forKey:@"width"];
            [size m_setValue: maxStr forKey:@"height"];
        } else {
            size = [NSXMLElement elementWithName:@"size"];
            [size m_setValue:@"freeformSize" forKey:@"key"];
            [size m_setValue:@"375" forKey:@"width"];
            [size m_setValue: maxStr forKey:@"height"];
            [vc addChild:size];
        }
        
    }
}

//// 查找一个view的所有父视图
//+ (NSArray<UIView *> *)findAllSuperViewsWithView:(UIView *)view {
//
//    UIView *tempView = view.superview;
//    NSMutableArray *array = @[].mutableCopy;
//    while (tempView != nil) {
//        [array addObject:tempView];
//        tempView = tempView.superview;
//    }
//    return array;
//}
//
//// 查找两个视图的共同父视图
//+ (NSArray<UIView *> *)findCommonParentViewsWithViewA:(UIView *)viewA viewB:(UIView *)viewB {
//
//    // 查找视图a的所有父视图
//    NSArray *aSuperViews = [self findAllSuperViewsWithView:viewA];
//    // 查找视图b的所有父视图
//    NSArray *bSuperViews = [self findAllSuperViewsWithView:viewB];
//    NSMutableArray *commonSuperViews = @[].mutableCopy;
//    NSInteger i = 0;
//    while (i < MIN(aSuperViews.count, bSuperViews.count)) {
//        // 倒序方式获取各视图的父视图
//        UIView *superViewA = aSuperViews[aSuperViews.count - 1 - i];
//        UIView *superViewB = bSuperViews[bSuperViews.count - 1 - i];
//        // 比较两个父视图是否相同，如果相同则放入到共同的父视图数组中
//        if (superViewA == superViewB) {
//            [commonSuperViews addObject:superViewA];
//        }
//        else {
//            // 不相同则退出循环
//            break;
//        }
//        i++;
//    }
//    return commonSuperViews;
//}
@end
