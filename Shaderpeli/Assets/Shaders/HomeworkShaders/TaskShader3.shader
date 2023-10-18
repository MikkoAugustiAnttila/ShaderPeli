Shader "Custom/PaintTextureShader"
{
    Properties
    {
        _MainTexA ("Texture A", 2D) = "white" {}
        _MainTexB ("Texture B", 2D) = "white" {}
        _BlendProperty ("Blend", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
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
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionHCS : SV_POSITION;
            };

            sampler2D _MainTexA;
            sampler2D _MainTexB;
            float4 _MainTexA_ST;
            float4 _MainTexB_ST;
            float _BlendProperty;

            Varyings vert(Attributes input)
            {
                Varyings output;
                output.positionHCS = UnityObjectToClipPos(input.positionOS);
                
                output.uv = TRANSFORM_TEX(input.uv, _MainTexA);
                output.uv = lerp(output.uv, TRANSFORM_TEX(input.uv, _MainTexB), _BlendProperty);

                return output;
            }

            fixed4 frag(Varyings input) : SV_Target
            {
                fixed4 texA = tex2D(_MainTexA, input.uv);
                fixed4 texB = tex2D(_MainTexB, input.uv);
                return lerp(texA, texB, _BlendProperty);
            }

            ENDCG
        }
    }
}
