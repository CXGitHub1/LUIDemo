// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// 中清龙图Unity手游项目专用Shader 
// author:王宏亮
// 此Shader用于中心透明制作

Shader "ZQLT/Effect/Particles/CoreTransparentBlended"
{
	Properties
	{
	    _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,1.0)
		_MainTex ("Texture", 2D) = "white" {}
		_RimPower ("Rim Power", Range(0.1,8.0)) = 2.0
		_Strength ("Rim Strength", Range(0, 10.0)) = 0
		_Alpha("Overall Alpha", Range(0, 1.0)) = 1.0
	}
	SubShader
	{
		Tags { "Queue"="Transparent-8" "IgnoreProjector"="True"  }
		LOD 150
	
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha 

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"


			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _RimPower;
			float _Strength;
			float _Alpha;
			fixed4 _TintColor;

			struct appdata
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float3 normal : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

//			inline float3 UnityObjectToWorldNormal( in float3 norm )
//			{
//				// Multiply by transposed inverse matrix, actually using transpose() generates badly optimized code
//				return normalize(unity_WorldToObject[0].xyz * norm.x + unity_WorldToObject[1].xyz * norm.y + unity_WorldToObject[2].xyz * norm.z);
//			}
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				fixed4 tex = tex2D(_MainTex, i.uv);
				if(_Strength == 0)
				{
					col.rgb = tex.rgb * _TintColor * 2;
					col.a = tex.a * _Alpha;
				}
				else
				{
					col.rgb = tex.rgb * _TintColor * 2;
					half rim = saturate(dot (normalize(i.viewDir), i.normal));
					col.a = tex.a * _Alpha * (1 - pow (rim, _RimPower) * _Strength);
				}

				return col;
			}
			ENDCG
		}
	}
}
