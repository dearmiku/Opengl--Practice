#version 300 es

precision mediump float;

struct Material {
    sampler2D texture_diffuse1;
    sampler2D texture_specular1;
    sampler2D texture_normal1;
    sampler2D texture_height;
    float shininess;
};


/* Note: because we now use a material struct again you want to change your
mesh class to bind all the textures using material.texture_diffuseN instead of
texture_diffuseN. */

struct PointLight {
    vec3 position;
    
    float constant;
    float linear;
    float quadratic;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

#define NR_POINT_LIGHTS 2

in vec3 fragPosition;
in vec3 Normal;
in vec2 TexCoords;

out vec4 color;

uniform vec3 viewPos;
uniform PointLight pointLights[NR_POINT_LIGHTS];
uniform Material material;

// Function prototypes
vec3 CalcPointLight(PointLight light, Material mat, vec3 normal, vec3 fragPos, vec3 viewDir);

void main()
{	
    vec3 result = vec3(0.0f,0.0f,0.0f);
    vec3 viewDir = normalize(viewPos - fragPosition);
    vec3 norm = normalize(vec3(texture(material.texture_diffuse1, TexCoords)));
    
    for(int i = 0; i < NR_POINT_LIGHTS; i++){

        vec3 lightDir = normalize(pointLights[i].position - fragPosition);
        // Diffuse shading
        float diff = max(dot(norm, lightDir), 0.0);
        // Specular shading
        vec3 reflectDir = reflect(-lightDir, norm);
        float spec = pow(max(dot(viewDir, reflectDir), 0.001), material.shininess);

        float distance = length(pointLights[i].position - fragPosition);
        float attenuation = 1.0f / (pointLights[i].constant + pointLights[i].linear * distance + pointLights[i].quadratic * (distance * distance));

        // Combine results
        vec3 ambient = pointLights[i].ambient * vec3(texture(material.texture_diffuse1, TexCoords));
        vec3 diffuse = pointLights[i].diffuse * diff * vec3(texture(material.texture_diffuse1, TexCoords));
        vec3 specular = pointLights[i].specular * spec * vec3(texture(material.texture_specular1, TexCoords));

        result += ((ambient + diffuse + specular));
    }
        //result += CalcPointLight(pointLights[i], material, norm, fragPosition, viewDir);
        
    color = vec4(result, 1.0f);

}

// Calculates the color when using a point light.
vec3 CalcPointLight(PointLight light, Material mat, vec3 normal, vec3 fragPos, vec3 viewDir)
{
    vec3 lightDir = normalize(light.position - fragPos);
    // Diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);
    // Specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.01), mat.shininess);
    // Attenuation
    float distance = length(light.position - fragPos);
    float attenuation = 1.0f / (light.constant + light.linear * distance + light.quadratic * (distance * distance));    
    // Combine results
    vec3 ambient = light.ambient * vec3(texture(mat.texture_diffuse1, TexCoords));
    vec3 diffuse = light.diffuse * diff * vec3(texture(mat.texture_diffuse1, TexCoords));
    vec3 specular = light.specular * spec * vec3(texture(mat.texture_specular1, TexCoords));

    return (ambient + diffuse + specular);

    //return vec3(texture(mat.texture_diffuse1, TexCoords))+vec3(texture(mat.texture_diffuse1, TexCoords))+vec3(texture(mat.texture_specular1, TexCoords));
}
