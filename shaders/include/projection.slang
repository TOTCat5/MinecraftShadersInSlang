layout(std140) cbuffer Projection
{
    float4x4 ProjMat;
};

float4 projection_from_position(float4 position)
{
    float4 projection=position*0.5;
    projection.xy=float2(projection.x+projection.w,projection.y+projection.w);
    projection.zw=position.zw;
    return projection;
}
