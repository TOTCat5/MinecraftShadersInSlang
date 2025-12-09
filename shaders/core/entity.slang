

#include <include/light.slang>
#include <include/fog.slang>
#include <include/dynamictransforms.slang>
#include <include/projection.slang>

uniform Sampler2D Sampler0;
uniform Sampler2D Sampler1;
uniform Sampler2D Sampler2;

struct VS_Input
{
    float3 Position;
    float4 Color;
    float2 UV0;
    int2 UV1;
    int2 UV2;
    float3 Normal;
}

struct PS_Input
{
    float4 gl_Position:SV_Position;

    float sphericalVertexDistance;
    float cylindricalVertexDistance;
    #ifdef PER_FACE_LIGHTING
    float4 vertexPerFaceColorBack;
    float4 vertexPerFaceColorFront;
    #else
    float4 vertexColor;
    #endif
    float4 lightMapColor;
    float4 overlayColor;
    float2 texCoord0;
}


[shader("vertex")]
PS_Input vertMain(VS_Input input)
{
    PS_Input output;

    output.gl_Position=mul(ProjMat,mul(ModelViewMat,float4(input.Position,1.0)));

    output.sphericalVertexDistance=fog_spherical_distance(input.Position);
    output.cylindricalVertexDistance=fog_cylindrical_distance(input.Position);

    

    #ifdef PER_FACE_LIGHTING
        float2 light=minecraft_compute_light(Light0_Direction,Light1_Direction,input.Normal);
        output.vertexPerFaceColorBack=minecraft_mix_light_separate(-light,input.Color);
        output.vertexPerFaceColorFront=minecraft_mix_light_separate(light,input.Color);
    #elif defined(NO_CARDINAL_LIGHTING)
        output.vertexColor=input.Color;
    #else
        output.vertexColor=minecraft_mix_light(Light0_Direction,Light1_Direction,input.Normal,input.Color);
    #endif
    #ifndef EMISSIVE
        output.lightMapColor=Sampler2.Load(int3(input.UV2/16,0));
    #endif
        output.overlayColor=Sampler1.Load(int3(input.UV1,0));

        output.texCoord0=input.UV0;
    #ifdef APPLY_TEXTURE_MATRIX
        output.texCoord0=mul(TextureMat,float4(input.UV0,0.0,1.0)).xy;
    #endif
}

[shader("fragment")]
float4 fragMain(PS_Input input):SV_Target
{
    float4 color=Sampler0.Sample(input.texCoord0);
    #ifdef ALPHA_CUTOUT
        if (color.a < ALPHA_CUTOUT) {
            discard;
        }
    #endif
    #ifdef PER_FACE_LIGHTING
        color *= (gl_FrontFacing ? vertexPerFaceColorFront : vertexPerFaceColorBack) * ColorModulator;
    #else
        color *= vertexColor * ColorModulator;
    #endif
    #ifndef NO_OVERLAY
        color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    #endif
    #ifndef EMISSIVE
        color *= lightMapColor;
    #endif
        fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
    }
}
