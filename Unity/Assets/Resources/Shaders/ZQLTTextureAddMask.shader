// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 中清龙图Unity手游项目专用Shader
// author:王宏亮
// 此Shader用于特效多张发光贴图叠加
// 参数：1张无透明通道的贴图，渲染方式为颜色叠加，贴图黑色为无光白色为白光叠加

Shader "ZQLT/Particles/ZQLTTextureAddMask" {
Properties {
	_Alpha ("Alpha", Range(0,1.0)) = 1.0
	_Color ("Color", Color) = (0.5,0.5,0.5,1.0)
	_MainTex ("Base Texture", 2D) = "white" {}
	_MaskTex ("Mask",2D) = "white" {}
    _StencilComp ("Stencil Comparison", Float) = 8
    _Stencil ("Stencil ID", Float) = 0
    _StencilOp ("Stencil Operation", Float) = 0
    _StencilWriteMask ("Stencil Write Mask", Float) = 255
    _StencilReadMask ("Stencil Read Mask", Float) = 255
    _ColorMask ("Color Mask", Float) = 15
}
Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
    Stencil
    {
        Ref [_Stencil]
        Comp equal
        Pass [_StencilOp]
        ReadMask [_StencilReadMask]
        WriteMask [_StencilWriteMask]
    }
	Blend SrcAlpha One
	ColorMask RGB
	Cull Off
	Lighting Off
	ZWrite Off
	Fog { Color (0,0,0,0) }

	SubShader {
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)

			sampler2D _MainTex;
			sampler2D _MaskTex;
			fixed4 _Color;
			float _Alpha;

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float4 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
			};

			float4 _MainTex_ST;
			float4 _MaskTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.texcoord1 = TRANSFORM_TEX(v.texcoord1,_MaskTex);
				return o;
			}

			fixed4 frag (v2f i) : COLOR
			{
				fixed4 mainTex = tex2D(_MainTex, i.texcoord);
				fixed4 maskTex = tex2D(_MaskTex, i.texcoord1);
				fixed4 outColor = lerp(fixed4(0,0,0,0),mainTex,maskTex);

				return 2.0 * i.color * _Alpha * _Color * outColor;
			}
			ENDCG
		}
	}
}
}
