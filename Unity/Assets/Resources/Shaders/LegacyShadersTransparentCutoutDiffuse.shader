// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Xcqy/LegacyShadersTransparentCutoutDiffuse" {
	Properties
	{
		_MainTex ("Sprite Texture", 2D) = "white" {}
		_AlphaCull ("AlphaCull",Range(0,1)) = 0.5
		_Alpha ("Alpha",Range(0,1)) = 1
		_Color ("_Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags
		{ 
			"Queue"="Geometry-100" 
			"RenderType"="Transparent-1" 
		}
		
		Pass
		{ 
			Tags{"LightMode"="ForwardBase"}
			Blend SrcAlpha OneMinusSrcAlpha 
			Fog { Mode Global }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			half _AlphaCull;
			half _Alpha;
			fixed4 _Color;
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				half2 texcoord : TEXCOORD0;
				half2 texcoord1 :TEXCOORD1;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				half2 texcoord  : TEXCOORD0;
				half2 texcoord1 : TEXCOORD1;
				UNITY_FOG_COORDS(2)
			};
			

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.texcoord1 = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				fixed4 color = tex2D(_MainTex, i.texcoord.xy);
				clip(color.a - _AlphaCull);
				color *= fixed4(DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,i.texcoord1.xy)),1.0);
				UNITY_APPLY_FOG(i.fogCoord, color); 
				color.a = color.a * _Alpha;
				return color * _Color;
			}
		ENDCG
		}
		
	
	}
	FallBack "Diffuse"
}
