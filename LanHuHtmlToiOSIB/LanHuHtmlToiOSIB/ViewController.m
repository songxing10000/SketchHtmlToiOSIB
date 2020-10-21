//
//  ViewController.m
//  LanHuHtmlToiOSIB
//
//  Created by dfpo on 2018/12/22.
//  Copyright © 2018 dfpo. All rights reserved.
//

@class NBSKObject;

#import "ViewController.h"
#import "ViewController+Add.h"
#import "XMDragView.h"
#import "XMFileItem.h"

@interface ViewController()<XMDragViewDelegate>


@end
@implementation ViewController
#pragma mark - view life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
}
#pragma mark - XMDragViewDelegate
- (void)dragView:(XMDragView *)dragView didDragItems:(NSArray *)items
{
    NSString *htmlFilePath = items[0];
    NSString *jsonStr = [self jsonStrWithHtmlFileAtPath:htmlFilePath];
    NBSKObject *skObj = [NBSKObject objWithJSON:jsonStr];
    
    NSLog(@"---%@---",[skObj.visible valueForKeyPath:@"type"]);
    for (VisibleItem *item1 in skObj.visible) {
        for (VisibleItem *item2 in item1.layers) {
            NSLog(@"---%@---",[item2.layers valueForKeyPath:@"type"]);
            for (VisibleItem *item3 in item2.layers) {
                NSLog(@"---%@---",[item3.layers valueForKeyPath:@"type"]);
                
                for (VisibleItem *item4 in item3.layers) {
                    NSLog(@"---%@---",[item4.layers valueForKeyPath:@"type"]);
                }
            }
        }
    }
    
    NSString *storyboardDestPath = [[self desktopFolderFilePath] stringByAppendingPathComponent:@"temp.storyboard"];
    [self createSBFileAtPath:storyboardDestPath withObj:skObj htmlFilePath: htmlFilePath];
}
- (NSString*)desktopFolderFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    if (!basePath) {
        NSLog(@"----%@---", @"没有找到桌面位置");
        return nil;
    }
    return basePath;
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
-(NSMutableDictionary<NSString *,NSNumber *> *)labelCountDict {
    if (_labelCountDict) {
        return _labelCountDict;
    }
    NSMutableDictionary *labelCountDict = @{}.mutableCopy;
    _labelCountDict = labelCountDict;
    return _labelCountDict;
}
@end

