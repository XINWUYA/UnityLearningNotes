﻿Shader "LearningNotes/1_DrawGBufferShader"
{
    Properties
    {
        _MainTex("Albedo", 2D) = "white" {}
        _NormalTex ("Normal", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "GBuffer"="Opaque" }

        Pass
        {
            ZTest LEQual Cull Back ZWrite On
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float depth : TEXCOORD3;
                float4 posWS : TEXCOORD4;
            };

            struct OutRenderTarget
            {
                float4 AlbedoTarget : COLOR0;
                float4 NormalAndDepthTarget : COLOR1;//w为depth
                float4 PositionTarget : COLOR2;
            };

            sampler2D _MainTex;
            sampler2D _NormalTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = COMPUTE_VIEW_NORMAL;
                o.uv = TRANSFORM_UV(0);
                o.depth = (o.vertex.z / o.vertex.w);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            OutRenderTarget frag(v2f i)
            {
                OutRenderTarget ort;

                ort.AlbedoTarget = tex2D(_MainTex, i.uv);
                ort.NormalAndDepthTarget.xyz = i.normal;// normalize(tex2D(_NormalTex, i.uv));
                ort.NormalAndDepthTarget.w = i.depth;
                ort.PositionTarget = i.posWS;
                return ort;
            }
            ENDCG
        }
    }
}