//
//  ViewController+Add.h
//  SketchHtmlToiOSIB
//
//  Created by dfpo on 2018/12/22.
//  Copyright © 2018 dfpo. All rights reserved.
//

#import "ViewController.h"
#import "NBSKObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface ViewController (Add)
#pragma mark - read save xml
- (NSXMLElement *)rootElementWithXmlFileName:(NSString *)xmlFileName;
- (NSXMLDocument *)documentWithXmlFileName:(NSString *)xmlFileName;
- (NSString *)jsonStrWithHtmlFileAtPath:(NSString *)htmlFilePath;
- (void)createSBFileAtPath:(NSString *)sbDesPath withObj:(NBSKObject *)object;
- (BOOL)saveXMLDoucment:(NSXMLDocument *)XMLDoucment toPath:(NSString *)destPath;
#pragma mark - get view add view
- (void)addSubviewElement:(NSXMLElement *)subViewElement inVCElement:(NSXMLElement *)vcElement fromSbDocument:(NSXMLDocument *)sbDocument;
- (NSXMLElement *)getNewVCElement;
- (NSXMLElement *)getNewlabelElement;
- (NSXMLElement *)getNewImageViewElement;
- (NSXMLElement *)getNewViewElement;
- (void)setRandomIdForElement:(NSXMLElement *)element;
#pragma mark - setProperty
- (NSXMLElement *)getFirstElementByName:(NSString *)elementName FromElement:(NSXMLElement *)element;
- (void)setRect:(SKRect *)rect forElement:(NSXMLElement *)element;
-(void)setText:(NSString *)text forLableElement:(NSXMLElement *)element;
-(void)setTextAlign:(NSString *)textAlign forLabelElement:(NSXMLElement *)element;
- (void)setTextRegularMediumBold:(NSString *)style forLabelElement:(NSXMLElement *)labelElement; 
- (void)setPointSize:(NSString *)pointSize forLabelElement:(NSXMLElement *)element;
-(void)setTextColor:(NSString *)textColor forLabelElement:(NSXMLElement *)element;
-(void)setBgColor:(NSString *)viewBgColor forViewElement:(NSXMLElement *)element;
/// 背景alpha
-(void)setAlpha:(NSString *)alpha ForElement:(NSXMLElement *)element;

-(void)setViewCss:(NSArray <NSString *> *)css ForElement:(NSXMLElement *)element;
/// 页面在sb中的label
-(void)setLable:(NSString *)text forVCElement:(NSXMLElement *)element;
#pragma mark - id
-(NSString *)randomid;
#pragma mark - other

- (NSDictionary *)dicWithJsonStr:(NSString *)jsonString;
@end

NS_ASSUME_NONNULL_END
