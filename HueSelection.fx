#include "../ReShade.fxh"
#include "../ReShadeUI.fxh"

#include "HSV.fxh"

uniform float hue < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0; ui_max = 360;
    ui_label = "Hue Value";
> = 0;

uniform float proximity < __UNIFORM_SLIDER_FLOAT1
    ui_min = 1; ui_max = 180;
    ui_label = "Proximity";
> = 10;

uniform int mode <
    ui_type = "combo";
    ui_items = "Flat\0Linear\0Gaussian\0Circular\0Spike\0Threshold\0";
    ui_label = "Proximity Mode";
> = 1;

uniform int mode_clamp <
    ui_type = "combo";
    ui_items = "Yes\0No\0";
    ui_label = "Clamp Satuatio with Original Value";
> = 0;

uniform float value < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0; ui_max = 1;
    ui_label = "Value used for Proximity Mode";
> = 0.5;

uniform float min_s < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0; ui_max = 1;
    ui_label = "Min Satuation";
> = 0;

uniform float shift < __UNIFORM_SLIDER_FLOAT1
    ui_min = 0; ui_max = 1;
    ui_label = "Hue Shift";
> = 0;

texture ColorTex : COLOR;

sampler ColorSRGB
{
	Texture = ColorTex;
	// SRGBTexture = true;
};

float prox(float x, float a, float p)
{
    return max(0, 1 - (abs(x - a) / p));
}

float4 ps(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
    float4 color = tex2D(ColorSRGB, uv);
    
    float3 hsv = rgb2hsv(color);

    float d = hsv.x * 360;
    d = max(max(prox(d, hue, proximity), prox(d - 360, hue, proximity)), prox(d + 360, hue, proximity));

    switch (mode)
    {
        case 0: // Flat
            d = ceil(d) * value;
            break;
        case 1: // Linear
            break;
        case 2: // Gaussian
            d = 1 - d;
            d = exp(5.5 * d) + exp(-5.5 * d);
            d = 2 / d;
            break;
        case 3: // Circular
            d = 1 - d;
            d = sqrt(1 - d * d);
            break;
        case 4: // Spike
            d = 1 - sqrt(1 - d * d);
            break;
        case 5: // Threshold
            d = step(d, value) * d;
            break;
        default:
            break;
    }

    d = max(min_s, d);
    if (mode_clamp == 0)
    {
        hsv.y = min(d, hsv.y);
    }
    else
    {
        hsv.y = d;
    }

    hsv.x += shift;

    float4 result = float4(hsv2rgb(hsv), 1);

    return result;
}

technique HueSelection
{
    pass p0
    {
        VertexShader = PostProcessVS;
        PixelShader = ps;
    }
}