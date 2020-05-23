
//
//  ZKViewController.m
//  ZKPreviewController
//
//  Created by deyang143@126.com on 05/07/2020.
//  Copyright (c) 2020 deyang143@126.com. All rights reserved.
//

#import "ZKViewController.h"
#import <ZKCategories/ZKCategories.h>
#import <ZKPreviewController/ZKPreviewController.h>
#import <Masonry/Masonry.h>

@interface ZKViewController ()

@end

@implementation ZKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    @weakify(self);
    UIButton *button       = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    button.titleLabel.textColor = UIColor.blackColor;
    [button setTitle:@"Demo" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addBlockForControlEvents:UIControlEventTouchUpInside
                               block:^(__kindof UIControl *_Nonnull sender) {
                                   @strongify(self);
                                   ZKPreviewController *controller = [[ZKPreviewController alloc] init];
                                   controller.items                = @[
                                       [ZKPreviewItem itemWithURL:@"http://www.igg.cas.cn/xwzx/kyjz/201404/W020140417581719774926.pdf".URL
                                                            title:/*@"科学研究动态监测快报"*/nil
                                                   filenameHashed:NO],
                                       [ZKPreviewItem itemWithURL:@"http://www.jyb.cn/info/jyzck/201309/P020130906611930584243.docx".URL
                                                            title:@"教育法律一揽子修订草案(征求意见稿) 条文对照表"
                                                   filenameHashed:NO],
                                   ];
                                   [self kai_pushViewController:controller];
                               }];
    kai_view_border_radius(button, 6, 1, UIColor.lightGrayColor);
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(80, 40));
        make.center.equalTo(self.view);
    }];
}

@end
