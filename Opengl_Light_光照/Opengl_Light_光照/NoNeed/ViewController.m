//
//  ViewController.m
//  Opengl_Light_光照
//
//  Created by MBP on 2017/12/4.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h"
#import "GL_MoreLight_View.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    GL_MoreLight_View* v = [GL_MoreLight_View new];
    v.frame = self.view.bounds;
    [self.view insertSubview:v atIndex:0];

}




@end

