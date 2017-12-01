#version 300 es

precision mediump float;


in vec2 outTexCoord;

uniform sampler2D outTexture;
uniform sampler2D outTexture1;


out vec4 FragColor;

void main()
{
    FragColor = mix(texture(outTexture,outTexCoord),texture(outTexture1,outTexCoord),0.2);
}
