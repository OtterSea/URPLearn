
//自习URPshader，复习下之前的知识点，这里只实现一个不透明物体的受光shader的写法

Shader "Summon/NormalTexExam"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _BaseTex ("Base Texture", 2D) = "" {}

        _NormalScale ("Normal Scale", Float) = 1.0
        [NoScaleOffset] _NormalTex ("Normal Texture", 2D) = "bump" {} 
    }
    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "LightMode" = "UniversalForward"
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "./../../_ShaderLibrary/SumNormal.hlsl"
            #include "./../../_ShaderLibrary/SumLighting.hlsl"

            CBUFFER_START(UnityPerMaterial)

            half4 _BaseColor;
            float4 _BaseTex_ST;
            float _NormalScale;

            CBUFFER_END

            //贴图
            TEXTURE2D(_BaseTex);        SAMPLER(sampler_BaseTex);
            TEXTURE2D(_NormalTex);      SAMPLER(sampler_NormalTex);

            struct SumAttributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct SumVaryings
            {
                float4 positionHCS : SV_POSITION;

                float3 normalWS : TEXCOORD0;
                float3 tangentWS : TEXCOORD1;
                float3 bitangentWS : TEXCOORD2;

                float3 positionWS : TEXCOORD3;

                float2 uv : TEXCOORD4;
            };

            SumVaryings vert(SumAttributes input)
            {
                SumVaryings output = (SumVaryings)0;

                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.uv, _BaseTex);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);

                //计算法线数据 VertexNormalInputs 是URP提供的结构体
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                output.bitangentWS = normalInputs.bitangentWS;

                return output;
            }

            half4 frag(SumVaryings input) : SV_TARGET
            {
                // 法线贴图采样后用两个我的函数得到最后的世界空间法线
                float4 normalTXS = SAMPLE_TEXTURE2D(_NormalTex, sampler_NormalTex, input.uv);
                half3x3 TBN = SumGetTBN(input.tangentWS, input.bitangentWS, input.normalWS);
                float3 normalWS = SumGetBumpTexNormalWS(normalTXS, TBN, _NormalScale);

                // 与法线无关的颜色展示部分
                half4 ambient = SAMPLE_TEXTURE2D(_BaseTex, sampler_BaseTex, input.uv) * _BaseColor;
                SumLight dirLight = SumGetDirectionalLight();
                return SumHalfLambert(ambient, dirLight.dir, normalWS);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
