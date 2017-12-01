//
//  ViewController.m
//  OpenGL_ES_3.0学习
//
//  Created by MBP on 2017/11/23.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "ViewController.h"

#import "GLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    EAGLContext* context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
//    [EAGLContext setCurrentContext:context];
//
//    printf("厂家 = %s\n", glGetString(GL_VENDOR));
//    printf("渲染器 = %s\n", glGetString(GL_RENDERER));
//    printf("ES版本 = %s\n", glGetString(GL_VERSION));
//    printf("拓展功能 =>\n%s\n", glGetString(GL_EXTENSIONS));

    GLView* v1 = [GLView new];
    v1.frame = self.view.bounds;
    [self.view addSubview:v1];
}




@end
