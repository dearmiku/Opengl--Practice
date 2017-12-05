//
//  GLView.m
//  Opengl_Light_光照
//
//  Created by MBP on 2017/12/4.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "GLView.h"

//#import "glm.hpp"   //这里需要将设置为运行C++ 不然会报错 'cmath' file not found, 因为它只能在C++环境
//#import "matrix_transform.hpp"
//#import "type_ptr.hpp"
//
//#import <OpenGLES/ES3/gl.h>
//#import <OpenGLES/ES3/glext.h>
//#import "GLUtil.h"
//
//#define STB_IMAGE_IMPLEMENTATION
//#import "stb_image.h"
//
//
//EAGLContext* context;
//
//
//GLuint renderBuf;
//GLuint frameBuf;
//GLuint depthBuf;
//GLuint program,lightProgram;
//
////光源位置
//glm::vec3 lightPo = glm::vec3(1.2f,1.0f,2.0f);
//
//unsigned int VBO,VAO,lightVAO;


@implementation GLView

-(void)setupGL{
//    //self.layer.contentsScale = [UIScreen mainScreen].scale;
//
//
//
//    context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
//    BOOL isSetCOntextRight = [EAGLContext setCurrentContext:context];
//    if (!isSetCOntextRight) {
//        printf("设置Context失败");
//    }
//
//    NSString* verStr = [[NSBundle mainBundle] pathForResource:@"Texture2D_Vert.glsl" ofType:nil];
//    NSString* fragStr = [[NSBundle mainBundle]pathForResource:@"Texture2D_Frag.glsl" ofType:nil];
//    NSString* lightFragStr = [[NSBundle mainBundle]pathForResource:@"Light_Frag.glsl" ofType:nil];
//
//    program = createGLProgramFromFile(verStr.UTF8String, fragStr.UTF8String);
//    lightProgram = createGLProgramFromFile(verStr.UTF8String, lightFragStr.UTF8String);
//
//    glUseProgram(program);
//
//
//    glGenRenderbuffers(1, &renderBuf);
//    glBindRenderbuffer(GL_RENDERBUFFER, renderBuf);
//    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
//
//
//    int wi,he;
//    //检索有关绑定缓冲区的对象的信息
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &wi);
//    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &he);
//
//    glGenRenderbuffers(1, &depthBuf);
//    glBindRenderbuffer(GL_RENDERBUFFER, depthBuf);
//
//    //为缓冲区分配内存 第一个必须是 GL_RENDERBUFFER 第二个是渲染格式 后面为渲染空间的尺寸
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, wi, he);
//
//
//    glGenFramebuffers(1, &frameBuf);
//    glBindFramebuffer(GL_FRAMEBUFFER, frameBuf);
//
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
//                              GL_RENDERBUFFER, renderBuf);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuf);
//
//    //最后需要再次绑定 否则没有内容显示
//    glBindRenderbuffer(GL_RENDERBUFFER, renderBuf);
//
//
//    float vertices[] = {
//        //顶点位置              //法线               //纹理坐标
//        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f,  0.0f,
//        0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f,  0.0f,
//        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f,  1.0f,
//        0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f,  1.0f,
//        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f,  1.0f,
//        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f,  0.0f,
//
//        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  0.0f,
//        0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  1.0f,  0.0f,
//        0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  1.0f,  1.0f,
//        0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  1.0f,  1.0f,
//        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  1.0f,
//        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,  0.0f,  0.0f,
//
//        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
//        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  1.0f,  1.0f,
//        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
//        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
//        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  0.0f,  0.0f,
//        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
//
//        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
//        0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  1.0f,  1.0f,
//        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
//        0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,  0.0f,  1.0f,
//        0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  0.0f,  0.0f,
//        0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,  1.0f,  0.0f,
//
//        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f,  1.0f,
//        0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  1.0f,  1.0f,
//        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f,  0.0f,
//        0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  1.0f,  0.0f,
//        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,  0.0f,  0.0f,
//        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,  0.0f,  1.0f,
//
//        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  1.0f,
//        0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  1.0f,  1.0f,
//        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f,  0.0f,
//        0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  1.0f,  0.0f,
//        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  0.0f,
//        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,  0.0f,  1.0f
//    };
//
//    stbi_set_flip_vertically_on_load(true);
//
//    NSString* texturePath = [[NSBundle mainBundle] pathForResource:@"Box.png" ofType:nil];
//    int width_tex,height_tex,nrChannels_tex;
//    unsigned char * textureData = stbi_load(texturePath.UTF8String, &width_tex, &height_tex, &nrChannels_tex, STBI_rgb_alpha);
//    for (int i = 0; i<width_tex*height_tex; i++ ) {
//        char tR = textureData[i*4+2];
//        textureData[i*4+2] = textureData[i*4];
//        textureData[i*4] = tR;
//    }
//
//    NSString* texture_specular_Path = [[NSBundle mainBundle] pathForResource:@"Box_specular.png" ofType:nil];
//    int width_specular,height_specular,nrChannels_specular;
//    unsigned char * texture_specular_Data = stbi_load(texture_specular_Path.UTF8String, &width_specular, &height_specular, &nrChannels_specular, STBI_rgb_alpha);
//    for (int i = 0; i<width_specular*height_specular; i++ ) {
//        char tR = texture_specular_Data[i*4+2];
//        texture_specular_Data[i*4+2] = texture_specular_Data[i*4];
//        texture_specular_Data[i*4] = tR;
//    }
//    unsigned int texture;
//    unsigned int texture_specular;
//
//    glGenTextures(1, &texture);
//    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, texture);
//    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_tex, height_tex, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
//
//    glGenerateMipmap(GL_TEXTURE_2D);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
//
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    stbi_image_free(textureData);
//    glUniform1i(glGetUniformLocation(program, "Material.Texture"), 0);
//
//
//    glGenTextures(1, &texture_specular);
//    glActiveTexture(GL_TEXTURE1);
//    glBindTexture(GL_TEXTURE_2D, texture_specular);
//    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width_specular, height_specular, 0, GL_RGBA, GL_UNSIGNED_BYTE, texture_specular_Data);
//
//    glGenerateMipmap(GL_TEXTURE_2D);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
//
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//    stbi_image_free(texture_specular_Data);
//    glUniform1i(glGetUniformLocation(program, "Material.specularTexture"), 0);
//
//
//
//
//
//    glGenVertexArrays(1, &VAO);
//    glGenBuffers(1, &VBO);
//    glBindVertexArray(VAO);
//    glBindBuffer(GL_ARRAY_BUFFER, VBO);
//
//    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//
//    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)0);
//    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)(3*sizeof(float)));
//    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)(6*sizeof(float)));
//
//    glEnableVertexAttribArray(0);
//    glEnableVertexAttribArray(1);
//    glEnableVertexAttribArray(2);
//
//    glGenVertexArrays(1, &lightVAO);
//    glBindVertexArray(lightVAO);
//    glBindBuffer(GL_ARRAY_BUFFER, VBO); //使用相同的VBO
//    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8*sizeof(float), (void*)0);
//    glEnableVertexAttribArray(0);
//
//    [self setupLinker];
//
//}
//
//-(void)render{
//
//    //绘制箱子程序激活
//    glUseProgram(program);
//    glEnable(GL_DEPTH_TEST);
//    glClearColor(1.0, 0.0, 0.0, 1.0);
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
//
//    glBindVertexArray(VAO);
//
//    glUniform3f(glGetUniformLocation(program, "lightColor"), 1.0f, 1.0f, 1.0f);
//    //glUniform3f(glGetUniformLocation(program, "objectColor"), 1.0f, 0.5f, 0.31f); //物体色
//
//    glm::mat4 projection = glm::perspective(glm::radians(45.0f), (float)(self.bounds.size.width/self.bounds.size.height), 0.1f, 800.0f);
//    glUniformMatrix4fv(glGetUniformLocation(program, "projection"), 1, GL_FALSE, glm::value_ptr(projection));
//
//
//    float radius = 10.0f;
//    float camX = sin(CACurrentMediaTime()) * radius;
//    float camZ = cos(CACurrentMediaTime()) * radius;
//    glm::vec3 viewPo = glm::vec3(camX,camX,camZ);
//    glm::mat4 view = glm::lookAt(viewPo, glm::vec3(0.0,0.0,0.0), glm::vec3(0.0,1.0,0.0));
//    glUniformMatrix4fv(glGetUniformLocation(program, "view"), 1, GL_FALSE, glm::value_ptr(view));
//
//
//
//    glUniform3f(glGetUniformLocation(program, "lightPo"), lightPo.x, lightPo.y, lightPo.z);
//    glUniform3f(glGetUniformLocation(program, "viewPo"), viewPo.x, viewPo.y, viewPo.z);
//
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
//    for (unsigned int i = 0; i < 10; i++)
//    {
//        // calculate the model matrix for each object and pass it to shader before drawing
//        glm::mat4 model;
//        model = glm::translate(model, cubePositions[i]);
//        float angle = 20.0f * i;
//        model = glm::rotate(model, glm::radians(angle), glm::vec3(1.0f, 0.3f, 0.5f));
//        glUniformMatrix4fv(glGetUniformLocation(program, "model"), 1, GL_FALSE, glm::value_ptr(model));
//
//        glDrawArrays(GL_TRIANGLES, 0, 36);
//    }
//
//    //glm::transpose(glm::inverse(model));
//
//
//    //切换至 光照程序
//    glUseProgram(lightProgram); //不能让两个程序对象同事生效
//    glBindVertexArray(lightVAO);
//
//    glm::mat4 model = glm::mat4();
//    model = glm::translate(model, lightPo);
//    model = glm::scale(model, glm::vec3(0.2f));
//    glUniformMatrix4fv(glGetUniformLocation(lightProgram, "model"), 1, GL_FALSE, glm::value_ptr(model));
//
//    glDrawArrays(GL_TRIANGLES, 0, 36);
//    [context presentRenderbuffer:GL_RENDERBUFFER];
//}
//
//
//- (void)setupLinker
//{
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        CADisplayLink *linker = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
//        linker.preferredFramesPerSecond = 24;
//        [linker addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
//        //[self render];
//    });
//}
//
//+(Class)layerClass{
//    return [CAEAGLLayer class];
//}
//-(void)layoutSubviews{
//    [super layoutSubviews];
//    [self setupGL];
//}
//
//- (void)dealloc {
//    if ([EAGLContext currentContext] == context) {
//        [EAGLContext setCurrentContext: nil];
//    }
}
@end
