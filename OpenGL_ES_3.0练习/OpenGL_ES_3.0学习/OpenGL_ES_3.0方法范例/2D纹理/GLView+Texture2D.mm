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

#import "glm.hpp"
#import "matrix_transform.hpp"
#import "type_ptr.hpp"



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
    //需要在主线程
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

    //需要在主线程
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


    //因为使用 stbi 函数导入的图片会颠倒,所以需要将其摆正
    stbi_set_flip_vertically_on_load(true);
    
    NSString* imPath = [[NSBundle mainBundle] pathForResource:@"wall.jpg" ofType:nil];
    int width,height,nrChannels;

    //加载图片
    unsigned char * imdata = stbi_load(imPath.UTF8String, &width, &height, &nrChannels, 0);

    //创建 纹理
    unsigned int texture;
    glGenTextures(1, &texture);

    //激活纹理单元0
    glActiveTexture(GL_TEXTURE0);
    //绑定纹理
    glBindTexture(GL_TEXTURE_2D, texture);
    //将图像传入纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, imdata);

    //glGenerateMipmap(GL_TEXTURE_2D);

    //设置纹理环绕和纹理过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    //将不用的图像释放
    stbi_image_free(imdata);


    //将纹理作为统一变量传入显存
    glUniform1i(glGetUniformLocation(program1, "outTexture"), 0);


    //这里PNG格式 通过stbi_load 拉入时 会导致产生 BGRA格式(我也不大清楚原因,懂的朋友 告告我 先O(∩_∩)O谢谢了) ,这时 图片作为纹理显示时色彩会出错.所以将其转换一蛤~
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


    //    glm::mat4 transform;
    //    transform = glm::translate(transform, glm::vec3(0.5f,-0.5f,0.0f));
    //    transform = glm::rotate(transform, 0.5f, glm::vec3(0.0f,0.0f,1.0f));    //都得是float类型 不然会爆方法找不到
    //    unsigned int loTrans = glGetUniformLocation(program1, "transform");
    //    glUniformMatrix4fv(loTrans, 1, GL_FALSE, glm::value_ptr(transform));


    glm::mat4 model;
    model = glm::rotate(model, glm::radians(-55.0f), glm::vec3(1.0f,0.0f,0.0f));
    glm::mat4 view;
    view = glm::translate(view, glm::vec3(0.0f,0.0f,-3.0f));
    glm::mat4 projection;
    projection = glm::perspective(glm::radians(45.0f), (float)(self.bounds.size.width/self.bounds.size.height), 0.1f, 100.0f);

    glUniformMatrix4fv(glGetUniformLocation(program1, "model"), 1, GL_FALSE, glm::value_ptr(model));
    glUniformMatrix4fv(glGetUniformLocation(program1, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(program1, "projection"), 1, GL_FALSE, glm::value_ptr(projection));

    //绘制显示
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

    [context1 presentRenderbuffer:GL_RENDERBUFFER];
    


}


@end
