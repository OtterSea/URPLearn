
//第一个shader：模拟非金属PBR

Shader "Summon/SumPBR"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _BaseMap ("Base Map", 2D) = "white" {}

        _BumpScale ("Bump Scale", Range(1, 5)) = 1
        [NoScaleOffset] [Noraml] _BumpMap("Bump Map", 2D) = "bump" {}

        _MetalMap("MetalMap", 2D) = "white" {}

        _Metallic ("Metallic", Range(0, 1)) = 0
        _Roughness ("Roughness", Range(0, 1)) = 0
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

            #include "./../../_ShaderLibrary/SumCore.hlsl"
            
            //变量
            CBUFFER_START(UnityPerMaterial)

            half4 _BaseColor;
            float4 _BaseMap_ST;
            float _BumpScale;
            float _Roughness;
            float _Metallic;

            CBUFFER_END

            //贴图
            TEXTURE2D(_BaseMap);        SAMPLER(sampler_BaseMap);
            TEXTURE2D(_BumpMap);        SAMPLER(sampler_BumpMap);
            TEXTURE2D(_MetalMap);       SAMPLER(sampler_MetalMap);


            //输入输出
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD1;
                float3 positionWS : TEXCOORD2;

                float3 normalWS : TEXCOORD3;
                float3 tangentWS : TEXCOORD4;
                float3 bitangentWS : TEXCOORD5;
            };

            // 函数
            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                //必备函数
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);

                //uv的 tilling offset 变化
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);

                //世界顶点
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);

                //法线相关处理
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                output.bitangentWS = normalInputs.bitangentWS;

                return output;
            }

            half4 frag(Varyings input) : SV_TARGET
            {
                // 法线贴图采样 （可能需要初始化一下再采样处理
                float4 normalTXS = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uv);
                half3x3 TBN = SumGetTBN(input.tangentWS, input.bitangentWS, input.normalWS);
                float3 normalWS = SumGetBumpTexNormalWS(normalTXS, TBN, _BumpScale);

                //视线方向
                float3 viewDirWS = GetWorldSpaceNormalizeViewDir(input.positionWS.xyz);

                //物体色
                half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);

                //金属贴图
                half4 metallicInfo = SAMPLE_TEXTURE2D(_MetalMap, sampler_MetalMap, input.uv);

                //直射光颜色
                half roughness = 1 - metallicInfo.a * (1 - _Roughness);//MetalMap的alpha通道保存的是光滑度
                SumBRDFData brdfData;
                InitializeBRDFData((albedo*_BaseColor).rgb, metallicInfo.r*_Metallic, roughness, brdfData);
                SumLight light = SumGetDirectionalLight();
                half NoL = saturate(dot(normalWS, light.dir));
                half3 irradiance = NoL * light.color;
                half3 directColor = DirectBRDF(brdfData, normalWS, light.dir, viewDirWS) * irradiance;

                //间接光漫反射（使用球谐函数实现）
                half NoV = saturate(dot(normalWS, viewDirWS));
                half3 indirectDiffuse = SampleSH(normalWS) * albedo * _BaseColor;        //RCP_PI
                half3 ks = FresnelTerm_Roughness(brdfData.f0, NoV, brdfData.roughness);
                half3 kd = (1 - ks) * (1 - brdfData.metallic);
                half3 indirectColor = kd * indirectDiffuse;
                // half3 indirectColor = SampleSH(normalWS);

                //镜面反射
// _GlossyEnvironmentCubeMap
                float3 reflectDir = reflect(-viewDirWS, normalWS);

                half mip = PerceptualRoughnessToMipmapLevel(brdfData.perceptualRoughness);
                float3 prefilteredColor = SAMPLE_TEXTURECUBE_LOD(_GlossyEnvironmentCubeMap, sampler_GlossyEnvironmentCubeMap, reflectDir, mip).rgb;
                // float4 scaleBias = UNITY_SAMPLE_TEX2D(_BRDFLUT, float2(NoV, brdfData.perceptualRoughness));
                half3 indirectSpec = ks * prefilteredColor;  //BRDFIBLSpec(brdfData, scaleBias.xy) *


                //环境光
                // half4 ambient = half4(SampleSH(normalWS), 1) * albedo;

                // return half4(directColor + indirectColor + indirectSpec, 1);
                // return half4(directColor + indirectColor, 1);

                // return half4(directColor, 1);
                // return half4(indirectColor, 1);
                // return half4(indirectSpec, 1);

                half4 encodedIrradiance = half4(SAMPLE_TEXTURECUBE(unity_SpecCube0, samplerunity_SpecCube0, normalWS));
                return encodedIrradiance;
                // return half4(unity_SpecCube0.rgb, 1.0);
            }
            ENDHLSL
        }
    }

    FallBack Off
}

                // 漫反射颜色本身
                // half4 baseMapColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor * half4(_MainLightColor.xyz, 1.0);
                // //环境光照本身
                // // half4 ambient = half4(SampleSH(normalWS), 1) * baseMapColor;
                // //漫反射比例FM + FS = 1
                // //漫反射
                // // half4 diffuse = SumLambert(baseMapColor, _MainLightPosition.xyz, normalWS);
                // //镜面反
                // // half4 specular = SumPBRReflectColor(_MainLightColor.xyz, viewDirWS, _MainLightPosition.xyz, normalWS);
                // //_MainLightColor.xyz * 
                // //baseMapColor * half4(lightColor, 1) + 
                // //直射光光照颜色PBR
                // half3 dirLit = SumCookTorranceBRDF(baseMapColor, normalWS, viewDirWS, _MainLightPosition.xyz,
                //     _Metallic, _Roughness, 1.0);
                // half3 color = dirLit + ambient;
                // half4 finalColor = half4(color, 1.0);
                // return finalColor;

//有关环境反射的计算
// #if !defined(_ENVIRONMENTREFLECTIONS_OFF)

//     half3 irradiance;

//     #ifdef _REFLECTION_PROBE_BLENDING
//         irradiance = CalculateIrradianceFromReflectionProbes(reflectVector, positionWS, perceptualRoughness);
//     #else
//         #ifdef _REFLECTION_PROBE_BOX_PROJECTION
//             reflectVector = BoxProjectedCubemapDirection(reflectVector, positionWS, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
//         #endif // _REFLECTION_PROBE_BOX_PROJECTION

//         half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
//         half4 encodedIrradiance = half4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip));

//         #if defined(UNITY_USE_NATIVE_HDR)
//             irradiance = encodedIrradiance.rgb;
//         #else
//             irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
//         #endif // UNITY_USE_NATIVE_HDR
//     #endif // _REFLECTION_PROBE_BLENDING

//     return irradiance * occlusion;

// #else
//         return _GlossyEnvironmentColor.rgb * occlusion;
// #endif // _ENVIRONMENTREFLECTIONS_OFF
