
#ifndef SUMMON_SHADER_SUM_Utility
#define SUMMON_SHADER_SUM_Utility

float SumDot(real3 vec1, real3 vec2)
{
    return max(dot(vec1, vec2), 0);
}

//提高性能的 pow5
float SumPow5(real v)
{
    return v*v*v*v*v;
}

#endif