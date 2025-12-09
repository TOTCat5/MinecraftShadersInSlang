uniform Sampler2D InSampler;

in float2 texCoord;


float4 main()
{
    return InSampler.Sample(texCoord);
}