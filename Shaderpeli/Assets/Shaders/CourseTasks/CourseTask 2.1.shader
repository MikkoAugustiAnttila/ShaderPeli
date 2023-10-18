Shader "Example/URPUnlitShaderMoveUp_WorldSpace"
{
    Properties
    {
        [KeywordEnum(Local, World, View)]
        _SpaceKeyword("Space", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "Queue" = "Geometry"
        }

        Pass
        {
            HLSLPROGRAM

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #pragma vertex vert
            #pragma fragment frag
            

            #pragma shader_feature_local_vertex _SPACEKEYWORD_LOCAL _SPACEKEYWORD_WORLD _SPACEKEYWORD_VIEW
            

            struct Attributes
            {
                float4 positionOS   : POSITION;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                
                
                #if _SPACEKEYWORD_LOCAL
                input.positionOS.y += 1.0;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                #elif _SPACEKEYWORD_WORLD
                float4x4 worldMatrix = unity_ObjectToWorld;
                output.positionHCS = mul(worldMatrix, input.positionOS);
                output.positionHCS.y += 1.0;
                output.positionHCS = TransformWorldToHClip(output.positionHCS.xyz);
                #elif _SPACEKEYWORD_VIEW
                
                #endif
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return half4(1, 1, 1, 1);
            }
            ENDHLSL
        }
    }
}
