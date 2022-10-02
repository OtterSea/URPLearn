
//提供一些基本的光照公式，一些与光照相关的采样的提示等

#ifndef SUMMON_SHADER_SUM_LIGHTING
#define SUMMON_SHADER_SUM_LIGHTING

// 获得视线WS：
// output.viewDirWS = GetWorldSpaceNormalizeViewDir(output.positionWS.xyz);



//半兰伯特光照
half4 SumHalfLambert(half3 color, float3 lightDir, float3 normal)
{
    float halfLambert = dot(lightDir, normal) * 0.5 + 1;
    return half4(color * halfLambert, 1);
}

//兰伯特光照
half4 SumLambert(half3 color, float3 lightDir, float3 normal)
{
    float lambert = max(dot(lightDir, normal), 0);
    return half4(color * lambert, 1);
}

//这个函数没写好 连blinnphone都没弄好
//尝试计算PBR的镜面反射颜色
half4 SumPBRReflectColor(half3 color, float3 viewDir, float3 lightDir, float3 normal)
{
    // Phone
    real3 ref = reflect(-lightDir, normal);
    return half4(pow(max(dot(viewDir, ref), 0), 80) * color, 1);

    // BlinnPhone
    // real3 h = normalize(normalize(viewDir) + normalize(lightDir));
    // return half4(pow(max(dot(h, normal), 0), 80) * color, 1);
}

//--------------------- 获得光数据部分

struct SumLight
{
    half3 color;
    float3 dir;
};

SumLight SumGetDirectionalLight()
{
    SumLight light;
    light.color = _MainLightColor.xyz;
    light.dir = _MainLightPosition.xyz;
    return light;
}

#endif