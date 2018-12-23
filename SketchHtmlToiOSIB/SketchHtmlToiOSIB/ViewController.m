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

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *htmlFilePath = @"/Users/dfpo/Downloads/222/index.html";
    NBSKObject *skObj = [self readHtmlAtPath:htmlFilePath];
    NSString *storyboardDestPath = @"/Users/dfpo/Downloads/temp.storyboard";
    [self createSbDesPathAt:storyboardDestPath fromObj:skObj];
}
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

