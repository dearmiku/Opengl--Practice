//
//  GLView.h
//  OpenGL_ES_3.0学习
//
//  Created by MBP on 2017/11/23.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#define ARRAY_SIZE(array)       (sizeof(array) / sizeof(array[0]))

@interface GLView : UIView

@property(nonatomic,strong)EAGLContext* context;

@property(nonatomic,assign)GLuint program;

@end
