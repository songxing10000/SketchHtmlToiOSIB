//
//  NSXMLElement+Add.h
//  LanHuHtmlToiOSIB
//
//  Created by mac on 2019/6/16.
//  Copyright © 2019 dfpo. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "NBSKObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSXMLElement (Add)
+ (nullable NSXMLElement *)elementWithItem:(nonnull VisibleItem *)item;

/// label view button
@property(nonatomic, copy) NSString *backgroundColor;
/// label
@property(nonatomic, copy) NSString *text;
/// label
@property(nonatomic, copy) NSString *textColor;
/// button中的label的color
@property(nonatomic, copy) NSString *normalTitleColor;
/// label button textFiled
@property(nonatomic, copy) NSString *fontSize;
/// label button textFiled 字的样式类型如 苹方-简 常规体
@property(nonatomic, copy) NSString *fontStyle;
@property(nonatomic, strong) _orgBounds *skRect;
@property(nonatomic, assign) CGRect cgRect;

- (NSXMLElement *)firstElementByName:(NSString *)elementName;
- (NSString *)m_getValueForKey:(NSString *)key;
- (void)m_setValue:(NSString *)value forKey:(NSString *)key;


+ (void)setRandomIdForElement:(NSXMLElement *)element;
+ (NSXMLElement *)rootElementWithXmlFileName:(NSString *)xmlFileName;
+ (NSXMLDocument *)documentWithXmlFileName:(NSString *)xmlFileName;




+ (NSXMLElement *)getNewVCElement;
+ (NSXMLElement *)getNewTextFiledElement;
+ (NSXMLElement *)getNewlabelElement;
+ (NSXMLElement *)getNewButtonElement;
+ (NSXMLElement *)getNewImageViewElementWithImgName:(NSString *)imgName;
+ (NSXMLElement *)getNewViewElement;

@end


NS_ASSUME_NONNULL_END

