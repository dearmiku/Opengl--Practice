#version 300 es

precision mediump float;


//uniform vec3 test;

//统一变量快
layout (std140) uniform colorBlock{
    vec4 cc;
};

layout (std140) uniform colorBlock1{
    vec4 cc1;
};


in vec3 outColor;

out vec4 FragColor;

void main()
{
    //FragColor = vec4(outColor.x,outColor.y,outColor.z, 1.0);
    FragColor = cc+cc1;
}
