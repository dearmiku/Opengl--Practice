//
//  GLView+Texture2D.m
//  OpenGL_ES_3.0学习
//
//  Created by MBP on 2017/11/28.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "GLView+Texture2D.h"
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "GLUtil.h"

#define STB_IMAGE_IMPLEMENTATION
#import "stb_image.h"



EAGLContext* context1;


GLuint renderBuf1;
GLuint frameBuf1;

GLuint program1;

unsigned int VBO1,VAO1,EBO1;

@implementation GLView (Texture2D)



-(void)setupGL_Texture2D{

    context1 = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    BOOL isSetCOntextRight = [EAGLContext setCurrentContext:context1];
    if (!isSetCOntextRight) {
        printf("设置Context失败");
    }

    NSString* verStr = [[NSBundle mainBundle] pathForResource:@"Texture2D_Vert.glsl" ofType:nil];
    NSString* fragStr = [[NSBundle mainBundle]pathForResource:@"Texture2D_Frag.glsl" ofType:nil];

    program1 = createGLProgramFromFile(verStr.UTF8String, fragStr.UTF8String);
    glUseProgram(program1);

    //创建,绑定渲染缓存 并分配空间
    glGenRenderbuffers(1, &renderBuf1);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuf1);
    // 为 color renderbuffer 分配存储空间
    [context1 renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];

    //创建,绑定帧缓存 并分配空间
    glGenFramebuffers(1, &frameBuf1);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuf1);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, renderBuf1);


    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);



    float verData[] = {
        // 位置              颜色                 纹理坐标
        0.5f,0.5f,0.0f,     1.0f,0.0f,0.0f,     1.0f,1.0f,
        0.5f,-0.5f,0.0f,    0.0f,1.0f,0.0f,     1.0f,0.0f,
        -0.5f,-0.5f,0.0f,   0.0f,0.0f,1.0f,     0.0f,0.0f,
        -0.5f,0.5f,0.0f,    1.0f,1.0f,0.0f,     0.0f,1.0f,
    };
    unsigned int indices[] = {
        0,1,3,
        1,2,3
    };




    glGenVertexArrays(1, &VAO1);
    glGenBuffers(1, &VBO1);
    glGenBuffers(1, &EBO1);

    glBindVertexArray(VAO1);
    glBindBuffer(GL_ARRAY_BUFFER, VBO1);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO1);

    glBufferData(GL_ARRAY_BUFFER, sizeof(verData), verData, GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)(3*sizeof(float)));
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)(6*sizeof(float)));

    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glEnableVertexAttribArray(2);

    stbi_set_flip_vertically_on_load(true);
    
    NSString* imPath = [[NSBundle mainBundle] pathForResource:@"wall.jpg" ofType:nil];
    int width,height,nrChannels;
    unsigned char * imdata = stbi_load(imPath.UTF8String, &width, &height, &nrChannels, 0);

    unsigned int texture;
    glGenTextures(1, &texture);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, imdata);

    glGenerateMipmap(GL_TEXTURE_2D);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
 
    stbi_image_free(imdata);
    glUniform1i(glGetUniformLocation(program1, "outTexture"), 0);


    
    
    
    
    NSString* imPath1 = [[NSBundle mainBundle] pathForResource:@"face.png" ofType:nil];
    int width1,height1,nrChannels1;
    unsigned char * imdata1 = stbi_load(imPath1.UTF8String, &width1, &height1, &nrChannels1, STBI_rgb_alpha);
    for (int i = 0; i<width1*height1; i++ ) {
        char tR = imdata1[i*4+2];
        imdata1[i*4+2] = imdata1[i*4];
        imdata1[i*4] = tR;
    }

    unsigned int texture1;

    glGenTextures(1, &texture1);
    glActiveTexture(GL_TEXTURE1);       //必须先写这个再绑定
    glBindTexture(GL_TEXTURE_2D, texture1);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width1, height1, 0, GL_RGBA, GL_UNSIGNED_BYTE, imdata1);
    glGenerateMipmap(GL_TEXTURE_2D);
    stbi_image_free(imdata1);
    
    glUniform1i(glGetUniformLocation(program1, "outTexture1"), 1);

    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    [context1 presentRenderbuffer:GL_RENDERBUFFER];

}


@end
