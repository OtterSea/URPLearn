
//自习URPshader，复习下之前的知识点，这里只实现一个不透明物体的受光shader的写法

// Shader "Summon/02PBR"
// {
//     Properties
//     {
//         _BaseColor("Base Color", Color) = (1, 1, 1, 1)
//         _BaseMap ("Base Map", 2D) = "white" {}

//         _BumpScale ("Bump Scale", Range(1, 5)) = 1
//         [NoScaleOffset] [Noraml] _BumpMap("Bump Map", 2D) = "bump" {}

//         _Smoothness ("Smoothness", Range(0, 1)) = 0

//     }
//     SubShader
//     {
//         //tags 语句块定义了一个subshader或pass在什么时候、什么情况下会被渲染
//         //以下代码定义了此subshader只会在通用渲染管线URP下渲染以及本物体是不透明物体
//         Tags {
//             "RenderType" = "Opaque"
//             "RenderPipeline" = "UniversalPipeline"
//             "LightMode" = "UniversalForward"
//         }

//         Pass
//         {
//             HLSLPROGRAM



//             struct Attributes
//             {
//                 float4 positionOS : POSITION;
//                 float3 normalOS : NORMAL;
//                 float4 tangentOS : TANGENT;
//                 float2 texcoord : TEXCOORD0;
//             };

//             struct Varyings
//             {
//                 float4 positionHCS : SV_POSITION;

//                 float3 normalWS : TEXCOORD0;
//                 float4 tangentWS : TEXCOORD1;
//                 float3 bitangentWS : TEXCOORD2;

//                 float3 positionWS : TEXCOORD3;

//                 float2 uv : TEXCOORD3;
//             };


//             #pragma vertex vert

//             #pragma fragment frag


//             ENDHLSL
//         }
//     }

//     FallBack Off
// }
