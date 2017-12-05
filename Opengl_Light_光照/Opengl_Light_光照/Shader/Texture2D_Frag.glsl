#version 300 es

precision mediump float;

out vec4 FragColor;

uniform vec3 lightColor;    //光源颜色
uniform vec3 lightPo;       //光源位置

uniform vec3 viewPo;        //视角位置

uniform sampler2D Texture;          //物体纹理
uniform sampler2D specularTexture;  //镜面纹理


in vec2 outTexCoord;    //纹理坐标
in vec3 outNormal;      //顶点法向量
in vec3 FragPo;         //顶点坐标

//点光源版本
void pointLight(){
    float ambientStrength = 0.3;    //环境因子
    float specularStrength = 2.0;
    float reflectance = 256.0;

    float constantPara = 1.0f;    //常亮
    float linearPara = 0.09f;     //线性部分因数
    float quadraticPara = 0.032f; //二次项部分因数

    //环境光
    vec3 ambient = ambientStrength * texture(Texture,outTexCoord).rgb;

    //漫反射
    vec3 norm = normalize(outNormal);
    vec3 lightDir = normalize(lightPo - FragPo);    //当前顶点 至 光源的的单位向量

    //点光源
    float diff = max(dot(norm,lightDir),0.0);   //光源与法线夹角
    vec3 diffuse = diff * lightColor*texture(Texture,outTexCoord).rgb;

    //镜面反射
    vec3 viewDir = normalize(viewPo - FragPo);
    vec3 reflectDir = reflect(-lightDir,outNormal);

    float spec = pow(max(dot(viewDir, reflectDir),0.0),reflectance);
    vec3 specular = specularStrength * spec * texture(specularTexture,outTexCoord).rgb;

    float LFDistance = length(lightPo - FragPo);
    float lightWeakPara = 1.0/(constantPara + linearPara * LFDistance + quadraticPara * (LFDistance*LFDistance));

    vec3 res = (ambient + diffuse + specular)*lightWeakPara;

    FragColor = vec4(res,1.0);

}


// 平行光版本
void parallelLight(){
    float ambientStrength = 0.3;    //环境因子
    float specularStrength = 2.0;
    float reflectance = 256.0;

    //平行光方向
    vec3 paraLightDir = normalize(vec3(-0.2,-1.0,-0.3));

    //环境光
    vec3 ambient = ambientStrength * texture(Texture,outTexCoord).rgb;

    //漫反射
    vec3 norm = normalize(outNormal);
    vec3 lightDir = normalize(lightPo - FragPo);    //当前顶点 至 光源的的单位向量

    //平行光版本
    float diff = max(dot(norm,paraLightDir),0.0);

    vec3 diffuse = diff * lightColor*texture(Texture,outTexCoord).rgb;

    //镜面反射
    vec3 viewDir = normalize(viewPo - FragPo);


    //平行光版本
    vec3 reflectDir = reflect(-paraLightDir,outNormal);

    float spec = pow(max(dot(viewDir, reflectDir),0.0),reflectance);
    vec3 specular = specularStrength * spec * texture(specularTexture,outTexCoord).rgb;

    float constantPara = 1.0f;
    float linearPara = 0.09f;
    float quadraticPara = 0.032f;

    float LFDistance = length(lightPo - FragPo);
    float lightWeakPara = 1.0/(constantPara + linearPara * LFDistance + quadraticPara * (LFDistance*LFDistance));

    vec3 res = ambient + diffuse + specular;

    FragColor = vec4(res,1.0);
}

//聚光版本
void Spotlight(){
    float ambientStrength = 0.3;    //环境因子
    float specularStrength = 2.0;
    float reflectance = 256.0;

    float constantPara = 1.0f;    //常亮
    float linearPara = 0.09f;     //线性部分因数
    float quadraticPara = 0.032f; //二次项部分因数

    //聚光灯切角 (一些复杂的计算操作 应该让CPU做,提高效率,不变的量也建议外部传输,避免重复计算)
    float inCutOff = cos(radians(10.0f));
    float outCutOff = cos(radians(15.0f));
    vec3 spotDir = vec3(-1.2f,-1.0f,-2.0f);

    //环境光
    vec3 ambient = ambientStrength * texture(Texture,outTexCoord).rgb;

    //漫反射
    vec3 norm = normalize(outNormal);
    vec3 lightDir = normalize(lightPo - FragPo);    //当前顶点 至 光源的的单位向量

    //点光源
    float diff = max(dot(norm,lightDir),0.0);   //光源与法线夹角
    vec3 diffuse = diff * lightColor*texture(Texture,outTexCoord).rgb;

    //镜面反射
    vec3 viewDir = normalize(viewPo - FragPo);
    vec3 reflectDir = reflect(-lightDir,outNormal);

    float spec = pow(max(dot(viewDir, reflectDir),0.0),reflectance);
    vec3 specular = specularStrength * spec * texture(specularTexture,outTexCoord).rgb;

    float LFDistance = length(lightPo - FragPo);
    float lightWeakPara = 1.0/(constantPara + linearPara * LFDistance + quadraticPara * (LFDistance*LFDistance));


    float theta = dot(lightDir,normalize(-spotDir));
    float epsilon  = inCutOff - outCutOff;
    float intensity = clamp((theta - outCutOff)/epsilon,0.0,1.0);

    vec3 res = (ambient + diffuse + specular)*intensity;

    FragColor = vec4(res,1.0);
}


void main()
{
    Spotlight();
}

