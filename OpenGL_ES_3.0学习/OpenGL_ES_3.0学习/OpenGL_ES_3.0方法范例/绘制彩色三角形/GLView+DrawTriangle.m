//
//  GLView+DrawTriangle.m
//  OpenGL_ES_3.0学习
//
//  Created by MBP on 2017/11/24.
//  Copyright © 2017年 leqi. All rights reserved.
//

#import "GLView+DrawTriangle.h"
#import "GLView.h"
#import "GLUtil.h"


CAEAGLLayer     *_eaglLayer;
EAGLContext     *_context;
GLuint          _colorRenderBuffer;
GLuint          _frameBuffer;

GLuint          _program;

unsigned int VBO,VAO,EBO;

GLuint blockid,bufferid;
GLint blocksize;
GLint point = 1;

GLuint blockid1,bufferid1;
GLint blocksize1;
GLint point1 = 2;

@implementation GLView (DrawTriangle)
    
    
-(void)setupGL_Triangle{
    
    //配置图层
    [self setupLayer];
    //配置上下文
    [self setupContext];
    //配置程序对象
    [self setupGLProgram];
    
    
    [EAGLContext setCurrentContext:_context];
    
    //清除原来的渲染缓存 和 帧缓存
    [self destoryRenderAndFrameBuffer];
    
    //配置渲染缓存 和 帧缓存
    [self setupFrameAndRenderBuffer];
    
    [self render];
}
    
    
    
- (void)setupLayer
    {
        _eaglLayer = (CAEAGLLayer*) self.layer;
        
        // CALayer 默认是透明的，必须将它设为不透明才能让其可见
        _eaglLayer.opaque = YES;

        // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
        _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    }
    
- (void)setupContext
    {
        // 设置OpenGLES的版本为2.0 当然还可以选择1.0和最新的3.0的版本，以后我们会讲到2.0与3.0的差异.
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        if (!_context) {
            return;
        }
        
        // 将当前上下文设置为我们创建的上下文
        if (![EAGLContext setCurrentContext:_context]) {
            return;
        }
    }
    
