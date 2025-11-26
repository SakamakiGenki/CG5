Shader "Unlit/02-02"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _BrightColor("Bright Color", Color) = (1,1,1,1)
        _ShadowColor("Shadow Color", Color) = (0.3,0.3,0.3,1)
        _Threshold("Threshold", Range(0,1)) = 0.5
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        Pass
        {
            Name "ForwardLit"
            Tags{ "LightMode"="UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // URP 基本ライブラリ
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // URP ライティング機能 ← これが必須
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            float4 _BaseColor;
            float4 _BrightColor;
            float4 _ShadowColor;
            float _Threshold;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 normalWS    : TEXCOORD0;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.normalWS = normalize(TransformObjectToWorldNormal(IN.normalOS));
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Main Light を取得（URP専用）
                Light mainLight = GetMainLight();

                float NdotL = saturate(dot(IN.normalWS, -mainLight.direction));

                // Step Toon
                float shadow = step(_Threshold, NdotL);

                float3 toon = lerp(_ShadowColor.rgb, _BrightColor.rgb, shadow);

                return half4(toon * _BaseColor.rgb, 1);
            }
            ENDHLSL
        }
    }
}