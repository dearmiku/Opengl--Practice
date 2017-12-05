#version 300 es

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;    //法向量
layout(location = 2) in vec2 texCoord;  //纹理坐标

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec3 outNormal; //法向量
out vec3 FragPo;    //顶点在世界坐标位置
out vec2 outTexCoord;//纹理坐标


void main()
{

    FragPo = vec3(model * vec4(position,1.0));
    outNormal = normal;
    outTexCoord = texCoord;
    //outNormal = mat3(transpose(inverse(model))) * normal;   //通过法线矩阵进行校正(当有不成比例缩放时)
    gl_Position = projection * view * model * vec4(position,1.0);
}
