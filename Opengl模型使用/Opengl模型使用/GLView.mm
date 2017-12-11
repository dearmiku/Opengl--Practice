//
//  GLView.m
//  Opengl模型使用
//
//  Created by MBP on 2017/12/6.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "GLView.h"

#include "Model.cpp"
#include "assimp/Importer.hpp"
#include "assimp/scene.h"
#include "assimp/postprocess.h"

EAGLContext* context;

GLuint renderBuf;
GLuint frameBuf;
GLuint depthBuf;
GLuint program,lightPro;

GLuint lampVAO, VBO;


GLfloat vertices[] = {
    -0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    -0.5f,  0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,

    -0.5f, -0.5f,  0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,
    -0.5f, -0.5f,  0.5f,

    -0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    -0.5f, -0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,

    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,

    -0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f, -0.5f,  0.5f,
    -0.5f, -0.5f,  0.5f,
    -0.5f, -0.5f, -0.5f,

    -0.5f,  0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f, -0.5f,

};

glm::vec3 pointLightPositions[] = {
    glm::vec3 (0.7f,  0.2f,  2.0f),
    glm::vec3 (-4.0f,  2.0f, -2.0f),
};

@interface GLView()

@property Model* modelOb;

@end

@implementation GLView

-(void)setupGL{

    context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
    BOOL isSetCOntextRight = [EAGLContext setCurrentContext:context];
    if (!isSetCOntextRight) {
        printf("设置Context失败");
    }

    NSString* LightverStr = [[NSBundle mainBundle] pathForResource:@"lamp.vert" ofType:nil];
    NSString* LightfragStr = [[NSBundle mainBundle]pathForResource:@"lamp.frag" ofType:nil];

    NSString* modelVerStr = [[NSBundle mainBundle] pathForResource:@"model_loading.vert" ofType:nil];
    NSString* modelFragStr = [[NSBundle mainBundle]pathForResource:@"model_loading.frag" ofType:nil];

    lightPro = createGLProgramFromFile(LightverStr.UTF8String, LightfragStr.UTF8String);
    program = createGLProgramFromFile(modelVerStr.UTF8String, modelFragStr.UTF8String);
    
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


    NSString* objPath = [[NSBundle mainBundle] pathForResource:@"nanosuit.obj" ofType:nil];
    //NSString* objPath = [[NSBundle mainBundle] pathForResource:@"earth.obj" ofType:nil];


    static Model model1 = Model(objPath.UTF8String);


    self.modelOb = &model1;

    //Model ourModel(objPath.UTF8String);

    glEnable(GL_DEPTH_TEST);
    glClearColor(1.0, 0.0, 0.0, 1.0);


    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);



    glm::mat4 model;
    model = glm::translate (model, glm::vec3 (0.0f, 0.0f, 0.0f));
    model = glm::scale (model, glm::vec3 (0.2f, 0.2f, 0.2f));
    glUniformMatrix4fv(glGetUniformLocation(program, "model"), 1, GL_FALSE, glm::value_ptr(model));

    //    float radius = 10.0f;
    //    float camX = sin(CACurrentMediaTime()) * radius;
    //    float camZ = cos(CACurrentMediaTime()) * radius;
    //    glm::vec3 viewPo = glm::vec3(camX,camX,camZ);
    //    glm::mat4 view = glm::lookAt(glm::vec3(0.0f, 2.0f, 3.0f), glm::vec3(0.0f, 0.0f, 0.0f), glm::vec3(0.0f, 1.0f, 0.0f));
    //    glUniformMatrix4fv(glGetUniformLocation(program, "view"), 1, GL_FALSE, glm::value_ptr(view));


    glm::mat4 projection = glm::perspective(glm::radians(45.0f), (float)(self.bounds.size.width/self.bounds.size.height), 0.1f, 800.0f);
    glUniformMatrix4fv(glGetUniformLocation(program, "projection"), 1, GL_FALSE, glm::value_ptr(projection));


    // Point light 1
    glUniform3f (glGetUniformLocation (program, "pointLights[0].position"), pointLightPositions[0].x, pointLightPositions[0].y, pointLightPositions[0].z);
    glUniform3f (glGetUniformLocation (program, "pointLights[0].ambient"), 0.05f, 0.05f, 0.05f);
    glUniform3f (glGetUniformLocation (program, "pointLights[0].diffuse"), 1.0f, 1.0f, 1.0f);
    glUniform3f (glGetUniformLocation (program, "pointLights[0].specular"), 1.0f, 1.0f, 1.0f);
    glUniform1f (glGetUniformLocation (program, "pointLights[0].constant"), 1.0f);
    glUniform1f (glGetUniformLocation (program, "pointLights[0].linear"), 0.009);
    glUniform1f (glGetUniformLocation (program, "pointLights[0].quadratic"), 0.0032);
    // Point light 2
    glUniform3f (glGetUniformLocation (program, "pointLights[1].position"), pointLightPositions[1].x, pointLightPositions[1].y, pointLightPositions[1].z);
    glUniform3f (glGetUniformLocation (program, "pointLights[1].ambient"), 0.05f, 0.05f, 0.05f);
    glUniform3f (glGetUniformLocation (program, "pointLights[1].diffuse"), 1.0f, 1.0f, 1.0f);
    glUniform3f (glGetUniformLocation (program, "pointLights[1].specular"), 1.0f, 1.0f, 1.0f);
    glUniform1f (glGetUniformLocation (program, "pointLights[1].constant"), 1.0f);
    glUniform1f (glGetUniformLocation (program, "pointLights[1].linear"), 0.009);
    glUniform1f (glGetUniformLocation (program, "pointLights[1].quadratic"), 0.0032);

    //modelOb->Draw(program);


    glUseProgram(lightPro);

    glGenVertexArrays (1, &lampVAO);
    glGenBuffers (1, &VBO);
    glBindVertexArray (lampVAO);
    glBindBuffer (GL_ARRAY_BUFFER, VBO);
    glBufferData (GL_ARRAY_BUFFER, sizeof (vertices), vertices, GL_STATIC_DRAW);
    glVertexAttribPointer (0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof (GLfloat), (GLvoid*) 0);
    glEnableVertexAttribArray (0);
    glBindBuffer (GL_ARRAY_BUFFER, 0);

    //    glUniformMatrix4fv(glGetUniformLocation(lightPro, "view"), 1, GL_FALSE, glm::value_ptr(view));


    glUniformMatrix4fv(glGetUniformLocation(lightPro, "projection"), 1, GL_FALSE, glm::value_ptr(projection));


    [self setupLinker];
    //[self render];
}

