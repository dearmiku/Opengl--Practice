//
//  BoxWordView.m
//  箱子世界的探险
//
//  Created by MBP on 2017/12/1.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "BoxWordView.h"

#import "glm.hpp"   //这里需要将设置为运行C++ 不然会报错 'cmath' file not found, 因为它只能在C++环境
#import "matrix_transform.hpp"
#import "type_ptr.hpp"

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "GLUtil.h"
#define STB_IMAGE_IMPLEMENTATION
#import "stb_image.h"


EAGLContext* context;


GLuint renderBuf;
GLuint frameBuf;
GLuint depthBuf;
GLuint program;

unsigned int VBO,VAO;
unsigned int texture;
unsigned int texture1;

float speed = 1.5f;
float rotateSpeed = 0.015;

float abValue = 10.0f;
float rlValue = 0.0f;
float udValue = 0.0f;

glm::vec3 cameraLo = glm::vec3(10.0f,0.0f,0.0f);
glm::vec3 cameraDir = glm::vec3(1.0f,0.0f,0.0f);

@implementation BoxWordView

- (void)setupLinker{
    CADisplayLink *linker = [CADisplayLink displayLinkWithTarget:self selector:@selector(move)];
    linker.preferredFramesPerSecond = 24;
    [linker addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}


-(void)move{
    if (_isAdvance) {
        //cameraLo = glm::vec3(cameraLo[0]-speed/24,cameraLo[1],cameraLo[2]);
        cameraLo -=(cameraDir*(speed/24));
    }
    if (_isback) {
        cameraLo +=(cameraDir*(speed/24));
    }
    if (_isLeft) {
        cameraDir = glm::normalize(glm::vec3(cameraDir[0],cameraDir[1],cameraDir[2]-rotateSpeed));
    }
    if (_isRight) {
        cameraDir = glm::normalize(glm::vec3(cameraDir[0],cameraDir[1],cameraDir[2]+rotateSpeed));
    }
    if (_isUp) {
        cameraDir = glm::normalize(glm::vec3(cameraDir[0],cameraDir[1]-rotateSpeed,cameraDir[2]));
    }
    if (_isDown) {
        cameraDir = glm::normalize(glm::vec3(cameraDir[0],cameraDir[1]+rotateSpeed,cameraDir[2]));
    }
    [self render];
}


+(Class)layerClass{
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setUpGL];
    });
}


-(void)setUpGL{
    context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    BOOL isSetCOntextRight = [EAGLContext setCurrentContext:context];
    if (!isSetCOntextRight) {
        printf("设置Context失败");
    }

    NSString* verStr = [[NSBundle mainBundle] pathForResource:@"Texture2D_Vert.glsl" ofType:nil];
    NSString* fragStr = [[NSBundle mainBundle]pathForResource:@"Texture2D_Frag.glsl" ofType:nil];

    program = createGLProgramFromFile(verStr.UTF8String, fragStr.UTF8String);
    glUseProgram(program);


    glGenRenderbuffers(1, &renderBuf);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuf);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];


    int wi,he;
    //检索有关绑定缓冲区的对象的信息
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &wi);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &he);

    glGenRenderbuffers(1, &depthBuf);
    glBindRenderbuffer(GL_RENDERBUFFER, depthBuf);

    //为缓冲区分配内存 第一个必须是 GL_RENDERBUFFER 第二个是渲染格式 后面为渲染空间的尺寸
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, wi, he);


    glGenFramebuffers(1, &frameBuf);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuf);

    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, renderBuf);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuf);

    //最后需要再次绑定 否则没有内容显示
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuf);


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
    
    
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);

    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
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
    glUniform1i(glGetUniformLocation(program, "outTexture"), 0);
    
    
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
    
    glUniform1i(glGetUniformLocation(program, "outTexture1"), 1);

    glm::mat4 projection;
    //投影矩阵
    projection = glm::perspective(glm::radians(45.0f), (float)(self.bounds.size.width/self.bounds.size.height), 0.1f, 100.0f);

    //projection = glm::ortho(0.0f, 800.0f, 0.0f, 600.0f, 0.1f, 100.0f);

    glUniformMatrix4fv(glGetUniformLocation(program, "projection"), 1, GL_FALSE, glm::value_ptr(projection));

    [self render];
    [self setupLinker];
}


-(void)render{
    glEnable(GL_DEPTH_TEST);
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);


    glBindVertexArray(VAO);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);



    glm::mat4 view;
    //窗口矩阵 参数为 相机位置  相机对准目标位置 和 当前世界都上向量 为指向屏幕上方的向量
    view = glm::lookAt(cameraLo,cameraLo-cameraDir, glm::vec3(0.0, 1.0, 0.0));
    glUniformMatrix4fv(glGetUniformLocation(program, "view"), 1, GL_FALSE, glm::value_ptr(view));


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
        //模型矩阵
        glm::mat4 model;
        model = glm::translate(model, cubePositions[i]);
        float angle = 20.0f * i;
        model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
        glUniformMatrix4fv(glGetUniformLocation(program, "model"), 1, GL_FALSE, glm::value_ptr(model));

        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
    [context presentRenderbuffer:GL_RENDERBUFFER];
}


- (void)dealloc {
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext: nil];
    }
}

@end
