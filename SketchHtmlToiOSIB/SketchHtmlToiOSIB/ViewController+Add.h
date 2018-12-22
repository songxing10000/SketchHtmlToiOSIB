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

-(void)setVCLable:(NSString *)text ForElement:(NSXMLElement *)element;
@end

NS_ASSUME_NONNULL_END
