

layout(std140) cbuffer Fog
{
    float4 FogColor;
    float FogEnvironmentalStart;
    float FogEnvironmentalEnd;
    float FogRenderDistanceStart;
    float FogRenderDistanceEnd;
    float FogSkyEnd;
    float FogCloudsEnd;
}

float linear_fog_value(float vertexDistance, float fogStart, float fogEnd)
{
    if(vertexDistance<=fogStart)
    {
        return 0.0;
    }
    else if(vertexDistance>=fogEnd)
    {
        return 1.0;
    }

    return (vertexDistance-fogStart)/(fogEnd-fogStart);
}

float total_fog_value(float sphericalVertexDistance,float cylindricalVertexDistance,float environmentalStart,float environmantalEnd,float renderDistanceStart,float renderDistanceEnd)
{
    return max(
        linear_fog_value(sphericalVertexDistance,environmentalStart,environmantalEnd),
        linear_fog_value(cylindricalVertexDistance,renderDistanceStart,renderDistanceEnd)
    );
}

float4 apply_fog(float4 inColor,float sphericalVertexDistance,float cylindricalVertexDistance,float environmentalStart,float environmantalEnd,float renderDistanceStart,float renderDistanceEnd,float4 fogColor)
{
    float fogValue=total_fog_value(
        sphericalVertexDistance,cylindricalVertexDistance,
        environmentalStart,environmantalEnd,
        renderDistanceStart,renderDistanceEnd
    );
    return float4(lerp(inColor.rgb,fogColor.rgb,fogValue*fogColor.a),inColor.a);
}

float fog_spherical_distance(float3 pos)
{
    return length(pos);
}

float fog_cylindrical_distance(float3 pos)
{
    float distXZ=length(pos.xz);
    float distY=abs(pos.y);
    return max(distXZ,distY);
}
