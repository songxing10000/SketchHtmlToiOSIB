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
- (NSXMLElement *)loadTemplateRootElementWithXmlFileName:(NSString *)xmlFileName;
- (NSXMLDocument *)loadTemplateDocumentFromXmlFileName:(NSString *)xmlFileName;
- (NBSKObject *)readHtmlAtPath:(NSString *)htmlFilePath;
- (void)createSbDesPathAt:(NSString *)sbDesPath fromObj:(NBSKObject *)object;
- (BOOL)saveXMLDoucment:(NSXMLDocument *)XMLDoucment toPath:(NSString *)destPath;
#pragma mark - get view add view
- (void)addSubview:(NSXMLElement *)subViewElement inVC:(NSXMLElement *)vcElement fromSb:(NSXMLDocument *)sbDocument;
- (NSXMLElement *)getVcElement;
- (NSXMLElement *)getlabelElement;
- (NSXMLElement *)getImgVElement;
- (NSXMLElement *)getViewElement;
- (void)setRandomIdFromElement:(NSXMLElement *)element;
#pragma mark - setProperty
- (NSXMLElement *)getFirstElementName:(NSString *)elementName FromElement:(NSXMLElement *)element;
- (void)setRect:(SKRect *)rect ForElement:(NSXMLElement *)element;
-(void)setText:(NSString *)text ForElement:(NSXMLElement *)element;
-(void)setTextAlign:(NSString *)textAlign ForElement:(NSXMLElement *)element;
- (void)setPointSize:(NSString *)pointSize ForElement:(NSXMLElement *)element;
-(void)setTextColor:(NSString *)textColor ForElement:(NSXMLElement *)element;
-(void)setviewBgColor:(NSString *)viewBgColor ForElement:(NSXMLElement *)element;
/// 背景alpha
-(void)setAlpha:(NSString *)alpha ForElement:(NSXMLElement *)element;

-(void)setViewCss:(NSArray <NSString *> *)css ForElement:(NSXMLElement *)element;

-(void)setVCLable:(NSString *)text forVCElement:(NSXMLElement *)element;
#pragma mark - id
-(NSString *)randomid;
#pragma mark - other

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
@end

NS_ASSUME_NONNULL_END
