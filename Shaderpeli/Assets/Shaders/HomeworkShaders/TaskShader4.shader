Shader "Example/IntersectionShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _IntersectionColor("Intersection Color", Color) = (0, 0, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" "RenderPipeline"="UniversalPipeline" }
        Pass
            {
                Name "Normals"
                Tags { "LightMode" = "DepthNormalsOnly" }
                
                Cull Back
                ZTest LEqual
                ZWrite On
                
                HLSLPROGRAM
                
                #pragma vertex DepthNormalsVert
                #pragma fragment DepthNormalsFrag

                #include "../../Common/DepthOnly.hlsl"
                
            ENDHLSL
        }
        Pass
        {
            Name "IntersectionUnlit"
            Tags { "LightMode"="SRPDefaultUnlit" }
            
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS : POSITION;
                float3 positionWS : TEXCOORD1;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                //output.positionWS = TransformObjectToWorld(input.positionOS).xyz;
                output.positionWS = mul(UNITY_MATRIX_V, input.positionOS).xyz;
                return output;
            }

            float4 _Color;
            float4 _IntersectionColor;

            half4 frag(Varyings input) : SV_Target
            {
                float2 screenUV = GetNormalizedScreenSpaceUV(input.positionHCS);
                
                float sceneDepth = SampleSceneDepth(screenUV);
                float linearEyeDepth = LinearEyeDepth(sceneDepth, _ZBufferParams);
                
                float objLinearEyeDepth = LinearEyeDepth(input.positionWS, UNITY_MATRIX_V);
                
                float lerpValue = pow(1 - saturate(linearEyeDepth - objLinearEyeDepth), 15);
                
                half4 colObject = _Color;
                half4 colIntersection = _IntersectionColor;
                half4 finalColor = lerp(colObject, colIntersection, lerpValue);

                return finalColor;
            }
            ENDHLSL
        }
    }
}