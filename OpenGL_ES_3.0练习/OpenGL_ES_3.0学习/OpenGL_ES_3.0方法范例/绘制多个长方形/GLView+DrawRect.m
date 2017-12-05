//
//  GLView+DrawRect.m
//  OpenGL_ES_3.0学习
//
//  Created by MBP on 2017/11/24.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "GLView+DrawRect.h"
#import "GLView.h"

@implementation GLView (DrawRect)

-(void)setupGL_SetRect{

    CAEAGLLayer* glLayer = (CAEAGLLayer *)self.layer;
    glLayer.contentsScale = [UIScreen mainScreen].scale;

    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];

    //创建一个帧缓冲缓冲对象
    GLuint renderbuffer;
    glGenRenderbuffers(1, &renderbuffer);

    //绑定至当前的帧缓冲
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:glLayer];

    GLint renderbufferWidth, renderbufferHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &renderbufferWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &renderbufferHeight);



    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);

    char *vertexShaderContent =
    "#version 300 es \n"
    "layout(location = 0) in vec4 position; "
    "layout(location = 1) in float point_size; "
    "void main() { "
    "gl_Position = position; "
    "gl_PointSize = point_size;"
    "}";
    GLuint vertexShader = compileShader(vertexShaderContent, GL_VERTEX_SHADER);

    char *fragmentShaderContent =
    "#version 300 es \n"
    "precision highp float; "
    "out vec4 fragColor; "
    "void main() { "
    "fragColor = vec4(1.0, 0.0, 1.0, 1.0);"
    "}";
    GLuint fragmentShader = compileShader(fragmentShaderContent, GL_FRAGMENT_SHADER);

    GLuint program = glCreateProgram();
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);

    glLinkProgram(program);
    GLint linkStatus;
    glGetProgramiv(program, GL_LINK_STATUS, &linkStatus);
    if (linkStatus == GL_FALSE) {
        GLint infoLength;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 0) {
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLength);
            glGetProgramInfoLog(program, infoLength, NULL, infoLog);
            printf("%s\n", infoLog);
            free(infoLog);
        }
    }

    glUseProgram(program);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glClearColor(1, 1, 1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    glViewport(0, 0, renderbufferWidth, renderbufferHeight);

    GLfloat vertex[2];
    GLfloat size[] = {50.f};
    for (GLfloat i = -0.9; i <= 1.0; i += 0.25f, size[0] += 20) {
        vertex[0] = i;
        vertex[1] = 0.f;

        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 2/* 坐标分量个数 */, GL_FLOAT, GL_FALSE, 0, vertex);

        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 1, GL_FLOAT, GL_FALSE, 0, size);

        glDrawArrays(GL_POINTS, 0, 1);
    }

    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

GLuint compileShader(char *shaderContent, GLenum shaderType) {
    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &shaderContent, NULL);
    glCompileShader(shader);

    GLint compileStatus;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
    if (compileStatus == GL_FALSE) {
        GLint infoLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength);
        if (infoLength > 0) {
            GLchar *infoLog = malloc(sizeof(GLchar) * infoLength);
            glGetShaderInfoLog(shader, infoLength, NULL, infoLog);
            printf("%s -> %s\n", shaderType == GL_VERTEX_SHADER ? "vertex shader" : "fragment shader", infoLog);
            free(infoLog);
        }
    }
    return shader;
}


@end