-(void)render{
    glEnable(GL_DEPTH_TEST);
    glClearColor(1.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    //观察视角
    float radius = 5.0f;
    float camX = sin(CACurrentMediaTime()) * radius;
    float camZ = cos(CACurrentMediaTime()) * radius;
    glm::vec3 viewPo = glm::vec3(camX,camX,camZ);
    glm::mat4 view = glm::lookAt(viewPo, glm::vec3(0.0,0.0,0.0), glm::vec3(0.0,1.0,0.0));

//    glm::mat4 view = glm::lookAt(glm::vec3(0.0f, 2.5f, 1.5f), glm::vec3(0.0f, 2.5f, 0.0f), glm::vec3(0.0f, 1.0f, 0.0f));

    glUseProgram(lightPro);
    glBindVertexArray (lampVAO);

    glUniformMatrix4fv(glGetUniformLocation(lightPro, "view"), 1, GL_FALSE, glm::value_ptr(view));
    for (GLuint i = 0; i < 2; i++) {
        glm::mat4 model = glm::mat4 ();
        model = glm::translate (model, pointLightPositions[i]);
        model = glm::scale (model, glm::vec3 (0.3f, 0.3f, 0.3f)); // Downscale lamp object (a bit too large)
        glUniformMatrix4fv (glGetUniformLocation (lightPro, "model"), 1, GL_FALSE, glm::value_ptr (model));
        glDrawArrays (GL_TRIANGLES, 0, 36);
    }

    glUseProgram(program);
    glUniformMatrix4fv(glGetUniformLocation(program, "view"), 1, GL_FALSE, glm::value_ptr(view));
    
    self.modelOb->Draw(program);

    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupLinker{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CADisplayLink *linker = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
        linker.preferredFramesPerSecond = 12;
        [linker addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    });
}



+(Class)layerClass{
    return [CAEAGLLayer class];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupGL];
    });
}

- (void)dealloc {
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext: nil];
    }
}
@end
