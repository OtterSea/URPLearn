
#ifndef SUMMON_SHADER_SUM_NORMAL
#define SUMMON_SHADER_SUM_NORMAL

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

//生成TBN矩阵
half3x3 SumGetTBN(float3 tangentWS, float3 bitangentWS, float3 normalWS)
{
    return half3x3(tangentWS.xyz, bitangentWS.xyz, normalWS.xyz);
}

// 使用以下先预计算参数 再调用此函数获得世界空间法线
// float4 normalTXS = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uv);
// half3x3 TBN = SumGetTBN(input.tangentWS, input.bitangentWS, input.normalWS);
float3 SumGetBumpTexNormalWS(float4 normalTXS, real3x3 TBN, float bumpScale)
{
    float3 normalTS = UnpackNormalScale(normalTXS, bumpScale);
    float3 normalWS = TransformTangentToWorld(normalTS, TBN);
    return normalize(normalWS);
}

#endif