Shader "Example/TaskShader2"
{    
    Properties
    {
        _COLOR("Color", Color) = (1,1,1,1)
        _SHINE("Shine", Range(0.1, 1)) = 0
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // Define the Blinn-Phong lighting function
            half4 BlinnPhong(half3 normalWS, half3 viewDirection, half3 objectColor, half shininess)
            {
            // Retrieve the main light
            Light mainLight = GetMainLight();

            // Ambient lighting
            half3 ambient = 0.1 * mainLight.color;

            // Diffuse lighting
            half3 lightDirection = normalize(mainLight.direction);
            half3 diffuse = saturate(dot(normalWS, lightDirection)) * mainLight.color;

            // Calculate half-vector between light and view direction
            half3 halfway = normalize(lightDirection + viewDirection);

            // Specular lighting
            half3 specular = pow(saturate(dot(normalWS, halfway)), shininess) * mainLight.color;

            // Combine all lighting components
            half3 finalLighting = ambient + diffuse + specular;

            // Calculate the final color
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

            float4 _COLOR;
            half _SHINE;

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

                // Calculate the view direction in world space
                half3 cameraPosition = _WorldSpaceCameraPos;
                half3 viewDirection = GetWorldSpaceNormalizeViewDir(cameraPosition);

                // Calculate the specular lighting component using the shader's shininess value
                half4 finalColor = BlinnPhong(input.normal, viewDirection, color.rgb, _SHINE);

                return finalColor;
            }

            ENDHLSL
        }
    }
}
