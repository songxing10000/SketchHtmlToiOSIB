//
//  NSXMLElement+Add.h
//  SketchHtmlToiOSIB
//
//  Created by mac on 2019/6/16.
//  Copyright © 2019 dfpo. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSXMLElement (Add)
/// label view button
@property(nonatomic, copy) NSString *backgroundColor;
/// label
@property(nonatomic, copy) NSString *textColor;
/// label button
@property(nonatomic, copy) NSString *pointSize;

- (NSXMLElement *)firstElementByName:(NSString *)elementName; 
@end

