Shader "Example/TaskShader2_TextureNormal"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _SHINE("Shine", Range(1, 50)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
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
            sampler2D _MainTex;
            sampler2D _NormalMap; // New normal map property
            half _SHINE;

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            half4 BlinnPhong(half3 normalWS, half3 viewDirection, half3 objectColor, half shininess, half2 uv)
            {
                Light mainLight = GetMainLight();

                half3 ambient = 0.1 * mainLight.color;

                half3 lightDirection = normalize(mainLight.direction);
                half3 diffuse = saturate(dot(normalWS, lightDirection)) * mainLight.color;

                half3 halfway = normalize(lightDirection + viewDirection);

                half3 specular = pow(saturate(dot(normalWS, halfway)), shininess) * mainLight.color;

                half3 finalLighting = ambient + diffuse + specular;

                half4 finalColor = half4(finalLighting * tex2D(_MainTex, uv).rgb, 1);

                return finalColor;
            }

            struct Attributes
            {
                float4 positionOS : POSITION;
                half3 normal : NORMAL;
                half2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                half3 normal : TEXCOORD1;
                half2 texcoord : TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionHCS = TransformObjectToHClip(input.positionOS.xyz);
                output.normal = TransformObjectToWorldNormal(input.normal);
                output.texcoord = input.texcoord;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                // Sample the normal map
                half3 normalMapSample = tex2D(_NormalMap, input.texcoord).xyz * 2 - 1; // Convert to -1 to 1 range

                // Perturb the surface normal using the normal map
                half3 normalWS = normalize(input.normal + normalMapSample);

                half4 finalColor = BlinnPhong(normalWS, GetWorldSpaceNormalizeViewDir(input.positionHCS.xyz), half3(1, 1, 1), _SHINE, input.texcoord);

                return finalColor;
            }

            ENDHLSL
        }
    }
}
