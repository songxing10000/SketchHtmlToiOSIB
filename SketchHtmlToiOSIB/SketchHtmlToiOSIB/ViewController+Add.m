//
//  ViewController+Add.m
//  SketchHtmlToiOSIB
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
    if (!isDir) {
        
        if (![[htmlFilePath pathExtension] isEqualToString:@"html"]) {
            NSLog(@"应该传入html文件");
            return nil;
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

/**
 忽略某个view不加入到页面上

 @param view 要判断的view
 */
- (BOOL)canIgnoreView:(SKLayer *)view {
    if (!view.objectID) {
        return YES;
    }
    if (view.rect.x.intValue <= 16 &&
        view.rect.y.intValue <= 36 &&
        view.rect.width.intValue <= 9 &&
        view.rect.height.intValue <= 26 ) {
        /// 不添加把返回按钮
        return YES;
    } else if (view.rect.y.intValue < 20 &&
               view.rect.height.intValue <= 20 ) {
        // 不添加状态栏上的控件
        return YES;
    }
    return NO;
}
- (void)createSBFileAtPath:(NSString *)sbDesPath withObj:(NBSKObject *)object htmlFilePath:(NSString *)htmlFilePath {
    if (!sbDesPath || !object) {
        return;
    }
    NSXMLDocument *sbDocument = [self documentWithXmlFileName:@"sb"];
    
    NSXMLElement *scenes =
    [sbDocument.rootElement firstElementByName:@"scenes"];
    [self.hud show:YES];
    for (ArtboardsItem *vc in object.artboards) {
        /// 调试某个特定页面可这样写
//                if (![vc.name isEqualToString: @"编辑员工信息"]) {
//                    NSLog(@"---%@---", vc.name);
//                continue;
//
//                }
        NSXMLElement *vcElement = [self getNewVCElement];
        NSArray <SKLayer *> *views = vc.layers;
        [self changeVCSizeForVCElement:vcElement vcViews:views];
        for (SKLayer *view in views) {
            if ([self canIgnoreView:view]) {
                continue;
            }
            
            /// 控件类别 text为lable， slice为图片，shape为view
            NSString *viewType = view.type;
            /// 将要被添加的新的 view NSXMLElement 对象
            NSXMLElement *aNewWillBeAddedViewElement = nil;
            if ([viewType isEqualToString:@"text"]) {
                if ([view.content hasPrefix: @"请输入"] ||
                    [view.content hasPrefix: @"请填写"]) {
#pragma mark - UITextFiled
                    // 输入框
                    NSXMLElement *textFiledElement = [self getNewTextFiledElement];
                    // placeholder
                    [textFiledElement m_setValue: view.content forKey: @"placeholder"];
                    
                    textFiledElement.fontSize = view.fontSize;
                    textFiledElement.fontStyle = view.fontFace;
                    // placeholder 颜色xml内置
                    // 正常情况下的文字颜色 xml内置
                    
                    //                    textFiledElement.textColor =
//                    [NSString stringWithFormat:@"(r:%f g:%f b:%f a:1.00)",view.color.r/255.0, view.color.g/255.0, view.color.b/255.0];
                    aNewWillBeAddedViewElement = textFiledElement;
                } else {
#pragma mark - UILabel

                    // 文本
                    NSXMLElement *labelElement = [self getNewlabelElement];
                    labelElement.text = view.content;
                    labelElement.fontSize = view.fontSize;
                    labelElement.fontStyle = view.fontFace;
                    labelElement.textColor =
                    [NSString stringWithFormat:@"(r:%f g:%f b:%f a:1.00)",view.color.r/255.0, view.color.g/255.0, view.color.b/255.0];
                    aNewWillBeAddedViewElement = labelElement;
                }
            }
            else if ([viewType isEqualToString:@"slice"]) {
                //图片
#pragma mark - UIImageView
                NSXMLElement *imgElement = [self getNewImageViewElementWithImgName: view.name];
                aNewWillBeAddedViewElement = imgElement;
            }
            else if ([viewType isEqualToString:@"shape"]) {
                //view
#pragma mark - UIView
                if ([view.rect.width isEqualToString: @"375"] &&
                    [view.rect.height isEqualToString: @"646"]) {
                    NSLog(@"---%@---",@"fsdf");
                }
                NSXMLElement *viewElement = [self getNewViewElement];
                if (view.fills && view.fills.count > 0) {
                    viewElement.backgroundColor = view.fills[0].color.uiColor ;
                }
                if (view.css && view.css.count > 0) {
                    [self setViewCss:view.css ForElement:viewElement];
                }
                aNewWillBeAddedViewElement = viewElement;
            }
            else {
                
                NSLog(@"--未知类型控件--%@---", viewType);
            }
            
            if (view.opacity) {
                // 暂忽略 透明度，用到的场景太少
//                [self setAlpha:view.opacity ForElement:aNewWillBeAddedViewElement];
            }
            aNewWillBeAddedViewElement.skRect = view.rect;
            if ([view.rect.y isEqualToString: @"30"]||
                [view.rect.y isEqualToString: @"31"]) {
                //可能是标题
                [self setLable:view.content forVCElement:vcElement];
            } else {
                [self setLable:vc.name forVCElement:vcElement];
            }
            if (!aNewWillBeAddedViewElement) {
                continue;
            }
            NSArray<NSXMLElement *> *rootViewSubViewElements = [self getSubViewElementInVCElement:vcElement].children;
            NSMutableArray<SKRect *> *rootViewSubViewSKRects = [NSMutableArray array];
            for (NSXMLElement *rootViewSubViewElement in rootViewSubViewElements) {
                [rootViewSubViewSKRects addObject:  rootViewSubViewElement.skRect];
            }
            /// 将要被添加的新的 view NSXMLElement 对象的 CGRect值
            CGRect aNewWillBeAddedViewRect =  aNewWillBeAddedViewElement.cgRect;
            BOOL hasSuperViewInRootView = NO;
            for (SKRect *rootViewSubViewSKRect in rootViewSubViewSKRects) {
                
                CGRect superViewInRootViewCGRect =
                [self getCGRectFromSKRect:rootViewSubViewSKRect];
                
                if ( !CGRectContainsRect(superViewInRootViewCGRect, aNewWillBeAddedViewRect) ) {
                    continue;
                }
                hasSuperViewInRootView = YES;
                NSUInteger findedSuperViewIdx =
                [rootViewSubViewSKRects indexOfObject: rootViewSubViewSKRect];
                
                NSXMLElement *superViewInRootViewElement =
                rootViewSubViewElements[findedSuperViewIdx];
                
                /// 再找一找父控件里，又包含自己的真正父控件
                NSArray<NSXMLElement *> *superViewInRootViewSubElements =
                [self getSubViewElementInElement: superViewInRootViewElement].children;
                //
                NSMutableArray<SKRect *> *superViewInRootViewSubSKRects = [NSMutableArray array];
                for (NSXMLElement *superViewInRootViewSubElement in superViewInRootViewSubElements) {
                    [superViewInRootViewSubSKRects addObject:  superViewInRootViewSubElement.skRect];
                }
                /// 在父控件里又有父控件
                BOOL hasSuperViewInSuperView = NO;
                for (SKRect *superViewInRootViewSubSKRect in superViewInRootViewSubSKRects) {
                    //
                    CGRect superViewInSuperViewCGRect = [self getCGRectFromSKRect: superViewInRootViewSubSKRect];
                    /// 最开始要加的父控件的SKRect
                    SKRect *firstSuperSKRect =  superViewInRootViewElement.skRect;
                    /// 坐标系转换
                    SKRect *oldSelfR =  aNewWillBeAddedViewElement.skRect;
                    oldSelfR.x = [NSString stringWithFormat:@"%zd", (oldSelfR.x.integerValue - firstSuperSKRect.x.integerValue)];
                    oldSelfR.y = [NSString stringWithFormat:@"%zd", (oldSelfR.y.integerValue - firstSuperSKRect.y.integerValue)];
                    if (oldSelfR.y.integerValue <= 0) {
                        oldSelfR.y = @"0";
                    }
                    
                    if (! CGRectContainsRect(superViewInSuperViewCGRect, [self getCGRectFromSKRect:oldSelfR]) ) {
                        continue;
                    }
                    hasSuperViewInSuperView = YES;
                    //
                    NSUInteger findedSuperViewInSuperViewIdx = [superViewInRootViewSubSKRects indexOfObject:superViewInRootViewSubSKRect];
                    NSXMLElement *findedSuperViewInSuperViewElement = superViewInRootViewSubElements[findedSuperViewInSuperViewIdx];
                    aNewWillBeAddedViewElement.skRect = oldSelfR;
                    [self moveSubviewElement: aNewWillBeAddedViewElement
                          toSuperViewElement: findedSuperViewInSuperViewElement
                              fromSbDocument: sbDocument
                                needChangeXY: YES];
                    
                    break;
                }
                if (!hasSuperViewInSuperView) {
                    [self moveSubviewElement: aNewWillBeAddedViewElement
                          toSuperViewElement: superViewInRootViewElement
                              fromSbDocument: sbDocument
                                needChangeXY: YES];
                } else {
                    NSLog(@"---%@---",@"ff");
                }
                
                break;
                
                
            }
            
            
            if (!hasSuperViewInRootView) {
                //  在根view下面没有找到了父控件，就加入到根view下
                [self addSubviewElement:aNewWillBeAddedViewElement
                            inVCElement:vcElement
                         fromSbDocument:sbDocument];
            } else {
                NSLog(@"---%@---",@"ff");
            }
            
        }
        // 尝试加入按钮
        [self generateBtnInRootViewFromVC:vcElement fromSbDocument:sbDocument];
        [scenes addChild: vcElement];
        self.hud.progress = (scenes.childCount+1)/(object.artboards.count+1);
        self.hud.labelText = [NSString stringWithFormat:@"%tu/%tu",scenes.childCount,object.artboards.count];
        if (scenes.childCount == object.artboards.count) {
            NSLog(@"----%@---", @"写入完成");
//            [[NSWorkspace sharedWorkspace] selectFile:sbDesPath inFileViewerRootedAtPath:sbDesPath];
//
//            [[NSWorkspace sharedWorkspace] openFile:sbDesPath withApplication:@"Xcode"];
            
            NSString *proFilePath = [sbDesPath stringByReplacingOccurrencesOfString:@".storyboard" withString:@".xcodeproj"];
             NSString *copyToFolderFilePath = [sbDesPath stringByReplacingOccurrencesOfString:@"temp.storyboard" withString:@"temp.xcassets/temp"];
            [[NSFileManager defaultManager] removeItemAtPath: copyToFolderFilePath error: nil];
            // 在桌面生成temp.xcodeproj临时工程关联temp.storyboard和temp.xcassets
            [self createTempProjectAtPath: proFilePath basisSBFileAtPath: sbDesPath htmlFilePath: htmlFilePath];
            // 生成json
            [self createJSONFileInImagesetFromCopyToFolderFilePath: copyToFolderFilePath];
            // 打开临时工程
            [[NSWorkspace sharedWorkspace] selectFile:proFilePath inFileViewerRootedAtPath:proFilePath];
            [[NSWorkspace sharedWorkspace] openFile:proFilePath withApplication:@"Xcode"];
        }
        
    }
    
    [self saveXMLDoucment:sbDocument toPath:sbDesPath];
    [self.hud hide:YES];
    
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
/// 生成某个页面中根view中的按钮
- (void)generateBtnInRootViewFromVC:(NSXMLElement *) vcElement fromSbDocument:(NSXMLDocument *)sbDocument{
    
    NSArray<NSXMLElement *> *rootViewSubViewElements = [self getSubViewElementInVCElement:vcElement].children;
    
    [rootViewSubViewElements enumerateObjectsUsingBlock:^(NSXMLElement * _Nonnull rootViewSubE, NSUInteger idx, BOOL * _Nonnull stop) {
        // 根view下可组合成按钮的
        NSArray<NSXMLElement *> *subEs = [self getSubViewElementInElement: rootViewSubE].children;
        NSArray<NSString *> *names = [subEs valueForKeyPath:@"name"];
        BOOL isOnleText = names.count == 1 && [names containsObject: @"label"];
        BOOL isTextAndImg = subEs.count == 2 && [names containsObject: @"label"] &&
        [names containsObject: @"imageView"];
        if ([rootViewSubE.name isEqualToString: @"view"] && (isOnleText || isTextAndImg)) {
            
            NSXMLElement *label;
            if (isOnleText) {
                label = subEs[0];
                
            } else if (isTextAndImg) {
                
                label = subEs[[names indexOfObject: @"label"]];
            }
            // view 包含一个  label
            NSXMLElement *button = [self getNewButtonElement];
            if (rootViewSubE.skRect.y.integerValue < 0) {
                rootViewSubE.skRect.y = @"0";
            }
            // 更新button frame
            button.skRect = rootViewSubE.skRect;
            // 更新 bgColor
            button.backgroundColor = rootViewSubE.backgroundColor;
            // normal 状态下的文字
            [self setNormalText: label.text forButtonElement:button];
            // normal 状态下的字色 字号大小
            button.fontSize = label.fontSize;
            button.fontStyle = label.fontStyle;
            button.normalTitleColor = label.textColor;
            // 删除label
            if (subEs.count == 1) {
                [[rootViewSubE firstElementByName: @"subviews"] removeChildAtIndex: 0];
            } else if (subEs.count == 2) {
                [[rootViewSubE firstElementByName: @"subviews"] removeChildAtIndex: 0];
                [[rootViewSubE firstElementByName: @"subviews"] removeChildAtIndex: 0];
            }
            
            // 删除 label的父控件view
            NSArray<NSXMLElement *> *rootViewSubViewElements = [self getSubViewElementInVCElement:vcElement].children;
            NSUInteger idx = [rootViewSubViewElements indexOfObject:rootViewSubE];
            [[self getSubViewElementInVCElement:vcElement] removeChildAtIndex: idx];
            [self addSubviewElement:button inVCElement:vcElement fromSbDocument:sbDocument];
        }
        
        [subEs enumerateObjectsUsingBlock:^(NSXMLElement * _Nonnull rootViewSubSubE, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray<NSXMLElement *> *subEs2 = [self getSubViewElementInElement: rootViewSubSubE].children;
            NSArray<NSString *> *names2 = [subEs2 valueForKeyPath:@"name"];
            BOOL isOnleText = names2.count == 1 && [names2 containsObject: @"label"];
            BOOL isTextAndImg = subEs2.count == 2 && [names2 containsObject: @"label"] &&
            [names2 containsObject: @"imageView"];
            if ([rootViewSubSubE.name isEqualToString: @"view"] && (isOnleText || isTextAndImg)) {
                
                NSXMLElement *label;
                if (isOnleText) {
                    label = subEs2[0];
                    
                } else if (isTextAndImg) {
                    
                    label = subEs2[[names2 indexOfObject: @"label"]];
                }
                // view 包含一个  label
                NSXMLElement *button = [self getNewButtonElement];
                // 更新button frame
                button.skRect = rootViewSubSubE.skRect;
                // 更新 bgColor
                button.backgroundColor = rootViewSubSubE.backgroundColor;
                // normal 状态下的文字
                [self setNormalText: label.text forButtonElement:button];
                // normal 状态下的字色 字号大小
                button.fontSize = label.fontSize;
                button.fontStyle = label.fontStyle;
                button.normalTitleColor = label.textColor;
                // 删除label
                if (subEs2.count == 1) {
                    [[rootViewSubSubE firstElementByName: @"subviews"] removeChildAtIndex: 0];
                } else if (subEs2.count == 2) {
                    [[rootViewSubSubE firstElementByName: @"subviews"] removeChildAtIndex: 0];
                    [[rootViewSubSubE firstElementByName: @"subviews"] removeChildAtIndex: 0];
                }
                
                // 删除 label的父控件view
                NSUInteger idx = [subEs indexOfObject:rootViewSubSubE];
                
                [[self getSubViewElementInElement: rootViewSubE] removeChildAtIndex: idx];
                // 更新button frame  这里坐标系 转换，有点头晕，后续有问题再修改
                SKRect *firstSuperSKRect = rootViewSubE.skRect;
                /// 坐标系转换
                SKRect *oldSelfR = button.skRect;
                oldSelfR.x = [NSString stringWithFormat:@"%zd", (oldSelfR.x.integerValue - firstSuperSKRect.x.integerValue)];
                NSInteger yStart = oldSelfR.y.integerValue - firstSuperSKRect.y.doubleValue;
                if (yStart < 0) {
                    yStart = 0;
                }
                oldSelfR.y = [NSString stringWithFormat:@"%zd", yStart];
//                button.skRect = oldSelfR;
                
                [self moveSubviewElement:button toSuperViewElement: rootViewSubE  fromSbDocument: sbDocument needChangeXY:NO];
            }
        }];
    }];
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
/// 移动子元素到父元素内，添加子view到其父view上
- (void)moveSubviewElement:(NSXMLElement *)subViewElement toSuperViewElement:(NSXMLElement *)superViewElement fromSbDocument:(NSXMLDocument *)sbDocument needChangeXY:(BOOL)needChangeXY{
    
    if (!subViewElement) {
        NSLog(@"未找到 %@", subViewElement);
        return;
    }
    if (!superViewElement) {
        NSLog(@"未找到 %@", superViewElement);
        return;
    }
    NSXMLElement *subViewSuperView = [superViewElement firstElementByName:@"subviews"];
    if ([superViewElement.name isEqualToString:@"label"] ||
        [superViewElement.name isEqualToString:@"imageView"] ||
        [superViewElement.name isEqualToString:@"button"]) {
        
        return;
    }
    if (needChangeXY) {
        SKRect *oldSuperR = superViewElement.skRect;
        SKRect *oldSelfR = subViewElement.skRect;
        /// 更新 移动到父控件里的x y
        oldSelfR.x = [NSString stringWithFormat:@"%zd", (oldSelfR.x.integerValue - oldSuperR.x.integerValue)];
        oldSelfR.y = [NSString stringWithFormat:@"%zd", (oldSelfR.y.integerValue - oldSuperR.y.integerValue)];
        if (oldSelfR.y.integerValue <= 0) {
            oldSelfR.y = @"0";
        }
        subViewElement.skRect = oldSelfR;
    }
    
    // 考虑 更新 x y
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
- (NSXMLElement *)getNewVCElement {
    NSXMLElement *vcElement = [self rootElementWithXmlFileName:@"vc"];
    [self setRandomIdForElement:vcElement];
    NSXMLElement *objects = [vcElement firstElementByName:@"objects"];
    NSXMLElement *placeholder = [objects firstElementByName:@"placeholder"];
    [self setRandomIdForElement:placeholder];
    
    NSXMLElement *viewController = [objects firstElementByName:@"viewController"];
    [self setRandomIdForElement:viewController];
    
    
    NSXMLElement *view = [viewController firstElementByName:@"view" ];
    [self setRandomIdForElement:view];
    NSXMLElement *viewLayoutGuide = [view firstElementByName:@"viewLayoutGuide" ];
    [self setRandomIdForElement:viewLayoutGuide];
    
    return vcElement.copy;
}
- (NSXMLElement *)getNewTextFiledElement {
    NSXMLElement *textFiledElement = [self rootElementWithXmlFileName:@"textField"];
    [self setRandomIdForElement:textFiledElement];
    return textFiledElement.copy;
}
- (NSXMLElement *)getNewlabelElement {
    NSXMLElement *lableElement = [self rootElementWithXmlFileName:@"label"];
    [self setRandomIdForElement:lableElement];
    return lableElement.copy;
}
- (NSXMLElement *)getNewButtonElement {
    NSXMLElement *lableElement = [self rootElementWithXmlFileName:@"button"];
    [self setRandomIdForElement:lableElement];
    return lableElement.copy;
}
/// name imageView"
- (NSXMLElement *)getNewImageViewElementWithImgName:(NSString *)imgName {
    NSXMLElement *imgVElement = [self rootElementWithXmlFileName:@"imageView"];
    [imgVElement m_setValue: imgName forKey: @"image"];
    [self setRandomIdForElement:imgVElement];
    return imgVElement.copy;
}
- (NSXMLElement *)getNewViewElement {
    NSXMLElement *viewElement = [self rootElementWithXmlFileName:@"view"];
    [self setRandomIdForElement:viewElement];
    return viewElement.copy;
}
#pragma mark - 对 NSXMLElement 对象设置相关属性
- (void)setRandomIdForElement:(NSXMLElement *)element {
    NSArray<NSXMLNode *> *nodes = element.attributes;
    NSString *name = [element.name isEqualToString:@"scene"]?@"sceneID":@"id";
    for (NSXMLNode *node in nodes) {
        if ([node.name isEqualToString: name]) {
            [node setStringValue:[NSString randomid]];
        }
    }
}

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
- (CGRect)getCGRectFromSKRect:(SKRect *)desSR {
    CGRect rect =
    CGRectMake(desSR.x.floatValue, desSR.y.floatValue, desSR.width.floatValue, desSR.height.floatValue);
    return rect;
}

- (void)changeVCSizeForVCElement:(NSXMLElement *)vcElement vcViews:(NSArray <SKLayer *> *)views {
    /// 设计稿 375*667
    CGFloat screenH = 667;
    NSArray<NSString *> *viewYs = [views valueForKeyPath:@"rect.y"];
    NSArray<NSString *> *viewHs = [views valueForKeyPath:@"rect.height"];
    NSMutableArray<NSNumber *> *maxYs = [NSMutableArray array];
    [viewYs enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull y, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger aY = viewHs[idx].integerValue + y.integerValue;
        [maxYs addObject:@(aY)];
    }];
    
    CGFloat max =[[maxYs valueForKeyPath:@"@max.floatValue"] floatValue];
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
@end
