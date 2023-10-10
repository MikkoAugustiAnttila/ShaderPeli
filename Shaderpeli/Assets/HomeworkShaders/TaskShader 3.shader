Shader "Example/TaskShader3"
{    
    Properties
    {
        _COLOR("Color", Color) = (1,1,1,1)
        _SHINE("Shine", Range(0, 100)) = 0
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
                
                half3 cameraPosition = _WorldSpaceCameraPos;
                half3 viewDirection = GetWorldSpaceNormalizeViewDir(cameraPosition);
                
                half4 finalColor = BlinnPhong(input.normal, viewDirection, color.rgb, _SHINE);

                return finalColor;
            }

            ENDHLSL
        }
    }
}
