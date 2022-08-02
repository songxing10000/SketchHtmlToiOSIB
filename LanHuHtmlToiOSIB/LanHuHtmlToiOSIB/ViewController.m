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

@interface ViewController()
/// url输入框
@property (unsafe_unretained) IBOutlet NSTextView *m_textView;
/// 尝试生成
@property (weak) IBOutlet NSButton *m_tryToBuildBtn;


@end
@implementation ViewController
- (IBAction)clickTryToBuildBtn:(NSButton *)sender {
    NSString *urlStr =  self.m_textView.string;
    [self reqUrlStr:urlStr];
}
- (void)reqUrlStr:(NSString *)urlStr {
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            dispatch_semaphore_signal(sema);
        } else {
            NSError *parseError = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (parseError) {
                NSLog(@"%@", error);
                dispatch_semaphore_signal(sema);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NBSKObject *skObj = [NBSKObject objWithJSON:responseDictionary[@"board"]];
                    NSString *storyboardDestPath = [[self desktopFolderFilePath] stringByAppendingPathComponent:@"temp.storyboard"];
                    [self createSBFileAtPath:storyboardDestPath withObj:skObj];
            });
            
            dispatch_semaphore_signal(sema);
        }
    }];
    [dataTask resume];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
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
@end

