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

- (NSString *)jsonStrWithHtmlFileAtPath:(NSString *)htmlFilePath;
- (void)createSBFileAtPath:(NSString *)sbDesPath withObj:(NBSKObject *)object htmlFilePath:(NSString *)htmlFilePath;
@end

NS_ASSUME_NONNULL_END
