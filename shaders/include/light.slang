#define MINECRAFT_LIGHT_POWER   (0.6)
#define MINECRAFT_AMBIENT_LIGHT (0.4)

layout(std140) cbuffer Lighting
{
    float3 Light0_Direction;
    float3 Light1_Direction;
};

float2 minecraft_compute_light(float3 lightDir0,float3 lightDir1,float3 normal)
{
    return float2(dot(lightDir0, normal),dot(lightDir1,normal));
}

float4 minecraft_mix_light_separate(float2 light,float4 color)
{
    float2 lightValue=max(float2(0.0),light);
    float lightAccum=min(1.0,(lightValue.x+lightValue.y)*MINECRAFT_LIGHT_POWER+MINECRAFT_AMBIENT_LIGHT);
    return float4(color.rgb*lightAccum,color.a);
}

float4 minecraft_mix_light(float3 lightDir0,float3 lightDir1,float3 normal,float4 color)
{
    float2 light=minecraft_compute_light(lightDir0,lightDir1,normal);
    return minecraft_mix_light_separate(light, color);
}