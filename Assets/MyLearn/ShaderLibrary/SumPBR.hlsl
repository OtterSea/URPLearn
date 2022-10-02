
//这个文件的代码来自UWA，是对真实PBR渲染的公式复刻

#ifndef SUMMON_SHADER_SUM_PBR
#define SUMMON_SHADER_SUM_PBR

#include "./SumUtility.hlsl"

//依据距离返回衰减float - 此float将会直接 * color
float SumGetAttenuationByDistance(float distance)
{
    return 1.0 / (distance * distance);
}

//--------------- Cook-Torrance specular BRDF 公式部分 ---------------//

#define DEFAULT_F0 half4(0.04, 0.04, 0.04, 1.0 - 0.04) //standard dielectric reflectivity coef at incident angle (= 4%)

struct SumBRDFData
{
    half perceptualRoughness;   //感性粗糙度
    half metallic;              //金属度
    half3 albedo;               //漫反射默认颜色 反射率
    half roughness;             //粗糙度 = perceptualRoughness^2
    half roughness2;            //roughness^2
    half3 f0;                    //菲涅尔f0
};

//感性粗糙度 变 真粗糙度
half PerceptualRoughnessToRoughness(half perceptualRoughness)
{
    return perceptualRoughness * perceptualRoughness;
}

//初始化BRDF数据，此代码参考了URP中的部分代码
void InitializeBRDFData(half3 albedo, half metallic, half roughness, out SumBRDFData outBRDFData)
{
    outBRDFData.perceptualRoughness = roughness;
    outBRDFData.metallic = metallic;
    outBRDFData.albedo = albedo;
    outBRDFData.roughness = PerceptualRoughnessToRoughness(roughness);
    outBRDFData.roughness2 = outBRDFData.roughness * outBRDFData.roughness;
    outBRDFData.f0 = lerp(kDieletricSpec.rgb, albedo, metallic);            //这里应该是half3吧？
}

//使用 Trowbridge-Reitz 法线分布函数 - N
half DistributionTerm(half NoH, half roughness)
{
    // half a2 = max(0.01, roughness * roughness);
    half a2 = roughness * roughness;
    half nh2 = NoH * NoH;
    half d = nh2 * (a2 - 1) + 1.00001f;
    return a2 / (d * d);

    // half a = max(roughness * roughness, 0.01);
    // half a2 = a * a;
    // half nh2 = NoH * NoH;
    // half d = (nh2 * (a2 - 1) + 1.00001f) * PI;
    // return a2 / d;
}

//几何遮蔽 - D，使用UE的方案 Schlick-GGX
half GeometryTerm(half roughness, half NoL, half NoV)
{
    half k = pow(roughness + 1, 2) / 8;
    half G1 = NoL / lerp(NoL, 1, k);
    half G2 = NoV / lerp(NoV, 1, k);
    half G = G1 * G2;
    return G;
}

//菲涅尔-F Schlick
half3 FresnelTerm(half3 f0, half VoH)
{
    return f0 + (1 - f0) * SumPow5(1 - VoH);
}

//计算直接光BRDF部分（漫反射+镜面反射
half3 DirectBRDF(SumBRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
{
    half3 halfDir = normalize(lightDirectionWS + viewDirectionWS);
    half NoH = max(saturate(dot(normalWS, halfDir)), 0.000001);
    half LoH = max(saturate(dot(lightDirectionWS, halfDir)), 0.000001);
    half NoL = max(saturate(dot(normalWS, lightDirectionWS)), 0.000001);
    half NoV = max(saturate(dot(normalWS, viewDirectionWS)), 0.000001);
    half VoH = max(saturate(dot(viewDirectionWS, halfDir)), 0.000001);

    half D = DistributionTerm(NoH, brdfData.roughness);
    half G = GeometryTerm(brdfData.roughness, NoL, NoV);
    half3 F = FresnelTerm(brdfData.f0, VoH);

    //上面的max都是为了防止出现除0
    half3 specularTerm = (D * G * F) / (NoV * NoL * 4);
    half3 ks = F;
    half3 kd = (1 - ks) * (1 - brdfData.metallic);

    return kd * brdfData.albedo + specularTerm;
}

//--------------- ----------------------------------- ---------------//

//--------------- 间接光镜面反射部分 --------------//

// The *approximated* version of the non-linear remapping. It works by
// approximating the cone of the specular lobe, and then computing the MIP map level
// which (approximately) covers the footprint of the lobe with a single texel.
// Improves the perceptual roughness distribution.
half PerceptualRoughnessToMipmapLevel(half perceptualRoughness, uint mipMapCount)
{
	perceptualRoughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);

	return perceptualRoughness * mipMapCount;
}

half PerceptualRoughnessToMipmapLevel(half perceptualRoughness)
{
	return PerceptualRoughnessToMipmapLevel(perceptualRoughness, UNITY_SPECCUBE_LOD_STEPS);
}

//ibl漫反射部分使用的Schlick
half3 FresnelTerm_Roughness(half3 f0, half VoH, half roughness)
{
	return f0 + (max(1 - roughness, f0) - f0) * SumPow5(1 - VoH);
}

//间接光镜面反射BRDF部分
half3 BRDFIBLSpec(SumBRDFData brdfData, float2 scaleBias)
{
	return brdfData.f0 * scaleBias.x + scaleBias.y;
}

#endif