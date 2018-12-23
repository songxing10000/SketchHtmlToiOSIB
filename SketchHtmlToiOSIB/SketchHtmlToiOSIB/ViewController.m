//
//  ViewController.m
//  SketchHtmlToiOSIB
//
//  Created by dfpo on 2018/12/22.
//  Copyright © 2018 dfpo. All rights reserved.
//

#import "ViewController.h"
#import "ViewController+Add.h"

@class NBSKObject;


@implementation ViewController
#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *htmlFilePath = @"/Users/mac/Downloads/开元助手首页（趋势图）";
    NSString *jsonStr = [self jsonStrWithHtmlFileAtPath:htmlFilePath];
    NBSKObject *skObj = [NBSKObject objWithJSON:jsonStr];
    NSString *storyboardDestPath = @"/Users/mac/Downloads/temp.storyboard";
    [self createSBFileAtPath:storyboardDestPath withObj:skObj];
}
#pragma mark - getter and setter
-(MBProgressHUD *)hud {
    if (_hud) {
        return _hud;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.progress = 0.1;
    _hud = hud;
    return _hud;
}
@end

