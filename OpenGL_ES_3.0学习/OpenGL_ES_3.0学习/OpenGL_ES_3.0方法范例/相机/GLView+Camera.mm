//
//  GLView+Camera.m
//  OpenGL_ES_3.0学习
//
//  Created by MBP on 2017/11/30.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "GLView+Camera.h"

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "GLUtil.h"
#import "GLView.h"
#import "glm.hpp"
#import "matrix_transform.hpp"
#import "type_ptr.hpp"

#import "stb_image.h"



GLuint renderBuf3;
GLuint frameBuf3;
GLuint depBuf3;

GLuint program3;
unsigned int texture;
unsigned int texture1;

unsigned int VBO3,VAO3,EBO3;

@implementation GLView (Camera)

- (void)setupLinker
{
    CADisplayLink *linker = [CADisplayLink displayLinkWithTarget:self selector:@selector(render_camera)];
    linker.preferredFramesPerSecond = 24;
    [linker addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

-(void)setupGL_camera{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupGL_camera_render];
    });

}

-(void)setupGL_camera_render{

    //    GLuint renderBuf3;
    //    GLuint frameBuf3;
    //    GLuint depBuf3;
    //
    //    GLuint program3;
    //
    //    unsigned int VBO3,VAO3,EBO3;


    self.context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    BOOL isSetCOntextRight = [EAGLContext setCurrentContext:self.context];
    if (!isSetCOntextRight) {
        printf("设置Context失败");
    }

    NSString* verStr = [[NSBundle mainBundle] pathForResource:@"boxVert.glsl" ofType:nil];
    NSString* fragStr = [[NSBundle mainBundle]pathForResource:@"boxFrag.glsl" ofType:nil];

    program3 = createGLProgramFromFile(verStr.UTF8String, fragStr.UTF8String);
    glUseProgram(program3);

    //创建,绑定渲染缓存 并分配空间
    glGenRenderbuffers(1, &renderBuf3);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuf3);
    // 为 color renderbuffer 分配存储空间
    //需要在主线程
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];

    int wi,he;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &wi);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &he);

    glGenRenderbuffers(1, &depBuf3);
    glBindRenderbuffer(GL_RENDERBUFFER, depBuf3);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, wi, he);


    //创建,绑定帧缓存 并分配空间
    glGenFramebuffers(1, &frameBuf3);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuf3);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, renderBuf3);

    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depBuf3);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuf3);

    glEnable(GL_DEPTH_TEST);
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    //需要在主线程
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);


    float vertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,

        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,

        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,

        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,

        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };


    glGenVertexArrays(1, &VAO3);
    glGenBuffers(1, &VBO3);

    glBindVertexArray(VAO3);
    glBindBuffer(GL_ARRAY_BUFFER, VBO3);

    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)0);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 5*sizeof(float), (void*)(3*sizeof(float)));

    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(2);


    //因为使用 stbi 函数导入的图片会颠倒,所以需要将其摆正
    stbi_set_flip_vertically_on_load(true);

    NSString* imPath = [[NSBundle mainBundle] pathForResource:@"wall.jpg" ofType:nil];
    int width,height,nrChannels;

    //加载图片
    unsigned char * imdata = stbi_load(imPath.UTF8String, &width, &height, &nrChannels, 0);

    //创建 纹理

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
    glUniform1i(glGetUniformLocation(program3, "outTexture"), 0);


    //这里PNG格式 通过stbi_load 拉入时 会导致产生 BGRA格式(我也不大清楚原因,懂的朋友 告告我 先O(∩_∩)O谢谢了) ,这时 图片作为纹理显示时色彩会出错.所以将其转换一蛤~
    NSString* imPath1 = [[NSBundle mainBundle] pathForResource:@"face.png" ofType:nil];
    int width1,height1,nrChannels1;
    unsigned char * imdata1 = stbi_load(imPath1.UTF8String, &width1, &height1, &nrChannels1, STBI_rgb_alpha);
    for (int i = 0; i<width1*height1; i++ ) {
        char tR = imdata1[i*4+2];
        imdata1[i*4+2] = imdata1[i*4];
        imdata1[i*4] = tR;
    }



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

    glUniform1i(glGetUniformLocation(program3, "outTexture1"), 1);

    //
    //    glm::vec3 cameraPos = glm::vec3(0.0f,0.0f,0.3f);
    //    glm::vec3 cameraTarget = glm::vec3(0.0f,0.0f,0.0f);
    //    glm::vec3 cameraDir = glm::normalize(cameraPos-cameraTarget);

    //    //平行y轴的单位向量
    //    glm::vec3 up = glm::vec3(0.0f,1.0f,0.0f);
    //    glm:: vec3 cameraRight = glm::normalize(glm::cross(up, cameraDir));
    //
    //    glm::vec3 cameraUp = glm::cross(cameraDir, cameraRight);
    //    glm::mat4 view;
    //
    //    float radius = 10.0f;
    //    float camX = sin(CACurrentMediaTime()) * radius;
    //    float camZ = cos(CACurrentMediaTime()) * radius;
    //
    //    view = glm::lookAt(glm::vec3(camX, 0.0, camZ), glm::vec3(0.0, 0.0, 0.0), glm::vec3(0.0, 1.0, 0.0));

    glm::mat4 projection;
    projection = glm::perspective(glm::radians(45.0f), (float)(self.bounds.size.width/self.bounds.size.height), 0.1f, 100.0f);

    //
    //    glUniformMatrix4fv(glGetUniformLocation(program3, "view"), 1, GL_FALSE, glm::value_ptr(view));
    glUniformMatrix4fv(glGetUniformLocation(program3, "projection"), 1, GL_FALSE, glm::value_ptr(projection));

    //    glm::vec3 cubePositions[] = {
    //        glm::vec3( 0.0f,  0.0f,  0.0f),
    //        glm::vec3( 2.0f,  5.0f, -15.0f),
    //        glm::vec3(-1.5f, -2.2f, -2.5f),
    //        glm::vec3(-3.8f, -2.0f, -12.3f),
    //        glm::vec3( 2.4f, -0.4f, -3.5f),
    //        glm::vec3(-1.7f,  3.0f, -7.5f),
    //        glm::vec3( 1.3f, -2.0f, -2.5f),
    //        glm::vec3( 1.5f,  2.0f, -2.5f),
    //        glm::vec3( 1.5f,  0.2f, -1.5f),
    //        glm::vec3(-1.3f,  1.0f, -1.5f)
    //    };
    //    for(unsigned int i = 0; i < 10; i++)
    //    {
    //        glm::mat4 model;
    //        model = glm::translate(model, cubePositions[i]);
    //        float angle = 20.0f * i;
    //        model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
    //
    //
    //        glUniformMatrix4fv(glGetUniformLocation(program3, "model"), 1, GL_FALSE, glm::value_ptr(model));
    //
    //        glDrawArrays(GL_TRIANGLES, 0, 36);
    //        [self.context3 presentRenderbuffer:GL_RENDERBUFFER];
    //    }
    [self setupLinker];
}

