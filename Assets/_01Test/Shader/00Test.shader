
//自习URPshader，复习下之前的知识点，这里只实现一个不透明物体的受光shader的写法

Shader "Summon/01Light"
{
    Properties
    {
        _TestInteger ("Test Integer", Integer) = 1

        _TestFloat ("Test Float", Float) = 0.5
        _TestFloatRange ("Test Float Range", Range(0.0, 1.0)) = 0.5

        //"red"{} "white"{} "black"{} "gray"{} "bump"{} 空字符串或无效值，默认“gray”
        _TestTex2D ("Test Tex2D", 2D) = "" {} 

        _TestTex3D ("Test Tex3D", 3D) = "" {}

        _TestTexCube ("Test TexCUBE", Cube) = "" {}

        _TestTexColor ("Test TexColor", Color) = (1, 0.5, 0.5, 1)

        _TestTexVector ("Test TexColor", Vector) = (.25, .5, .5, 1)

    }
    // SubShader
    // {
    //     //tags 语句块定义了一个subshader或pass在什么时候、什么情况下会被渲染
    //     //以下代码定义了此subshader只会在通用渲染管线URP下渲染以及本物体是不透明物体
    //     Tags {
    //         "RenderType" = "Opaque"
    //         "RenderPipeline" = "UniversalPipeline"
    //         "LightMode" = "UniversalForward"
    //     }

    //     Pass
    //     {
    //         HLSLPROGRAM

    //         #pragma shader_feature _LAMBERTLIGHT_OFF


    //         #pragma vertex vert

    //         #pragma fragment frag

    //         #include "./../ShaderLibrary/01Light.hlsl"

    //         ENDHLSL
    //     }
    // }

    FallBack Off
}
