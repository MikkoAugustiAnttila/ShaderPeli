Shader "Custom/PaintTextureShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    
    SubShader
    {
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
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            Varyings vert (Attributes input)
            {
                Varyings output;
                output.positionHCS = UnityObjectToClipPos(input.positionOS);

                // Add a time-based offset to the texture coordinates
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                output.uv += _Time.x; // Adjust the speed as needed

                return output;
            }
            
            fixed4 frag (Varyings input) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, input.uv);
                return col;
            }
            ENDCG
        }
    }
}
