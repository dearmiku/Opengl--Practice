#version 300 es

layout(location = 0) in vec3 position;

layout(location = 2) in vec2 texCoord;  //纹理坐标

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;



out vec2 outTexCoord;

void main()
{
    gl_Position = projection * view * model * vec4(position,1.0);

    outTexCoord = texCoord;
}
