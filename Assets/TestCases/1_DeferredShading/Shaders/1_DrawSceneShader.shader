Shader "LearningNotes/1_DrawSceneShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            ZTest Off
            Cull Off
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _NormalAndDepthTex;
            sampler2D _PositionTex;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 FragPosWS = tex2D(_PositionTex, i.uv);
                float4 NormalAndDepth = tex2D(_NormalAndDepthTex, i.uv);
                float3 FragNormal = normalize(NormalAndDepth.xyz);
                float3 FragAlbedo = tex2D(_MainTex, i.uv);

                float3 LightDir = WorldSpaceLightDir(FragPosWS);
                float3 DiffuseColor = saturate(dot(LightDir, FragNormal)) * FragAlbedo;// *_LightColor0.rgb;

                float4 ResultColor = float4(DiffuseColor, 1.0f);
                return ResultColor;
            }
            ENDCG
        }
    }
}
