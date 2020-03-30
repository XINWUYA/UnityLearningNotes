Shader "LearningNotes/2_DrawShadowWithPCFShader"
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
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 posWS : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _DepthTexture;//深度贴图
            float4 _MainTex_ST;
            float4x4 _LightSpaceMatrix;//光空间变换矩阵，将每个世界坐标变换到光源所见到的空间
            half _Bias;//阴影偏移值
            float _TexturePixelWidth;//深度贴图宽度
            float _TexturePixelHeight;//深度贴图高度

            float CalculateShadow(float4 vPosWS, float3 vFragNormal, float3 vLightDir)
            {
                float Result = 0.0f;

                float4 PosLS = mul(_LightSpaceMatrix, vPosWS);
                PosLS.xyz /= PosLS.w;//将光空间片元位置转换为NDC(裁切空间的标准化设备坐标)
                float3 Project = PosLS * 0.5 + 0.5;//将NDC坐标变换为0到1的范围
                //获取当前像素深度值
                float CurrentDepth = PosLS.z;
                float Bias = max(0.00001 * (1.0 - dot(vFragNormal, vLightDir)), 0.0001);
                //应用PCF求阴影值
                float2 TexelSize = float2(1.0f / _TexturePixelWidth, 1.0f / _TexturePixelHeight);//一个纹理像素的大小
                for (int x = -1; x <= 1; x++) {
                    for (int y = -1; y <= 1; y++) {
                        float2 SampleUV = Project.xy + float2(x, y) * TexelSize;//采样坐标
                        fixed4 pcfDepthRGBA = tex2D(_DepthTexture, SampleUV);
                        float pcfDepth = DecodeFloatRGBA(pcfDepthRGBA);
                        //float pcfDepth = tex2D(_ShadowMapTex, SampleUV).r;
                        Result += CurrentDepth + Bias < pcfDepth ? 1.0 : 0.0;
                    }
                }

                return Result / 9.0f;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.posWS = mul(unity_ObjectToWorld, v.vertex);
                o.posWS.w = 1.0;
                o.normal = mul(v.normal, (float3x3)unity_WorldToObject);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float3 FragColor = tex2D(_MainTex, i.uv).rgb;
                float3 FragNormal = normalize(i.normal);
                float3 LightDir = normalize(UnityWorldSpaceLightDir(i.posWS.xyz));

                float Shadow = CalculateShadow(i.posWS, FragNormal, LightDir);

                float3 ResultColor = FragColor * (1.0f - Shadow);

                return float4(ResultColor, 1.0f);
            }
            ENDCG
        }
    }
}