- (void)setupFrameAndRenderBuffer
    {
        //创建,绑定渲染缓存 并分配空间
        glGenRenderbuffers(1, &_colorRenderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
        // 为 color renderbuffer 分配存储空间
        [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
        
        //创建,绑定帧缓存 并分配空间
        glGenFramebuffers(1, &_frameBuffer);
        // 设置为当前 framebuffer
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                                  GL_RENDERBUFFER, _colorRenderBuffer);
    }
    
- (void)setupGLProgram
    {
        NSString *vertFile = [[NSBundle mainBundle] pathForResource:@"vert.glsl" ofType:nil];
        NSString *fragFile = [[NSBundle mainBundle] pathForResource:@"frag.glsl" ofType:nil];
        
        //获取配置好的程序对象
        _program = createGLProgramFromFile(vertFile.UTF8String, fragFile.UTF8String);
        
        //将程序对象设置为活跃状态
        glUseProgram(_program);
    }
    
- (void)setupVertexData
    {
        // 需要加static关键字,出了作用域 数据会被回收(所以还是在下面注释的方法里写吧)
        
        //三角形的三点坐标+颜色坐标
        static GLfloat vertices[] = {
            //点坐标                     //颜色
            0.5f,  0.5f, 0.0f,          1.0f, 0.0f, 0.0f,
            0.5f, -0.5f, 0.0f,          0.0f, 1.0f, 0.0f,
            -0.5f, -0.5f, 0.0f,         0.0f, 0.0f, 1.0f,
            -0.5f, 0.5f, 0.0f,          1.0f, 0.0f, 1.0f
        };
        
        static unsigned int indices[] = {
            0,1,3,
            1,2,3
        };
        
        //获取顶点属性的入口
        //GLint posSlot = glGetAttribLocation(_program, "position");//获得顶点着色器中的 position属性的index.
        
        //    glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
        //    indx 指定要修改的顶点着色器中顶点变量id；
        //    size 指定每个顶点属性的组件数量。必须为1、2、3或者4。
        //    type 指定数组中每个组件的数据类型。可用的符号常量有GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT,GL_UNSIGNED_SHORT, GL_FIXED, 和 GL_FLOAT，初始值为GL_FLOAT；
        //    normalized 指定当被访问时，固定点数据值是否应该被归一化（GL_TRUE）或者直接转换为固定点值（GL_FALSE）；
        //    stride 指定连续顶点属性之间的偏移量。如果为0，那么顶点属性会被理解为：它们是紧密排列在一起的。初始值为0；
        //    ptr 顶点数据指针。
        //glVertexAttribPointer(posSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
        
        //处于性能考虑 所有地点着色器的属性变量都是关闭的(就是在着色器端是不可见的)只有启用了指定属性 着色器才能读取
        //glEnableVertexAttribArray(posSlot);



        GLfloat blockData[] = {
            1.0f,0.0f,1.0f,1.0f
        };

        blockid = glGetUniformBlockIndex(_program, "colorBlock");
        glGetActiveUniformBlockiv(_program, blockid, GL_UNIFORM_BLOCK_DATA_SIZE, &blocksize);
        glUniformBlockBinding(_program, blockid, point);

        glGenBuffers(1, &bufferid);
        glBindBuffer(GL_UNIFORM_BUFFER, bufferid);

        glBufferData(GL_UNIFORM_BUFFER, blocksize, blockData, GL_DYNAMIC_DRAW);
        glBindBufferBase(GL_UNIFORM_BUFFER, point, bufferid);


        GLfloat blockData1[] = {
            0.0f,1.0f,0.0f,0.0f
        };

        blockid1 = glGetUniformBlockIndex(_program, "colorBlock1");
        glGetActiveUniformBlockiv(_program, blockid1, GL_UNIFORM_BLOCK_DATA_SIZE, &blocksize1);
        glUniformBlockBinding(_program, blockid1, point1);

        glGenBuffers(1, &bufferid1);
        glBindBuffer(GL_UNIFORM_BUFFER, bufferid1);

        glBufferData(GL_UNIFORM_BUFFER, blocksize1, blockData1, GL_DYNAMIC_DRAW);
        glBindBufferBase(GL_UNIFORM_BUFFER, point1, bufferid1);




        glGenVertexArrays(1, &VAO);
        glGenBuffers(1, &VBO);
        glGenBuffers(1, &EBO);
        
        glBindVertexArray(VAO);

        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
        
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), (void*)0);
        glEnableVertexAttribArray(0);
        
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), (void*)(3*sizeof(float)));
        glEnableVertexAttribArray(1);


    }
    
#pragma mark - Clean
- (void)destoryRenderAndFrameBuffer
    {
        glDeleteFramebuffers(1, &_frameBuffer);
        _frameBuffer = 0;
        glDeleteRenderbuffers(1, &_colorRenderBuffer);
        _colorRenderBuffer = 0;
    }
    
#pragma mark - Render
- (void)render
    {
        //设置清屏颜色
        glClearColor(1.0, 0.0, 0.0, 1.0);
        //清除缓存
        glClear(GL_COLOR_BUFFER_BIT);
        
        //设置窗口,通知设置用于绘制2d渲染表面的位置
        //参数: 显示坐标(x,y)  宽度   高度
        glViewport(0, 0, self.frame.size.width, self.frame.size.height);
        
        //加载集合形状和绘制图元
        [self setupVertexData];

//        统一变量赋值
//        int vertexColorLocation = glGetUniformLocation(_program, "test");
//        glUniform3f(vertexColorLocation, 0.0f, 1.0f, 0.0f);





        GLfloat uploadData[] = {
            0.0f,0.0f,1.0f,1.0f
        };

        glBindBuffer(GL_UNIFORM_BUFFER, bufferid);
        const GLchar *names[] = {"cc"};
        GLuint indices[1];
        glGetUniformIndices(_program, 1, names, indices);
        GLint offset[1];
        glGetActiveUniformsiv(_program, 1, indices, GL_UNIFORM_OFFSET, offset);
        glBufferSubData(GL_UNIFORM_BUFFER, offset[0], blocksize, uploadData);


        glDrawElements(GL_TRIANGLE_FAN, 6, GL_UNSIGNED_INT, 0);

        
        //将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。
        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    
    
    
    @end
