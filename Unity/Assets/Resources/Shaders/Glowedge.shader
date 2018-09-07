// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Xcqy/Glowedge" {
	Properties {
		_Opacity("透明度",Float) = 1
		_MainTex ("Main Texture", 2D) = "white" {}
		_DIRLightColor("平行光颜色", Color) = (0.91, 1.0, 0.98, 1.0)
		_DIRLightIntensity("平行光照强度",Float) = 0.4
		_Ambient("环境光亮度", Float) = 0.8
		_RimColor("描边颜色",Color) = (1.0, 0.86, 0.5, 1.0)
		_RimIntensity("描边强度",Float) = 0
		_RimFalloff("描边衰减(1-10)",Float) = 2
	}
	SubShader {
	Tags
	{
		"RenderType"="Transparent"
		"IgnoreProjector"="True"
		"Queue" = "Transparent"
	}
	Pass {
		Lighting Off
		Zwrite On
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off

		CGPROGRAM
		#pragma vertex vert
		#pragma fragment frag
		#include "UnityCG.cginc"
		struct appdata_t {
				fixed4 vertex : POSITION;
				fixed2 texcoord : TEXCOORD0;
				fixed3 normal : NORMAL;
			};

			struct v2f {
				fixed4 vertex : POSITION;
				fixed2 texcoord : TEXCOORD0;
				fixed3 camdir : TEXCOORD1;
				fixed3 normal : TEXCOORD2;
				fixed3 pos : TEXCOORD3;
			};

		   uniform fixed _Opacity;
			uniform sampler2D _MainTex;
			uniform fixed4 _DIRLightColor;
			uniform fixed _DIRLightIntensity;
			uniform fixed4 _RimColor;
			uniform fixed _RimIntensity;
			uniform fixed _Ambient;
			uniform fixed _RimFalloff;

			v2f vert (appdata_t v)
			{
				v2f o;
				fixed3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				fixed3 N = normalize((mul(fixed4(v.normal, 0), unity_WorldToObject).xyz));
				fixed3 I = normalize(_WorldSpaceCameraPos - worldPos);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.pos = worldPos;
				o.normal = N;
				o.camdir = I;
				return o;
			}

			fixed4 frag (v2f i) : COLOR
			{
				fixed4 col;

				fixed4 texcolor = tex2D(_MainTex, i.texcoord);


				//环境光
				col = _Ambient * texcolor;

				//平行光
				col += saturate(dot(fixed3(0,1,0),i.normal)) * _DIRLightColor * _DIRLightIntensity * texcolor;

				//rim
				fixed rim = 1 - abs(dot(i.camdir,i.normal));
				col += _RimColor * pow(rim,_RimFalloff) * _RimIntensity;

				col = saturate(col);
				col.a = texcolor.a * _RimColor.a * _Opacity * rim ;
				return col;
			}
		ENDCG
		}
	}
	Fallback "VertexLit"
}

