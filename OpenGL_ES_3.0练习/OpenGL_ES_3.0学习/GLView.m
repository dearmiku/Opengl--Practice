//
//  GLView.m
//  OpenGL_ES_3.0学习
//
//  Created by MBP on 2017/11/23.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "GLView.h"
#import "GLView+DrawRect.h"
#import "GLView+DrawTriangle.h"
#import "GLView+Texture2D.h"
#import "GLView+Camera.h"

@interface GLView ()

@end

@implementation GLView

+(Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    //[self setupGL_SetBackgroundColor];
    //[self setupGL_SetRect];
    //[self setupGL_Triangle];
    //[self setupGL_Texture2D];
    [self setupGL_camera];
}


- (void)dealloc {
    if ([EAGLContext currentContext] == _context) {
        [EAGLContext setCurrentContext: nil];
    }
}


///设置背景色
-(void)setupGL_SetBackgroundColor{
    //创建 上下文对象
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!_context) {
        NSLog(@"create EAGLContext failed.");
        return;
    }
    //绑定当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"set EAGLContext failed.");
        return;
    }

    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.contentsScale = [UIScreen mainScreen].scale;

    //分配n个未使用的渲染缓存对象,将它存储到renderbuffers中, 返回的id不会为0 0是OpenGL ES 保留的
    GLuint renderbuffer[1];
    glGenRenderbuffers(ARRAY_SIZE(renderbuffer), renderbuffer);

    //创建并绑定渲染缓存。当第一次来绑定某个渲染缓存的时候，它会分配这个对象的存储空间并初始化，此后再调用这个函数的时候会将指定的渲染缓存对象绑定为当前的激活状态。
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer[0]);

    if (glIsRenderbuffer(renderbuffer[0]) == GL_TRUE) {
        NSLog(@"成功生成渲染缓存");
    }

    //释放渲染缓存
    //glDeleteRenderbuffers(ARRAY_SIZE(renderbuffer), renderbuffer);

    //为渲染缓冲分配空间
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];

    /*
     * 渲染缓冲 是OpenGL ES 管理的一块高效内存区域,它可以存储格式化的图像数据. 渲染缓冲中存储的数据只有关联到一个帧缓存对象才有意义 并且需要保证图像缓存格式必须与 OpenGL ES要求的渲染格式相符.(例如: 不能讲颜色值 渲染到 深度缓存中)
     */


    /*
     * 帧缓存它是屏幕所显示画面的一个直接映像,BitMap或光栅.帧缓存的每一存储单元对应屏幕上的每一个像素,整帧缓存 对应一帧图像.
     */

    //设置帧缓冲区(Frame Buffer)
    GLuint framebuffer[1];
    // 分配n个未使用的帧缓存对象,并将它存储到 framebuffers中
    glGenFramebuffers(ARRAY_SIZE(framebuffer), framebuffer);
    // 释放帧缓存对象
    //glDeleteFramebuffers(ARRAY_SIZE(framebuffer), framebuffer);

    //设置一个可读可写的帧缓存,当第一次来绑定某个帧缓存时,它会分配这个对象的存储地址并初始化,此后再调用该函数时会将指定的帧缓存对象绑定为当前的激活状态.
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer[0]);


    if (glIsFramebuffer(framebuffer[0]) == GL_TRUE) {
        NSLog(@"成功生成帧缓存");
    }

    //GL_COLOR_ATTACHMENT(0~i) ---> 第i个颜色缓存 0为默认值
    //GL_DEPTH_ATTACHMENT ---> 深度缓存
    //GL_STENCIL_ATTACHMENT ---> 模板缓存
    /*
     * 将相关buffer(三大buffer之一)依附(attach)到帧缓存上(如果renderbuffer不为0) 或从帧缓存上分离(detach).
     * 参数attachment 是指定 renderbuffer被装配到那个装配点上.
     */
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer[0]);

    //设置清屏颜色,默认为黑色 。
    glClearColor(1.0, 0, 0.0, 1.0);

    //清除缓存
    //GL_COLOR_BUFFER_BIT:    当前可写的颜色缓冲
    //GL_DEPTH_BUFFER_BIT:    深度缓冲
    //GL_ACCUM_BUFFER_BIT:    累积缓冲
    //GL_STENCIL_BUFFER_BIT:  模板缓冲
    glClear(GL_COLOR_BUFFER_BIT);

    //在典型的显示系统中,物理屏幕以固定的速率从帧缓冲区内存中更新,若我们直接绘制带帧缓冲区,那么用户在部分更新帧缓冲区时会看到伪像.
    //在OpenGL中采用双缓冲区, 分为 前缓冲区 和 后缓冲区.
    //所有的渲染都发生在后台缓冲区,它位于不可见于屏幕的内存区域
    //当所有渲染完成时,这个渲染将被 交换 到前台缓冲区用于显示, 然后原 前台缓冲区就下一帧的后台缓冲区
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


@end
