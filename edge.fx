#include "../ReShade.fxh"
#include "../ReShadeUI.fxh"

#include "HSV.fxh"

uniform float kernel_size < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0; ui_max = 1.5;
    ui_label = "Kernel Size";
> = 1;

uniform float threshold < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0; ui_max = 1;
    ui_label = "Threshold";
> = 0.1;

uniform float multiplier < __UNIFORM_SLIDER_FLOAT1
    ui_min = 1; ui_max = 10;
    ui_label = "Multiplier";
> = 0.1;

uniform float background < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0; ui_max = 1;
    ui_label = "Dimness of background";
> = 0.1;

texture ColorTex : COLOR;

sampler ColorSRGB
{
	Texture = ColorTex;
	// SRGBTexture = true;
};

float4 ps(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
    float4 color = tex2D(ColorSRGB, uv);
    
    float step = pow(kernel_size, 2) / 1000;

    float4 top = tex2D(ColorSRGB, uv + float2(0, step));
    float4 right = tex2D(ColorSRGB, uv + float2(step, 0));

    float4 result = color;
    float4 delta_x = color - right;
    float4 delta_y = color - top;
    float4 delta = length(delta_x) > length(delta_y) ? delta_x : delta_y;

    delta.x = delta.x > threshold ? delta.x : 0;
    delta.y = delta.y > threshold ? delta.y : 0;
    delta.z = delta.z > threshold ? delta.z : 0;

    result.xyz = color.xyz * background + delta.xyz * multiplier;
    
    // color = result > threshold ? result : color * background ;

    return result;
}

technique Sharpen < ui_tooltip = "This is a Sharpen filter";>
{
    pass p0
    {
        VertexShader = PostProcessVS;
        PixelShader = ps;
    }
}