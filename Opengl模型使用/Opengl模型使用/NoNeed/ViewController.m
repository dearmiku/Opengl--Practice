//
//  ViewController.m
//  Opengl模型使用
//
//  Created by MBP on 2017/12/6.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GLView* v = [GLView new];
    v.frame = self.view.bounds;
    [self.view insertSubview:v atIndex:0];
}


@end