-(void)render_camera{
    glEnable(GL_DEPTH_TEST);
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    glm::vec3 cameraPos = glm::vec3(0.0f,0.0f,0.3f);
    glm::vec3 cameraTarget = glm::vec3(0.0f,0.0f,0.0f);
    glm::vec3 cameraDir = glm::normalize(cameraPos-cameraTarget);

    //平行y轴的单位向量
    glm::vec3 up = glm::vec3(0.0f,1.0f,0.0f);
    glm:: vec3 cameraRight = glm::normalize(glm::cross(up, cameraDir));

    glm::vec3 cameraUp = glm::cross(cameraDir, cameraRight);
    glm::mat4 view;

    float radius = 10.0f;
    float camX = sin(CACurrentMediaTime()) * radius;
    float camZ = cos(CACurrentMediaTime()) * radius;

    view = glm::lookAt(glm::vec3(camX, 0.0, camZ), glm::vec3(0.0, 0.0, 0.0), glm::vec3(0.0, 1.0, 0.0));
    glUniformMatrix4fv(glGetUniformLocation(program3, "view"), 1, GL_FALSE, glm::value_ptr(view));

    glBindVertexArray(VAO3);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);

    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        glm::vec3 cubePositions[] = {
            glm::vec3( 0.0f,  0.0f,  0.0f),
            glm::vec3( 2.0f,  5.0f, -15.0f),
            glm::vec3(-1.5f, -2.2f, -2.5f),
            glm::vec3(-3.8f, -2.0f, -12.3f),
            glm::vec3( 2.4f, -0.4f, -3.5f),
            glm::vec3(-1.7f,  3.0f, -7.5f),
            glm::vec3( 1.3f, -2.0f, -2.5f),
            glm::vec3( 1.5f,  2.0f, -2.5f),
            glm::vec3( 1.5f,  0.2f, -1.5f),
            glm::vec3(-1.3f,  1.0f, -1.5f)
        };
        for(unsigned int i = 0; i < 10; i++)
        {
            glm::mat4 model;
            model = glm::translate(model, cubePositions[i]);
            float angle = 20.0f * i;
            model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));


            glUniformMatrix4fv(glGetUniformLocation(program3, "model"), 1, GL_FALSE, glm::value_ptr(model));

            glDrawArrays(GL_TRIANGLES, 0, 36);
        }
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
    });
}

@end
