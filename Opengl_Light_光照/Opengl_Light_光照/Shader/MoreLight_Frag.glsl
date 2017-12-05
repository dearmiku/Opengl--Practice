#version 300 es

precision mediump float;

out vec4 FragColor;

uniform vec3 viewPo;        //视角位置

uniform sampler2D Texture;          //物体纹理
uniform sampler2D specularTexture;  //镜面纹理


in vec2 outTexCoord;    //纹理坐标
in vec3 outNormal;      //顶点法向量
in vec3 FragPo;         //顶点坐标



//平行光
struct parallelLight {
    vec3 lightDir;  //光线方向
    vec3 lightColor;

    //环境光照 和 镜面光照
    float ambientStrength;
    float specularStrength;
    float reflectance;
};

//点光源
struct pointLight{
    vec3 lightPo;
};

uniform float point_ambientStrength;
uniform float point_specularStrength;

//聚光源
struct Spotlight{
    vec3 lightPo;
    vec3 lightColor;
    
    vec3 spotDir;
    float inCutOff;
    float outCutOff;

    float constant;
    float linear;
    float quadratic;

    float ambientStrength;
    float specularStrength;
    float reflectance;
};


uniform parallelLight paL;
uniform pointLight  poL[4];
uniform Spotlight spL;


vec3 pointLightDeal(){
    vec3 res = texture(Texture,outTexCoord).rgb;
    vec3 data = vec3(0.0);
    for (int i = 0; i<4; i++) {
        //环境光
        vec3 ambient = point_ambientStrength * res;

        //漫反射
        vec3 norm = normalize(outNormal);
        vec3 lightDir = normalize(poL[i].lightPo - FragPo);    //当前顶点 至 光源的的单位向量
        float diff = max(dot(norm,lightDir),0.0);   //光源与法线夹角
        vec3 diffuse = diff * spL.lightColor * res *1.5;

        //镜面反射
        vec3 viewDir = normalize(viewPo - FragPo);
        vec3 reflectDir = reflect(-lightDir,outNormal);

        float spec = pow(max(dot(viewDir, reflectDir),0.0),spL.reflectance);
        vec3 specular = point_specularStrength * spec * res;

        float LFDistance = length(poL[i].lightPo - FragPo);
        float lightWeakPara = 1.0/(spL.constant + spL.linear * LFDistance + spL.quadratic * (LFDistance*LFDistance));

        data += (ambient + diffuse + specular)*lightWeakPara;
    }
    return data;
}

vec3 SpotLightDeal(){

    vec3 data = texture(Texture,outTexCoord).rgb;
    //聚光灯切角 (一些复杂的计算操作 应该让CPU做,提高效率,不变的量也建议外部传输,避免重复计算)
    float inCutOff = cos(radians(10.0f));
    float outCutOff = cos(radians(15.0f));
    vec3 spotDir = vec3(-1.2f,-1.0f,-2.0f);

    //环境光
    vec3 ambient = spL.ambientStrength * data.rgb;

    //漫反射
    vec3 norm = normalize(outNormal);
    vec3 lightDir = normalize(spL.lightPo - FragPo);    //当前顶点 至 光源的的单位向量

    float diff = max(dot(norm,lightDir),0.0);   //光源与法线夹角
    vec3 diffuse = diff * spL.lightColor*data;

    //镜面反射
    vec3 viewDir = normalize(viewPo - FragPo);
    vec3 reflectDir = reflect(-lightDir,outNormal);

    float spec = pow(max(dot(viewDir, reflectDir),0.0),spL.reflectance);
    vec3 specular = spL.specularStrength * spec * data;

    float LFDistance = length(spL.lightPo - FragPo);
    float lightWeakPara = 1.0/(spL.constant + spL.linear * LFDistance + spL.quadratic * (LFDistance*LFDistance));


    float theta = dot(-lightDir,normalize(spL.spotDir));
    float epsilon  = spL.inCutOff - spL.outCutOff;
    float intensity = clamp((theta - spL.outCutOff)/epsilon,0.0,1.0);

    vec3 res = (ambient + diffuse + specular)*intensity*lightWeakPara;
    return res;

}


//平行光处理
vec3 paralleDeal(vec3 data){
    //平行光方向
    vec3 paraLightDir = normalize(paL.lightDir);
    //漫反射
    vec3 norm = normalize(outNormal);
    float diff = max(dot(norm,paraLightDir),0.0);
    vec3 diffuse = diff * paL.lightColor * data;

    //平行光版本
    vec3 reflectDir = reflect(-paraLightDir,outNormal);
    float spec = pow(max(dot(paraLightDir, reflectDir),0.0),paL.reflectance);
    vec3 specular = paL.specularStrength * spec * data;

    vec3 res = paL.ambientStrength*data + diffuse + specular;
    return res;
}


void main(){
    vec3 tex = texture(Texture,outTexCoord).rgb;
    tex = paralleDeal(tex);
    tex += SpotLightDeal();
    tex += pointLightDeal();

    FragColor = vec4(tex,1.0);
}

