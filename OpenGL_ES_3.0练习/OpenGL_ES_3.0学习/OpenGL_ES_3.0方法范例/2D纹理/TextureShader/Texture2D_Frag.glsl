#version 300 es

precision mediump float;


in vec2 outTexCoord;

uniform sampler2D outTexture;
uniform sampler2D outTexture1;

in vec3 outColor;

out vec4 FragColor;

void main()
{
    vec4 t = texture(outTexture1,outTexCoord);

    //FragColor = vec4(t[0],t[1],t[2],t[3]);
    FragColor = mix(texture(outTexture,outTexCoord),texture(outTexture1,outTexCoord),0.2);
    //FragColor = vec4(outColor.x,outColor.y,outColor.z, 1.0);
}
