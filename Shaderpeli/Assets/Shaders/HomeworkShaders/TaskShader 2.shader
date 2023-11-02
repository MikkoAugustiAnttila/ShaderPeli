//ChatGPT tekoälyä hyödynnetty suorituksessa. (Ei täysin tekoälyllä tuotettu, vaan sille annettu koodia ja pyydetty korjaamaan tai tekemään toisella tavalla.) (Lisätty jälkikäteen koska huomattu että täytyy mainita vasta myöhemmin.)
Shader "Example/TaskShader2"
{    
    Properties
    {
        _COLOR("Color", Color) = (1,1,1,1)
        _SHINE("Shine", Range(1, 10)) = 0
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
            
            #include "../../Common/DepthNormalsOnly.hlsl"

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

                #include "../../Common/DepthOnly.hlsl"
                
            ENDHLSL
        }
        Pass
        {
            HLSLPROGRAM
            float4 _COLOR;
            half _SHINE;      
            #pragma vertex vert            
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            half4 BlinnPhong(half3 normalWS, half3 viewDirection, half3 objectColor, half shininess)
            {
            Light mainLight = GetMainLight();
                
            half3 ambient = 0.1 * mainLight.color;
                
            half3 lightDirection = normalize(mainLight.direction);
            half3 diffuse = saturate(dot(normalWS, lightDirection)) * mainLight.color;
                
            half3 halfway = normalize(lightDirection + viewDirection);
                
            half3 specular = pow(saturate(dot(normalWS, halfway)), shininess) * mainLight.color;
                
            half3 finalLighting = ambient + diffuse + specular;
                
            half4 finalColor = half4(finalLighting * objectColor, 1);

            return finalColor;
                
            }

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
                half4 color = _COLOR;
                
                // Use the world space position of the fragment instead of cameraPosition
                half3 fragmentPosition = input.positionHCS.xyz;
                half3 viewDirection = GetWorldSpaceNormalizeViewDir(fragmentPosition);
                
                half4 finalColor = BlinnPhong(input.normal, viewDirection, color.rgb, _SHINE);

                return finalColor;
            }


            ENDHLSL
        }
    }
}
