//ChatGPT tekoälyä hyödynnetty suorituksessa. (Ei täysin tekoälyllä tuotettu, vaan sille annettu koodia ja pyydetty korjaamaan tai tekemään toisella tavalla.) (Lisätty jälkikäteen koska huomattu että täytyy mainita vasta myöhemmin.)

Shader "Custom/SimpleNormalMap" {
    Properties {
        _MainTex ("Base Texture", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _Strength ("Normal Strength", Range(0, 5)) = 1
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 100
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
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f {
                float2 texcoord : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _BumpMap;
            float _Strength;

            v2f vert (appdata_t v) {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.texcoord = v.texcoord;
                return o;
            }

            half4 frag (v2f i) : SV_Target {
                half4 baseColor = tex2D(_MainTex, i.texcoord);
                half3 normalMap = tex2D(_BumpMap, i.texcoord).rgb * 2.0 - 1.0;
                half3 lighting = normalize(normalMap);
                half3 lightDir = normalize(float3(0, 0, 1));
                half diffuse = max(0, dot(lightDir, lighting)) * _Strength;
                half3 finalColor = baseColor.rgb * diffuse;
                return half4(finalColor, baseColor.a);
            }
            ENDCG
        }
    }
}
