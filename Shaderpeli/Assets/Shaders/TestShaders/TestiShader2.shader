Shader "Custom/TestiShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags {
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
            
        }
        Pass
        {
            Name "Depth"
            Tags { "LightMode" = "DepthOnly" }
            
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask R
            
            HLSLPROGRAM
            
            #pragma vertex DepthVert
            #pragma fragment DepthFrag

             // PITÄÄ OLLA RELATIVE PATH TIEDOSTOON!!!
             #include "../../Common/DepthOnly.hlsl"

             ENDHLSL
            }

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

                #include "../../Common/DepthNormalsOnly.hlsl"
                
            ENDHLSL
        }
        Pass
        {
            Name "OmaPass"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXTCOORD0;
                half3 normal    : TEXCOORD0;
                
            };

            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            CBUFFER_END

            Varyings Vert(const Attributes input)
            {
                Varyings output;
                output.positionHCS = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_V, mul(UNITY_MATRIX_M, float4(input.positionOS, 1.0))));
                //output.positionHCS = TransformObjectToHClip(input.positionOS); //Same as above done differently cuz idk???
                
                //output.positionWS = TransformObjectToWorld(input.positionOS); //Worldspace?
                output.positionWS = mul(UNITY_MATRIX_P, input.positionOS); //Object Space?

                const float3 os = mul(UNITY_MATRIX_I_M, output.positionWS); //Object Space? Idk i want to scream

                
                
                return output;
            }

            half4 Frag(const Varyings input) : SV_TARGET
            {
                //return half4(input.positionWS,1); //Weird trippy thing that shouldn't be used but I wanted to save it
                return _Color * clamp(input.positionWS.x, 0, 1);
            }
            
            ENDHLSL
        }
    }
}
