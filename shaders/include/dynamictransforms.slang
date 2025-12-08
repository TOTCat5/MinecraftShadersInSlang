

layout(std140) cbuffer DynamicTransforms
{
    float4x4 ModelViewMat;
    float4 ColorModulator;
    float3 ModelOffset;
    float4x4 TextureMat;
    float LineWidth;
}
