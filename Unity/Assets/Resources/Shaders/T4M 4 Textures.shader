// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Xcqy/T4MShaderModel2/Diffuse/T4M 4 Textures" {
	Properties {
		_Splat0 ("Layer 1", 2D) = "white" {}
		_Splat1 ("Layer 2", 2D) = "white" {}
		_Splat2 ("Layer 3", 2D) = "white" {}
		_Splat3 ("Layer 4", 2D) = "white" {}
		_Control ("Control (RGBA)", 2D) = "white" {}

	}

	SubShader
	{
		Tags
		{
			"Queue"="Geometry-100"
			"RenderType"="Opaque"
		}

		Pass
		{
			Tags{"LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog

			#include "UnityCG.cginc"
			#include "Lighting.cginc"


			sampler2D _Control;
			float4 _Control_ST;

			sampler2D _Splat0;
			sampler2D _Splat1;
			sampler2D _Splat2;
			sampler2D _Splat3;

			float4 _Splat0_ST;
			float4 _Splat1_ST;
			float4 _Splat2_ST;
			float4 _Splat3_ST;

			struct my_input
			{
				float4 vertex    : POSITION;
				half2 texcoord 	 : TEXCOORD0;
				half2 lightmap   : TEXCOORD1;
			};

			struct v2f
			{
				float4 vertex    : SV_POSITION;

				half4 texcoord 	 : TEXCOORD0;
				half4 texcoord1  : TEXCOORD1;
				half4 lightmap   : TEXCOORD2;

				UNITY_FOG_COORDS(3)
			};

			v2f vert(my_input v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.texcoord.xy = v.texcoord.xy * _Control_ST.xy + _Control_ST.zw;
				o.texcoord.zw = v.texcoord.xy * _Splat0_ST.xy + _Splat0_ST.zw;
				o.texcoord1.xy = v.texcoord.xy * _Splat1_ST.xy + _Splat1_ST.zw;
				o.texcoord1.zw = v.texcoord.xy * _Splat2_ST.xy + _Splat2_ST.zw;

				o.lightmap.xy = v.lightmap.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				o.lightmap.zw = v.texcoord.xy *  _Splat3_ST.xy + _Splat3_ST.zw;

				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 splat_control = tex2D (_Control, i.texcoord.xy).rgba;

				fixed3 lay1 = tex2D (_Splat0, i.texcoord.zw);
				fixed3 lay2 = tex2D (_Splat1, i.texcoord1.xy);
				fixed3 lay3 = tex2D (_Splat2, i.texcoord1.zw);
				fixed3 lay4 = tex2D (_Splat3, i.lightmap.zw);

				fixed4 color  = fixed4((lay1 * splat_control.r + lay2 * splat_control.g + lay3 * splat_control.b + lay4 * splat_control.a),1);

				color *= fixed4(DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap,i.lightmap.xy)),1.0);
				UNITY_APPLY_FOG(i.fogCoord, color);
				return color;
			}
		ENDCG
		}


	}
	FallBack "Diffuse"
}
