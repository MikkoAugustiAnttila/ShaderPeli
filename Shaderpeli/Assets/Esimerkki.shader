Shader "Custom/Esimerkki"
{
    Properties
    {
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture] _BaseMap("Base Map", 2D) = "white" { }
    }
    
CustomEditor"ExampleShaderGUI" // Custom editor GUI
    
    SubShader
    {
    Tags{"RenderType"="Opaque" "RenderPipeline" = "UniversalPipeline" "Queue"="Geometry"}

        Pass {
            Name"ForwardLit"
            Tags {"LightMode" = "UniversalForward"}

            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM

            #pragma exclude_renderers gles gles3 glcore
            #pragma target 4.5
            
            #pragma vertex Vertex
            #pragma fragment Fragment

            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _FORWARD_PLUS

            // Unity defined keywords
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile_fog

            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma instancing_options renderinglayer

            //#include "EsimerkkiProgram.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // This is the input struct for the vertex stage.
            struct Attributes {
                float3 positionOS : POSITION; // The object space position of the vertex
            };

            // This is the output struct for the vertex stage.
            struct Varyings {
                float4 positionHCS : SV_POSITION; // (homogenous) Clip space position, used for interpolation
            };

            // The vertex stage function
            Varyings Vertex(const Attributes input) {
                Varyings output; // The output struct
                // Here we transform the coordinates from object to clip space
                // with ProjectionMatrix * ViewMatrix * ModelMatrix * PositionVector
                output.positionHCS = TransformObjectToHClip(input.positionOS);
                return output;
            }

            // Semantics can be applied directly to functions and parameters
            // The previous function could be rewritten as:
            // float4 Vertex(const float3 positionOS : POSITION) : SV_POSITION {
            //     return TransformObjectToHClip(positionOS);
            // }
            // This is not done, however because usually you want more than one input or output
            // In those cases, it's easier to put them into a struct

            // The fragment stage function
            half4 Fragment(const Varyings input) : SV_TARGET { // Color semantic
                return half4(1, 1, 1, 1);
            }
            ENDHLSL
        }
    }
}