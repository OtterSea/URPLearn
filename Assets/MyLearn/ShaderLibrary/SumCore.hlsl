
#ifndef SUMMON_SHADER_SUM_CORE
#define SUMMON_SHADER_SUM_CORE

//与同名shader配套的hlsl文件，用于学习和实践，之后可以考虑把本文件里的代码封装成好用的函数

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"












//我自己的文件
#include "./SumLighting.hlsl"
#include "./SumNormal.hlsl"
#include "./SumPBR.hlsl"

// 输入输出结构体提示
// struct SumAttributes
// {
//     float4 positionOS : POSITION;
//     float3 normalOS : NORMAL;
//     float4 tangentOS : TANGENT;
//     float2 texcoord : TEXCOORD0;
//     float2 staticLightmapUV   : TEXCOORD1;
//     float2 dynamicLightmapUV  : TEXCOORD2;
//     UNITY_VERTEX_INPUT_INSTANCE_ID
// };

// struct SumVaryings
// {
//     float4 positionHCS : SV_POSITION;

//     float3 normalWS : TEXCOORD0;
//     float4 tangentWS : TEXCOORD1;
//     float3 bitangentWS : TEXCOORD2;

//     float3 positionWS : TEXCOORD3;

//     float2 uv : TEXCOORD3;
// };


#endif