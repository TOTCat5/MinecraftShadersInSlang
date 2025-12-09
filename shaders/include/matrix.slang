float2x2 mat2_rotate_z(float radians)
{
    return float2x2(
        cos(radians), -sin(radians),
        sin(radians), cos(radians)
    );
}