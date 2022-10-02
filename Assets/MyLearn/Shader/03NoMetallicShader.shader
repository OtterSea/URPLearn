Shader "Summon/NoMetallicShader"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _BaseMap ("Base Map", 2D) = "white" {}
        _Metallic ("Metallic", Range(0.1, 1.0)) = 0.5
        _Roughness ("Roughness", Range(0.1, 1.0)) = 0.5
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
            
            #include "./../ShaderLibrary/SumCore.hlsl"

            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            float4 _BaseMap_ST;
            float _Metallic;
            float _Roughness;
            float _Kd;
            CBUFFER_END

            TEXTURE2D(_BaseMap);        SAMPLER(sampler_BaseMap);

            //结构体
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 normalWS : TEXCOORD3;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                return output;
            }

            half4 frag(Varyings input) : SV_TARGET
            {
                //世界法线
                float3 normalWS = normalize(input.normalWS);

                //视线方向
                float3 viewDirWS = normalize(GetWorldSpaceNormalizeViewDir(input.positionWS.xyz));

                //漫反射基本色
                float3 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv).rgb * _BaseColor.rgb;



                //预准备数据
                SumLight light = SumGetDirectionalLight();
                half NoL = max(saturate(dot(normalWS, light.dir)), 0.000001);
                half NoV = max(saturate(dot(normalWS, viewDirWS)), 0.000001);
                half3 dirHalfDir = normalize(light.dir + viewDirWS);
                half NoH = max(saturate(dot(normalWS, dirHalfDir)), 0.000001);
                half VoH = max(saturate(dot(viewDirWS, dirHalfDir)), 0.000001);

                //直射光数据
                half3 lightColor = NoL * light.color;


                //非金属 - 直射光 - 漫反射
                half3 diffuseDirColor = albedo * lightColor;

                //非金属 - 直射光 - 高光反射
                half D = DistributionTerm(NoH, _Roughness);
                half G = GeometryTerm(_Roughness, NoL, NoV);
                // half3 F = FresnelTerm(lerp(kDieletricSpec.rgb, albedo, _Metallic), VoH);
                half3 F = FresnelTerm(kDieletricSpec.rgb, VoH);

                // half3 specularDirColor = lightColor * G * D * F;
                // half3 specularDirColor = lightColor * D * G;
                // half3 specularDirColor = lightColor * D;
                // half3 specularDirColor = lightColor * G;
                // half3 specularDirColor = lightColor * F;
                half3 specularDirColor = lightColor * (D * G * F) / (NoV * NoL * 4);
                // half3 specularDirColor = lightColor * (D * G) / (NoV * NoL * 4);
                // half3 specularDirColor = lightColor * (D) / (NoV * NoL * 4);

                //







                half3 ks = 0.2;

                // return half4((1-ks) * diffuseDirColor + ks * specularDirColor, 1);
                // return half4((1-ks) * diffuseDirColor + ks * specularDirColor, 1);
                return half4((1-ks) * diffuseDirColor + specularDirColor, 1);


                // return half4(diffuseDirColor, 1);
                // return half4((1-ks) * diffuseDirColor, 1);
                // return half4((1-ks), 1);
                // return half4(ks, 1);
                // return half4(specularDirColor, 1);
                // return half4(ks * specularDirColor, 1);
            }

            ENDHLSL
        }
    }

    FallBack Off
}
