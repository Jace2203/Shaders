#include "../ReShadeUI.fxh"

uniform int kernel_size < __UNIFORM_SLIDER_INT1
    ui_min = 1; ui_max = 5;
    ui_label = "Kernel Size";
    ui_tooltip = "Control of the kernel size (2n+1)";
> = 1;

#include "../ReShade.fxh"
#include "../FXShaders/Convolution.fxh"

texture ColorTex : COLOR;

sampler ColorSRGB
{
	Texture = ColorTex;
	// SRGBTexture = true;
};

float4 ps(float4 p : SV_POSITION, float2 uv : TEXCOORD) : SV_TARGET
{
	float4 color = tex2D(ColorSRGB, uv);

	return color;
}

technique DoG
{
    pass DifferenceOfGaussians
    {
        VertexShader = PostProcessVS;
        PixelShader = ps;
    }
}