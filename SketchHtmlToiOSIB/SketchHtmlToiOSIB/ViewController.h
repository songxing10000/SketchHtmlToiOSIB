//
//  ViewController.h
//  SketchHtmlToiOSIB
//
//  Created by dfpo on 2018/12/22.
//  Copyright © 2018 dfpo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MBProgressHUD.h>

@interface ViewController : NSViewController

@property(nonatomic, strong) MBProgressHUD *hud;
/// {label的字 : 被加入的次数}
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *labelCountDict;
@end

