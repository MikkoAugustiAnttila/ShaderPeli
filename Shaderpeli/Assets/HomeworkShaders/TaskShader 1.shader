/*Isoilta osin plagioitu netistä koska en saanut itse tehtyä mitenkään niin
että ei tule vain täysin musta. Ensi kerralla olisi kiva saada vähän enemmän ohjeistusta eikä vain
"joo tee jotain tolla jutulla jota ei käyty tunnilla läpi" :/
*/
Shader "Example/URPUnlitShaderNormal"
{    
    Properties
    {
        
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
            HLSLPROGRAM            
            #pragma vertex vert            
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            

            struct Attributes
            {
                float4 positionOS   : POSITION;
                half3 normal        : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                half3 normal        : TEXCOORD0;
            };                                   

            Varyings vert(Attributes input)
            {                
                Varyings output;                
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.normal = TransformObjectToWorldNormal(input.normal);                
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {                
                half4 color = 0;
                color.rgb = input.normal * 0.5 + 0.5;                
                return color;
            }
            ENDHLSL
        }
    }
}